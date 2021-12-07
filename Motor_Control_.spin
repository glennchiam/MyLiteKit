{
    Project: EE-6 Practical 2
    Platform: Parallax Project USB Board & RoboClaw Servo Control
    Revision: 1.0
    Author:  Glenn Chiam
    Date: 26th Nov 2021
    Log:
       Date: Desc


}
CON
        '' [ Declare Pins for motor ]
        motor1 = 10
        motor2 = 11
        motor3 = 12
        motor4 = 13

        'Motor Zero points.
        motor1Zero = 1380
        motor2Zero = 1400
        motor3Zero = 1210
        motor4Zero = 1230

VAR ' Global variable
      long MotorCogID
      long MotorCogStack[128]
      long _Ms_001


OBJ  ' Objects
  Motors  : "Servo8Fast_vZ2.spin"
  'Term    : "FullDuplexSerial.spin"

PUB Start(mainMSVal,MCmd, MSpeed)

    _Ms_001 := mainMSVal 'For Pause function


    StopCore   ' If MotorCogID detected stops it.

    MotorCogID := cognew(Init(MCmd, MSpeed), @MotorCogStack) 'Assign newcog for Init function.


    return


PUB Init(MCmd, MSpeed)

    'Motor initializing.
    Motors.Init
    Motors.AddSlowPin(motor1)
    Motors.AddSlowPin(motor2)
    Motors.AddSlowPin(motor3)
    Motors.AddSlowPin(motor4)
    Motors.Start


    StopAllMotors 'Ensures Motors don't move at start of function.

    'Moves based on MCmd received from litekit.spin
    repeat
      Case long[MCmd]
        1:
          Forward(MSpeed)

        2:
          Reverse(MSpeed)

        3:
          TurnLeft(MSpeed)

        4:
          TurnRight(MSpeed)

        5:
          StopAllMotors


PUB StopCore  ' Stop the code in the core/cog and release the core/cog
    if MotorCogID
      cogstop(MotorCogID~)

    return
PUB Set(motor, speed)

    Motors.Set(motor,speed)

PUB Forward(i)

    Set(motor1,motor1Zero+i-4)
    Set(motor2,motor2Zero+i)
    Set(motor3,motor3Zero+i-3)
    Set(motor4,motor4Zero+i)

PUB Reverse(i)

    Set(motor1,motor1Zero-i+3)
    Set(motor2,motor2Zero-i)
    Set(motor3,motor3Zero-i)
    Set(motor4,motor4Zero-i)    'behaving very weirdly for motor 4 specifically, zero point always changing

PUB TurnLeft(i)

    Set(motor1,motor1Zero+i)
    Set(motor2,motor2Zero-i)
    Set(motor3,motor3Zero+i)
    Set(motor4,motor4Zero-i)

PUB Turnright(i)

    Set(motor1,motor1Zero-i)
    Set(motor2,motor2Zero+i)
    Set(motor3,motor3Zero-i)
    Set(motor4,motor4Zero+i)
PUB StopAllMotors

    Set(motor1, motor1Zero)
    Set(motor2, motor2Zero)
    Set(motor3, motor3Zero)
    Set(motor4, motor4zero)


PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _MS_001)
  return