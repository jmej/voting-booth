
//Code by Jesse Mejia 2026 for Katherine Longstreth
//Camera shutter and flash combined by montclairguy -- https://freesound.org/s/353044/ -- License: Creative Commons 0


import processing.video.*;
import themidibus.*;
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;
import processing.sound.*;

float oscTime = 0;

float labanX, labanY, labanWidth, labanHeight;

float waveOffset1 = 0;
float waveOffset2 = 0;
float waveOffset3 = 0;

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


String[] words = {
  "Weight", "Time", "Space", "Flow",
  "Bound", "Free", "Strong", "Light", "Direct", "Indirect", "Sustained", "Quick",
  "Sensing", "Feeling", "Intending", "Progressing", "Thinking", "Intuiting", "Attending", "Deciding",
  "Sensing & Feeling", "Intending & Progressing", "Thinking & Intuiting", "Attending & Deciding",
  "Sensing & Intuiting", "Intending & Deciding", "Feeling & Thinking", "Progressing & Attending",
  "Sensing & Thinking", "Intending & Attending", "Feeling & Thinking", "Progressing & Deciding",
  "Dream State", "Awake State", "Rhythm State", "Remote State", "Mobile State", "Stable State",
  "Passion Drive", "Spell Drive", "Vision Drive", "Active Drive"
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
int b;
void setup(){
 fullScreen(P3D);
 b = b+1;
 b = b % 5;
  //size(800, 800);
  background(0);
  labanX = 100;
  labanY = 80;
  labanWidth = 500;
  labanHeight = 440;
  video = new Movie(this, "final_inside_video_all_v13c_upres_90° (1080p).mp4");
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(receiver, "Pico", "Pico"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  flash = new SoundFile(this, "flash.wav");
  fontX = width/8;
  fontY = height - height/8;
  background(0);
  mono = loadFont("CourierNewPS-BoldMT-12.vlw");
  PFont.list();
  textSize(6);
  textFont(mono);
  fill(0, 255, 0); //green color for text
  startTime = millis();
  endTime = startTime + duration;
}

void movieEvent(Movie m) {
  m.read();
}


void draw(){
  noCursor();
  flash.amp(0.2);
  background(0);
  //if (movie.available() == true) {
  //  movie.read(); 
  //}
  
  if(millis() > endTime){
    playing = false;
  }else{
    image(video, 0, 0, width, height);
    playing = true;
    noteSent = false;
  }
  spying = 0;
  //fakeaudio scan 
  if(millis() > startTime + 56000 && millis() < startTime + 64000){
    spying = 1;
  }
  
  //fakevisual scan 
  if(millis() > startTime + 165000 && millis() < startTime + 168000){
    spying = 2;
  }
  
  
  switch(spying){
    case 0:
      //draw nothing
      break;
    case 1:
      pushMatrix();
      rotate(HALF_PI); //rotate 90 degrees
      translate(width/12, -height/4); 
      fakeAudio(0, 0, width/2, height/6 );
      textSize(20);
      text("analyzing audio: "+random(-1, 1),0,0);
      popMatrix();
      break;
    case 2:
      pushMatrix();
      rotate(HALF_PI); //rotate 90 degrees
      translate(width/12, -height/4); 
      spying = 2;
      textSize(20);
      text("visual analysis: "+words[int(random(100))], 0, 0);
      popMatrix();
      break;
  }
  if(playFlash && !flashPlaying){
    flash.play();
    flashPlaying = true;
  }

  
}


void fakeAudio(float x, float y, float w, float h) {
  strokeWeight(2);
  noFill();

  float topY = y + h * 0.35;
  float bottomY = y + h * 0.65;

  // --- TOP WAVE ---
  stroke(0, 255, 0);
  beginShape();
  for (int i = 0; i < w; i++) {

    float burst = noise(oscTime * 3) * 1.8;
    float n = noise(i * 0.015, oscTime * 4);

    float yy =
      topY +
      sin(i * 0.035 + oscTime * 6) * (h * 0.12) * burst +
      sin(i * 0.08 - oscTime * 8) * (h * 0.05) * burst +
      map(n, 0, 1, -h * 0.12, h * 0.12) * burst;

    vertex(x + i, yy);
  }
  endShape();

  // --- BOTTOM WAVE ---
  stroke(0, 255, 0);
  beginShape();
  for (int i = 0; i < w; i++) {

    float burst = noise(oscTime * 3 + 50) * 1.8;
    float n = noise(i * 0.015, oscTime * 5 + 200);

    float yy =
      bottomY +
      sin(i * 0.038 + oscTime * 6.5) * (h * 0.12) * burst +
      sin(i * 0.085 - oscTime * 8.5) * (h * 0.05) * burst +
      map(n, 0, 1, -h * 0.12, h * 0.12) * burst;

    vertex(x + i, yy);
  }
  endShape();

  oscTime += 0.09;
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
  if(!playing){
    video.jump(0);
    video.play();
    startTime = millis();
    endTime = startTime + duration;
    flashPlaying = true;
    playFlash = false;
  }
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
