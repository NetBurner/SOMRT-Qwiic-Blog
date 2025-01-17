/*
  This is a library written for the SparkFun Qwiic Keypad
  SparkFun sells these at its website: www.sparkfun.com
  Do you like this library? Help support SparkFun. Buy a board!
  https://www.sparkfun.com/products/15168

  Written by Pete Lewis @ SparkFun Electronics, 3/12/2019
  Much of the code originally came from SparkX version,
  Located here: https://github.com/sparkfunX/Qwiic_Keypad

  The Qwiic Keypad is a I2C controlled 12 button keypad

  https://github.com/sparkfun/SparkFun_Qwiic_Keypad_Arduino_Library

  Development environment specifics:
  Arduino IDE 1.8.8

  The MIT License (MIT)
  
  Copyright (c) 2024 SparkFun Electronics
  
  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following conditions: The
  above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED
  "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
  Distributed as-is; no warranty is given.
*/

#include "SparkFun_Qwiic_Keypad_Arduino_Library.h"
#include "Arduino.h"

//Constructor
KEYPAD::KEYPAD()
{

}

//Initializes the I2C connection
//Returns false if board is not detected
boolean KEYPAD::begin(TwoWire &wirePort, uint8_t deviceAddress)
{
  _i2cPort = &wirePort;
  _i2cPort->begin(); //This resets any setClock() the user may have done

  _deviceAddress = deviceAddress;

  if (isConnected() == false) return (false); //Check for sensor presence

  return (true); //We're all setup!
}

//Returns true if I2C device ack's
boolean KEYPAD::isConnected()
{
  _i2cPort->beginTransmission((uint8_t)_deviceAddress);
  if (_i2cPort->endTransmission() != 0)
    return (false); //Sensor did not ACK
  return (true);
}

//Change the I2C address of this address to newAddress
void KEYPAD::setI2CAddress(uint8_t newAddress)
{
  if (8 <= newAddress && newAddress <= 119)
  {
    writeRegister(KEYPAD_CHANGE_ADDRESS, newAddress);
    delay(100); // allow time for slave device to write new address to EEPROM

    //Once the address is changed, we need to change it in the library
    _deviceAddress = newAddress;

    if (begin(Wire, newAddress) == true)
    {
      Serial.print("Address: 0x");
      if (newAddress < 16) Serial.print("0");
      Serial.print(newAddress, HEX); //Prints out new Address value in HEX
    }
    else
    {
      Serial.println("Address Change Failure");
    }
  }
  else
  {
    Serial.println();
    Serial.println("ERROR: Address outside 8-119 range");
  }
  
}

////Returns the button at the top of the stack (aka the oldest button)
byte KEYPAD::getButton()
{
  byte button = readRegister(KEYPAD_BUTTON);
  return(button);
}

//Returns the number of milliseconds since the current button in FIFO was pressed.
uint16_t KEYPAD::getTimeSincePressed()
{
  uint16_t MSB = readRegister(KEYPAD_TIME_MSB);
  uint16_t LSB = readRegister(KEYPAD_TIME_LSB);  
  uint16_t timeSincePressed = (MSB << 8);
  timeSincePressed |= LSB;
  return timeSincePressed;
}

//Returns a string of the firmware version number
String KEYPAD::getVersion()
{
  uint8_t Major = readRegister(KEYPAD_VERSION1);
  uint8_t Minor = readRegister(KEYPAD_VERSION2);

  return("v" + String(Major) + "." + String(Minor));
}


//Reads from a given location from the Keypad
uint8_t KEYPAD::readRegister(uint8_t addr)
{
  _i2cPort->beginTransmission((uint8_t)_deviceAddress);
  _i2cPort->write(addr);
  if (_i2cPort->endTransmission() != 0)
  {
    //Serial.println("No ack!");
    return (0); //Device failed to ack
  }
  _i2cPort->requestFrom((uint8_t)_deviceAddress, (uint8_t)1);
  if (_i2cPort->available()) {
    return (_i2cPort->read());
  }
  return (0); //Device failed to respond
}


//Write a byte value to a spot in the Keypad
boolean KEYPAD::writeRegister(uint8_t addr, uint8_t val)
{
  _i2cPort->beginTransmission((uint8_t)_deviceAddress);
  _i2cPort->write(addr);
  _i2cPort->write(val);
  if (_i2cPort->endTransmission() != 0)
  {
    //Serial.println("No write ack!");
    return (false); //Device failed to ack
  }

  return (true);
}

// "commands" keypad to plug in the next button into the registerMap
// note, this actually sets the bit0 on the updateFIFO register
void KEYPAD::updateFIFO()
{
    writeRegister(KEYPAD_UPDATE_FIFO, 0x01); // set bit0, commanding keypad to update fifo
} 
