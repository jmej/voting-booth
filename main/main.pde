
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
int wordIndex = 0;

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
 // "Bound", "Free", "Strong", "Light", "Direct", "Indirect", "Sustained", "Quick",
  "Sensing & Feeling", "Intending & Progressing", "Thinking & Intuiting", "Attending & Deciding",
  "Sensing & Intuiting", "Intending & Deciding", "Feeling & Thinking", "Progressing & Attending",
  "Sensing & Thinking", "Intending & Attending"
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
  labanX = 0;
  labanY = 200; //how far over the graph will appear from the left
  labanWidth = 400;
  labanHeight = 400;
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
  if(millis() > startTime + 165000 && millis() < startTime + 169000){
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
      translate(labanX + labanWidth / 2, labanY + labanHeight / 2);
      rotate(HALF_PI); // 45 degrees clockwise
      translate(-(labanX + labanWidth / 2), -(labanY + labanHeight / 2));
      drawLabanDiagram(labanX, labanY, labanWidth, labanHeight);
      drawWaves();
      popMatrix();
  
      waveOffset1 += 0.34;
      waveOffset2 += 0.33;
      waveOffset3 += 0.35;
      spying = 2;

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

void drawWaves() {
  float cx = labanX + labanWidth / 2;
  float cy = labanY + labanHeight / 2;

  int steps = 80;
  float noiseScale = 0.5;
  float amp = 60; // how far the wave deviates from the axis

  noFill();

  // --- Vertical axis (Light/Strong) ---
  stroke(255, 255, 255, 160);
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = (float) i / steps;
    float axisY = map(t, 0, 1, cy - labanHeight * 0.46, cy + labanHeight * 0.46);
    float n = noise(t * noiseScale, waveOffset1) - 0.5;
    float x = cx + n * amp * 2;
    strokeWeight(max(0.1, map(noise(t * 0.3, waveOffset1 * 0.5), 0, 1, 0.5, 6)));
    vertex(x, axisY);
  }
  endShape();

  // --- Horizontal axis (Free/Bound) ---
  stroke(255, 255, 255, 160);
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = (float) i / steps;
    float axisX = map(t, 0, 1, cx - labanWidth * 0.47, cx + labanWidth * 0.47);
    float n = noise(t * noiseScale, waveOffset2) - 0.5;
    float y = cy + n * amp * 2;
    strokeWeight(max(0.1, map(noise(t * 0.3, waveOffset2 * 0.5), 0, 1, 0.5, 6)));
    vertex(axisX, y);
  }
  endShape();

  // --- Diagonal axis (Indirect/Direct) ---
  // Full axis: from back end to arrow end
  float dxFull = labanWidth  * 0.27 + labanWidth  * 0.086;
  float dyFull = -labanHeight * 0.14 - labanHeight * 0.044;
  float axisLen = sqrt(dxFull * dxFull + dyFull * dyFull);
  float ux = dxFull / axisLen;  // unit vector along axis
  float uy = dyFull / axisLen;
  float px = -uy;               // perpendicular
  float py =  ux;

  float startX = cx - labanWidth  * 0.086;
  float startY = cy + labanHeight * 0.044;

  stroke(255, 255, 255, 160);
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = (float) i / steps;
    float ax = startX + ux * axisLen * t;
    float ay = startY + uy * axisLen * t;
    float n = noise(t * noiseScale, waveOffset3) - 0.5;
    float wx = ax + px * n * amp * 2;
    float wy = ay + py * n * amp * 2;
    strokeWeight(max(0.1, map(noise(t * 0.3, waveOffset3 * 0.5), 0, 1, 0.5, 6)));
    vertex(wx, wy);
  }
  endShape();
}

void drawLabanDiagram(float x, float y, float w, float h) {
  textSize(25);
  if (frameCount % int(random(30, 60)) == 0 ) { 
    wordIndex = int(random(words.length));
  }
  text(words[wordIndex], x+5, y);
  float cx = x + w / 2;
  float cy = y + h / 2;

  color g = color(0, 220, 80);

  float vLen  = h * 0.46;
  float hLen  = w * 0.47;
  float dxEnd = w * 0.27;
  float dyEnd = -h * 0.14;

  float labelSize   = h * 0.034;
  float qualitySize = h * 0.038;

  strokeWeight(2);
  stroke(g);

  line(cx, cy - vLen, cx, cy + vLen);
  drawArrow(cx, cy - vLen, cx, cy - vLen - 1, g);
  drawArrow(cx, cy + vLen, cx, cy + vLen + 1, g);

  line(cx - hLen, cy, cx + hLen, cy);
  drawArrow(cx - hLen, cy, cx - hLen - 1, cy, g);
  drawArrow(cx + hLen, cy, cx + hLen + 1, cy, g);

  line(cx, cy, cx + dxEnd, cy + dyEnd);
  line(cx, cy, cx - w * 0.086, cy + h * 0.044);
  drawArrow(cx + dxEnd, cy + dyEnd, cx + dxEnd + 1, cy + dyEnd - 1, g);

  fill(g);
  noStroke();
  textAlign(CENTER, CENTER);

  textSize(labelSize);
  text("Light",    cx,                           cy - vLen - labelSize * 1.4);
  text("Strong",   cx,                           cy + vLen + labelSize * 1.4);
  text("Free",     cx - hLen - labelSize * 2.2,  cy);
  text("Bound",    cx + hLen + labelSize * 2.2,  cy);
  text("Indirect", cx + w * 0.11,                cy - h * 0.22);
  text("Direct",   cx + dxEnd + labelSize * 2.8, cy + dyEnd);

  textSize(qualitySize);
  text("(Space)",  cx + w * 0.17, cy - h * 0.13);
  text("(Flow)",   cx + w * 0.22, cy + h * 0.04);

  textSize(labelSize);
  text("Sustained", cx - w * 0.16,  cy + h * 0.12);
  text("Quick",     cx + w * 0.086, cy + h * 0.12);

  stroke(g);
  strokeWeight(2);
  float dashY = cy + h * 0.145;
  line(cx - w * 0.205, dashY, cx - w * 0.115, dashY);
  line(cx + w * 0.054, dashY, cx + w * 0.126, dashY);

  noStroke();
  fill(g);
  textSize(qualitySize);
  text("(Time)",   cx - w * 0.145, cy + h * 0.20);
  text("(Weight)", cx,             cy + h * 0.34);
}

void drawArrow(float x1, float y1, float x2, float y2, color c) {
  stroke(c);
  fill(c);
  float angle     = atan2(y2 - y1, x2 - x1);
  float arrowSize = 9;
  pushMatrix();
  translate(x2, y2);
  rotate(angle);
  triangle(0, 0, -arrowSize, -arrowSize * 0.5, -arrowSize, arrowSize * 0.5);
  popMatrix();
}
