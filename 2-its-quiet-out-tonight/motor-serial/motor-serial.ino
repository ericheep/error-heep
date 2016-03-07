#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_MS_PWMServoDriver.h"

// ID number of the arduino, cooresponds to a motor
#define arduinoID 2
#define NUM_MOTORS 2

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield();
// Or, create it with a different I2C address (say for stacking)
// Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x61);

// Connect a stepper motor with 200 steps per revolution (1.8 degree)
Adafruit_StepperMotor *motorOne = AFMS.getStepper(200, 1);

// motor two h-bridge burnt out for now, will only code for motor one
//Adafruit_StepperMotor *motorTwo = AFMS.getStepper(200, 2);

char bytes[2];
int handshake = 0;

int moving[NUM_MOTORS];
int steps[NUM_MOTORS];
int dir[NUM_MOTORS];

void setup() {
  // start serial port at 57600
  Serial.begin(57600);
  // create with the default frequency 1.6KHz
  AFMS.begin();
  // rpm
  motorOne->setSpeed(10);

  // init
  for (int i = 0; i < NUM_MOTORS; i++) {
    moving[i] = 0;
    steps[i] = 0;
    dir[i] = 0;
  }
}

void loop() {
  for (int i = 0; i < NUM_MOTORS; i++) {
    if (moving[i] == 0) {
      motorOne->step(1, BACKWARD, SINGLE);
    }
    moving[i] = 0;
  }

  if (Serial.available()) {
    if (Serial.read() == 0xff) {
      // reads in a four element array from ChucK
      Serial.readBytes(bytes, 4);

      // bit unpacking
      int motor = byte(bytes[0]) >> 2; // 0-63
      steps[motor] = (byte(bytes[0]) << 8 | byte(bytes[1])) & 1023; // 0-1023
      dir[motor] = byte(bytes[2]); // 0-255
      int val = byte(bytes[3]); // 0-255

      // message required for "handshake" to occur
      // happens once per Arduino at the start of the ChucK serial code
      if (motor == 63 && steps[motor] == 1023 && handshake == 0) {
        Serial.write(arduinoID);
        handshake = 1;
      }
      else {
        moving[0] = 1;
        moving[1] = 1;
      }
    }
  }
}

// other steps in the library, will keep them here for now
//myMotor->step(400, FORWARD, DOUBLE);
//myMotor->step(5, BACKWARD, DOUBLE);
//myMotor->step(100, FORWARD, INTERLEAVE);
//myMotor->step(100, BACKWARD, INTERLEAVE);
//myMotor->step(2, FORWARD, MICROSTEP);
//myMotor->step(1, BACKWARD, MICROSTEP);
