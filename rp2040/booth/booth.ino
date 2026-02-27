/*********************************************************************
 requires https://github.com/earlephilhower/arduino-pico (LGPL)
 
 
 button code for katherine

 jesse mejia 2026

 Adafruit invests time and resources providing this open source code,
 please support Adafruit and open-source hardware by purchasing
 products from Adafruit!

 MIT license, check LICENSE for more information
 Copyright (c) 2019 Ha Thach for Adafruit Industries
 All text above, and the splash screen below must be included in
 any redistribution
*********************************************************************/

/* This sketch is enumerated as USB MIDI device. 
 * Following library is required
 * - MIDI Library by Forty Seven Effects
 *   https://github.com/FortySevenEffects/arduino_midi_library
 */

#include <Arduino.h>
#include <Adafruit_TinyUSB.h>
#include <MIDI.h>

Adafruit_USBD_MIDI usb_midi;

bool noteSent = false;
// Create a new instance of the Arduino MIDI Library,
// and attach usb_midi as the transport.
MIDI_CREATE_INSTANCE(Adafruit_USBD_MIDI, usb_midi, MIDI);

void setup() {
  // Manual begin() is required on core without built-in support e.g. mbed rp2040
  if (!TinyUSBDevice.isInitialized()) {
    TinyUSBDevice.begin(0);
  }

  Serial.begin(115200);

  pinMode(10, OUTPUT);
  pinMode(13, INPUT);

  usb_midi.setStringDescriptor("TinyUSB MIDI");

  // Initialize MIDI, and listen to all MIDI channels
  // This will also call usb_midi's begin()
  MIDI.begin(MIDI_CHANNEL_OMNI);

  // If already enumerated, additional class driverr begin() e.g msc, hid, midi won't take effect until re-enumeration
  if (TinyUSBDevice.mounted()) {
    TinyUSBDevice.detach();
    delay(10);
    TinyUSBDevice.attach();
  }

}

void loop() {
  #ifdef TINYUSB_NEED_POLLING_TASK
  // Manual call tud_task since it isn't called by Core's background
  TinyUSBDevice.task();
  #endif

  // not enumerated()/mounted() yet: nothing to do
  if (!TinyUSBDevice.mounted()) {
    return;
  }

  bool buttonPressed = digitalRead(13);
  if(buttonPressed && !noteSent){
    Serial.println(buttonPressed);
    MIDI.sendNoteOn(64, 127, 1);    // Send a Note (pitch 42, velo 127 on channel 1)
    digitalWrite(10, LOW);
    noteSent = true;
  }

  if(!buttonPressed && noteSent){
    Serial.println(buttonPressed);
    MIDI.sendNoteOff(64, 0, 1);     // Stop the note
    digitalWrite(10, HIGH);
    noteSent = false;
  }
  
  delay(10);
}


