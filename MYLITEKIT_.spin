{
  Platform: Parallax Project USB Board
  Revision: 1.0
  Author: Glenn CHiam Bo shiun
  Date: 26 Nov 2021
  Log:

}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 = _ConClkFreq / 1_000

        ' Comm check signals.

        commForward = 1
        commReverse = 2
        commLeft = 3
        commRight = 4
        commStopAll = 5

        'Motor Commands
        Forward = 1
        Reverse = 2
        Left = 3
        Right = 4
        Stop = 5

VAR
        long mainTof1ADD, mainTof2ADD,mainUltra1ADD, mainUltra2ADD
        long MotorCmd, MotorSpeed
        long RxRead
        long signal
OBJ
  Term    : "FullDuplexSerial.spin"
  Sensor  : "Sensor_Control_.spin"
  Motor   : "Motor_Control_.spin"
  Comm    : "Communications_Control_.spin"

PUB Main

    'for Testing:
    'Term.Start(31, 30 ,0, 115200)
    'Term.Start(21,20,0, 9600)

    Sensor.Start(_Ms_001, @mainTof1ADD, @mainTof2ADD, @mainUltra1ADD, @mainUltra2ADD) 'Read Sensors
    Comm.Start(_Ms_001,@Signal)        'Read comms signals
    'repeat
      'Term.str(string(13, "hello: "))
      'term.dec(signal)
    Motor.Start(_Ms_001,@MotorCmd, @MotorSpeed)     'Initialize motors
    {
    repeat
      MotorCmd := motor.forward(100) 'something wrong with motor 4  (roboclaw acting weird as usual)
      pause(500)     }
   {

    repeat
      term.str(string(13, "TOF1 value: "))
      term.dec(mainToF1ADD)
      term.str(string(13, "TOF2 value: "))
      term.dec(mainToF2ADD)
      term.str(string(13, "ultra1 value: "))
      term.dec(mainUltra1ADD)
      term.str(string(13, "ultra2 value: "))
      term.dec(mainUltra2ADD)
      pause(500)
      term.tx(0)          }

    repeat

        case Signal

          CommForward:                        'Forward when forward signal received.
             if ((mainToF1ADD < 230) and ((mainUltra1ADD > 300) or (mainUltra1ADD == 0)))

                MotorCmd := motor.Forward(100)

             elseif ((mainToF1ADD < 200) and (mainUltra1ADD > 300))       ' when its nearer to an object, the litekit will slow down in case the oject moves away (applies to reverse)
                MotorCmd := motor.Forward(100)

             else
                MotorCmd := stop                                     ' if the object doesnt move away, then the litekit will come to a stop (applies to reverse)
                                   'If obstacle detected stop.
          CommReverse:
             if ((mainToF2ADD < 230) and ((mainUltra2ADD > 300) or (mainUltra2ADD == 0)))

                MotorCmd := motor.Reverse(150)   'Reverse when reverse signal received.

             elseif ((mainToF2ADD < 200) and (mainUltra2ADD > 300))

                MotorCmd := motor.Reverse(100)

             else
               MotorCmd := Stop

          commLeft:
              MotorCmd := motor.turnleft(100)

          commRight:
              MotorCmd := motor.turnright(100)

          5:
              MotorCmd := Stop      'motors will come to a stop when motorcmd receives stop signal

    Sensor.StopCore           ' release all cogs that are being utilised
    Motor.StopCore
    Comm.StopCore


PRI Pause(ms) | t

  t := cnt - 1088   ' sync with system counter
  repeat (ms #> 0)  ' delay must be >0
    waitcnt(t += _Ms_001)
  return
