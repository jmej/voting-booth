/*********************************************************************
 requires https://github.com/earlephilhower/arduino-pico (LGPL)
 
 
 button and flash code for katherine longstreth's piece , Portland Biennial 2026

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
#include <FastLED.h>

#define NUM_LEDS 1
#define DATA_PIN 20

// Define the array of leds
CRGB leds[NUM_LEDS];

uint32_t flashedAt = 0; //timestamp for last flash
bool flash = false;
bool flashed = false;

Adafruit_USBD_MIDI usb_midi;

bool noteSent = false;
bool light = true;
float duration = 208000;
// float duration = 30000;
float startTime = 0;
bool firstRun = true; //needed to make the light start on

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
  MIDI.setHandleNoteOn(handleNoteOn);
  // If already enumerated, additional class driverr begin() e.g msc, hid, midi won't take effect until re-enumeration
  if (TinyUSBDevice.mounted()) {
    TinyUSBDevice.detach();
    delay(10);
    TinyUSBDevice.attach();
  }
    FastLED.addLeds<WS2812, DATA_PIN, GRB>(leds, NUM_LEDS).setRgbw(RgbwDefault());
    FastLED.setBrightness(255);  // Set global brightness to 100%
    delay(2000);  // If something ever goes wrong this delay will allow upload.
}

void loop() {

  if(!flash && (millis() > startTime + 73000) && !flashed){ //73000
    flash = true;
    flashed = true;
    flashedAt = millis();
    MIDI.sendNoteOn(65, 127, 1);    // Send a Note (pitch 65, velo 127 on channel 1)
  }

    //turn light off 80ms after on
  if(flash && millis() > (flashedAt + 80)){
    leds[0] = CHSV(65, 0, 0);
    flash = false;
  }

  if(flash){
    leds[0] = CHSV(65, 5, 255);
  }

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
    noteSent = true;
    light = false;
    firstRun = false;
    startTime = millis();
    flashed = false;
  }

  // if(!buttonPressed && noteSent){
  //   Serial.println(buttonPressed);
  //   MIDI.sendNoteOff(64, 0, 1);     // Stop the note
  //   noteSent = false;
  // }

  if(millis() > (startTime + duration) || firstRun) {
    light = true;
    noteSent = false;
  }else{
    light = false;
  } 
  
  if(light){
    digitalWrite(10, HIGH);
  }else{
    digitalWrite(10, LOW);
  }
  FastLED.show();
  delay(10);
}

void handleNoteOn(byte channel, byte pitch, byte velocity) {
  if(!light){
    light = true;
  }
}


