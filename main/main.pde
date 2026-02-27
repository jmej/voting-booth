import processing.video.*;
import themidibus.*;
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;

MidiBus myBus; // The MidiBus
MidiReceiver receiver = new MidiReceiver();

Movie video;
float duration;
float ellapsed;
float startTime;
float endTime;
boolean playing = false;
boolean noteSent = false;

void setup(){
  //fullScreen(2);
  size(800, 800);
  background(0);
  video = new Movie(this, "SC1TK2.mov");
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
  image(video, 0, 0, width, height);
  if(millis() > endTime){
    playing = false;
  }else{
    playing = true;
    noteSent = false;
  }
  
  //if(!noteSent && !playing){
  //  myBus.sendNoteOn(1, 64, 127);
  //  noteSent = true;
  //}
  
  //if(noteSent && playing){
  //  noteSent = false;
  //}
  println("millis: "+millis());
  println("duration "+duration*1000);
  println("start "+startTime);
  println("end "+endTime);
  println("playing: "+playing);
  
}

void keyPressed(){
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
    if(!playing){
      video.jump(0);
      video.play();
      duration = video.duration()*1000;
      startTime = millis();
      endTime = startTime + duration;
      playing = true;
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
