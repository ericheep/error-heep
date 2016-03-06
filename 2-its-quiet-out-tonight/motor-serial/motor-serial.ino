#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_MS_PWMServoDriver.h"

// ID number of the arduino, cooresponds to a motor
#define arduinoID 2

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield();
// Or, create it with a different I2C address (say for stacking)
// Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x61);

// Connect a stepper motor with 200 steps per revolution (1.8 degree)
// to motor port #2 (M3 and M4)
Adafruit_StepperMotor *motorOne = AFMS.getStepper(200, 1);

// motor two burnt out for now, will only code for motor one
//Adafruit_StepperMotor *motorTwo = AFMS.getStepper(200, 2);

char bytes[2];
int handshake;

void setup() {
  // start serial port at 57600
  Serial.begin(57600);
  // create with the default frequency 1.6KHz
  AFMS.begin();
  // rpm
  myMotor->setSpeed(10);  // 10 rpm
}

void loop() {
  if (Serial.available()) {
    if (Serial.read() == 0xff) {
      // reads in a four element array from ChucK
      Serial.readBytes(bytes, 4);

      // bit unpacking
      int motor = byte(bytes[0]) >> 2; // 0-63
      int rotations = (byte(bytes[0]) << 8 | byte(bytes[1])) & 1023; // 0-1023
      int sat = byte(bytes[2]); // 0-255
      int val = byte(bytes[3]); // 0-255

      // message required for "handshake" to occur
      // happens once per Arduino at the start of the ChucK serial code
      if (motor == 63 && rotations == 1023 && handshake == 0) {
        Serial.write(arduinoID);
        handshake = 1;
      }
      else {
        Tlc.update();
      }
    }
  }
  //Serial.println("Single coil steps");
  //myMotor->step(1, FORWARD, SINGLE);
  //myMotor->step(1, BACKWARD, SINGLE);

  //Serial.println("Double coil steps");
  //myMotor->step(400, FORWARD, DOUBLE);
  //myMotor->step(5, BACKWARD, DOUBLE);

  //Serial.println("Interleave coil steps");
  //myMotor->step(100, FORWARD, INTERLEAVE);
  //myMotor->step(100, BACKWARD, INTERLEAVE);

  //Serial.println("Microstep steps");
  //myMotor->step(2, FORWARD, MICROSTEP);
  //myMotor->step(1, BACKWARD, MICROSTEP);
}
