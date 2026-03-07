
//Code by Jesse Mejia 2026 for Katherine Longstreth
//Camera shutter and flash combined by montclairguy -- https://freesound.org/s/353044/ -- License: Creative Commons 0


import processing.video.*;
import themidibus.*;
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;
import processing.sound.*;

SoundFile flash;
boolean playFlash = false;
boolean flashPlaying = false;

MidiBus myBus; // The MidiBus
MidiReceiver receiver = new MidiReceiver();

PFont mono;

int spying = 0; //0 nothing, 1 audio scan, 2 visual scan

//fake audio vars
  float time = 0;
  float ampTime = 0;
  float currentEnvelope = 0;
  boolean isPausing = false;
  float pauseTimer = 0;


static String[] words = {
    "vibrant", "melancholic", "radiant", "mysterious", "serene",
    "boisterous", "fragile", "resilient", "ancient", "modern",
    "gleaming", "shadowy", "luminous", "whimsical", "graceful",
    "rugged", "sleek", "brilliant", "dull", "majestic",
    "nimble", "clumsy", "elegant", "fierce", "gentle",
    "stormy", "tranquil", "curious", "fearless", "timid",
    "bold", "cautious", "lavish", "meager", "ornate",
    "plain", "charming", "awkward", "loyal", "fickle",
    "dusky", "crisp", "murky", "pristine", "tattered",
    "shimmering", "vast", "compact", "soaring", "sunken",
    "fragrant", "pungent", "savory", "bitter", "sweet",
    "icy", "scorching", "velvety", "rough", "spacious",
    "cramped", "jubilant", "somber", "zealous", "apathetic",
    "intricate", "simple", "dynamic", "static", "harmonious",
    "discordant", "playful", "stern", "vivid", "faded",
    "robust", "delicate", "hearty", "hollow", "glorious",
    "dreary", "sparkling", "fluffy", "dense", "swift",
    "sluggish", "polished", "gritty", "quaint", "modernistic",
    "colorful", "monochrome", "ethereal", "radiant", "enigmatic",
    "brisk", "dreary", "opulent", "subtle", "tenacious"
};

Movie video;
float duration;
float ellapsed;
float startTime;
float endTime;
boolean playing = false;
boolean noteSent = false;

int fontX;
int fontY;

void setup(){
  fullScreen(P2D, 2);
  //size(800, 800);
  flash = new SoundFile(this, "353044__montclairguy__camera-shutter-and-flash-combined.wav");
  fontX = width/8;
  fontY = height - height/8;
  background(0);
  mono = loadFont("CourierNewPS-BoldMT-12.vlw");
  PFont.list();
  textSize(6);
  textFont(mono);
  fill(0, 255, 0); //green color for text
  video = new Movie(this, "insideVideo_all_v8_upres_90.mov");
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(receiver, "TinyUSB MIDI", "TinyUSB MIDI"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  startTime = millis();
  endTime = startTime + duration;
}

void movieEvent(Movie m) {
  m.read();
}


void draw(){
  //if (movie.available() == true) {
  //  movie.read(); 
  //}
  background(0);
  image(video, 0, 0, width, height);
  if(millis() > endTime){
    playing = false;
  }else{
    playing = true;
    noteSent = false;
  }
  
  switch(spying){
    case 0:
      //draw nothing
      break;
    case 1: 
      pushMatrix();
      translate(fontX, fontY - 50);
      fakeAudio();
      popMatrix();
      textSize(12);
      text("analyzing audio: "+random(-1, 1), fontX, fontY);
      break;
    case 2:
      spying = 2;
      textSize(12);
      text("visual analysis: "+words[int(random(100))], fontX, fontY);
      break;
  }
  if(playFlash && !flashPlaying){
    flash.play();
    flashPlaying = true;
  }
  //println("spying: "+spying);
  
  //if(!noteSent && !playing){
  //  myBus.sendNoteOn(1, 64, 127);
  //  noteSent = true;
  //}
  
  //if(noteSent && playing){
  //  noteSent = false;
  //}
  //println("millis: "+millis());
  //println("duration "+duration*1000);
  //println("start "+startTime);
  //println("end "+endTime);
  //println("playing: "+playing);
  
}


void fakeAudio() {

  float widthMult = 0.5;
  float heightMult = 0.02;

  //breath pauses
  if (!isPausing && random(1) < 0.002) {
    isPausing = true;
    pauseTimer = random(20, 60);
  }

  if (isPausing) {
    pauseTimer--;
    if (pauseTimer <= 0) {
      isPausing = false;
    }
  }
  float targetEnvelope = map(noise(ampTime), 0, 1, 0.2, 1.3);

  // Smooth attack / decay
  currentEnvelope = lerp(currentEnvelope, targetEnvelope, 0.08);

  if (isPausing) {
    currentEnvelope *= 0.1;
  }

  // consonants
  float burst = 0;
  if (random(1) < 0.4) {
    burst = random(0.5, 1.2);
  }

  float finalAmp = currentEnvelope + burst;

  //waveform
  for (int x = 0; x < width * widthMult; x += 2) {
    float phase = map(x, 0, width * widthMult, 0, 4 * PI);
    float sineWave = sin(phase - time) * (height * heightMult);
    float texture = (noise(x * 0.05, time) - 0.5) * (height * heightMult);
    float y = (sineWave + texture) * finalAmp;
    float asym = noise(x * 0.02, time * 0.5) * 10;
    stroke(0,255,0);
    line(x, -abs(y) - asym, x, abs(y));
  }

  time += 0.8;    // fast vibration
  ampTime += 10; // slow syllable pacing
}

void keyPressed(){
  switch(key){
    case 'q':
      spying = 0;
      break;
    case 'w':
      spying = 1;
      break;
    case 'e':
      spying = 2;
      break;
  }
  
  video.jump(0);
  video.play();
}

public class MidiReceiver{
  void noteOn(int channel, int pitch, int velocity) {
    // Receive a noteOn
    println();
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
    if(!playing && pitch == 64){
      video.jump(0);
      video.play();
      duration = video.duration()*1000;
      startTime = millis();
      endTime = startTime + duration;
      playing = true;
      flashPlaying = false;
      playFlash = false;
    }
    if(pitch == 65){
      playFlash = true;
    }
  }

  void noteOff(int channel, int pitch, int velocity) {
    // Receive a noteOff
    println();
    println("Note Off:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
  }
  
  void controllerChange(int channel, int number, int value) {
    // Receive a controllerChange
    println();
    println("Controller Change:");
    println("--------");
    println("Channel:"+channel);
    println("Number:"+number);
    println("Value:"+value);
  }
}
