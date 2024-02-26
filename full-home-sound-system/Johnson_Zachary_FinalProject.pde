import guru.ttslib.*;

import beads.*;
import java.util.*;
import controlP5.*;

//to use text to speech functionality, copy text_to_speech.pde from this sketch to yours
//example usage below

//IMPORTANT (notice from text_to_speech.pde):
//to use this you must import 'ttslib' into Processing, as this code uses the included FreeTTS library
//e.g. from the Menu Bar select Sketch -> Import Library... -> ttslib

TextToSpeechMaker ttsMaker; 
ControlP5 p5;

SamplePlayer dogCollar;
SamplePlayer dogBark; 
SamplePlayer walking;
SamplePlayer schoolBus;
SamplePlayer schoolBell;
SamplePlayer hammer;
SamplePlayer delivery;
SamplePlayer appliance;
SamplePlayer worknotif;

BiquadFilter filter;

WavePlayer wp;

Glide tempGlide;
Glide masterGlide; 

Gain tempGain;
Gain masterGain;


//<import statements here>

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON1 = "events.json";
String eventDataJSON2 = "events.json";
String eventDataJSON3 = "events.json";

NotificationServer server;
ArrayList<Notification> notifications;

Example example;

//Comparator<Notification> comparator;
//PriorityQueue<Notification> queue;
PriorityQueue<Notification> q2;

void setup() {
  size(600,600);
  
  NotificationComparator priorityComp = new NotificationComparator();
  
  q2 = new PriorityQueue<Notification>(10, priorityComp);
  
  //comparator = new NotificationComparator();
  //queue = new PriorityQueue<Notification>(10, comparator);
  
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  p5 = new ControlP5(this);
  dogCollar = getSamplePlayer("dogcollar.wav");
  dogBark = getSamplePlayer("dogout.wav");
  walking = getSamplePlayer("personmove.wav");
  schoolBus = getSamplePlayer("schoolbus.wav");
  schoolBell = getSamplePlayer("schoolbell.wav");
  hammer = getSamplePlayer("contractor.wav");
  delivery = getSamplePlayer("delivery.wav");
  worknotif = getSamplePlayer("worknotif.wav");
  appliance = getSamplePlayer("appliance.wav");
  appliance.pause(true);
  worknotif.pause(true);
  dogCollar.pause(true);
  dogBark.pause(true);
  walking.pause(true);
  schoolBus.pause(true);
  schoolBell.pause(true);
  hammer.pause(true);
  delivery.pause(true);
  masterGlide = new Glide(ac, 1.0, 1);
  masterGain  = new Gain(ac, 2, masterGlide);
  filter = new BiquadFilter(ac, BiquadFilter.LP, new Glide(ac, 1500.0, 500), 0.5f);
  masterGain.addInput(dogCollar);
  filter.addInput(dogBark);
  masterGain.addInput(filter);
  masterGain.addInput(worknotif);
  masterGain.addInput(appliance);
  masterGain.addInput(walking);
  masterGain.addInput(schoolBus);
  masterGain.addInput(schoolBell);
  masterGain.addInput(hammer);
  masterGain.addInput(delivery);
  WavePlayer wp = new WavePlayer(ac, 440.f, Buffer.SINE);
  wp.pause(true);
  masterGain.addInput(wp);
  ac.out.addInput(masterGain);
  p5.addButton("petOutside")
    .setPosition(40, 40)
    .setSize(80,80);
  p5.addButton("petInside")
    .setPosition(120, 40)
    .setSize(80,80);
  p5.addButton("delivery")
    .setPosition(120, 200)
    .setSize(80,80);
  p5.addButton("personMove")
    .setPosition(200, 40)
    .setSize(80,80);
  p5.addButton("childLeaveSchool")
    .setPosition(200, 120)
    .setSize(80,80);
  p5.addButton("childAtSchool")
    .setPosition(200, 200)
    .setSize(80,80);
  p5.addButton("appliance")
    .setPosition(40, 200)
    .setSize(80,80);
  p5.addButton("contractor")
    .setPosition(120, 120)
    .setSize(80,80);
  p5.addButton("worknotif")
    .setPosition(40, 120)
    .setSize(80,80);
  p5.addSlider("gainLevel")
    .setPosition(300, 300)
    .setSize(160, 40)
    .setRange(0,1)
    .setValue(0.9)
    .setLabel("Volume");
  ac.start();
  
  //this will create WAV files in your data directory from input speech 
  //which you will then need to hook up to SamplePlayer Beads
  ttsMaker = new TextToSpeechMaker();
  
  String exampleSpeech = "hI";
  
  ttsExamplePlayback(exampleSpeech); //see ttsExamplePlayback below for usage
  
  //START NotificationServer setup
  server = new NotificationServer();
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  example = new Example();
  server.addListener(example);
  
  //loading the event stream, which also starts the timer serving events
  server.loadEventStream(eventDataJSON1);
  
  //END NotificationServer setup
  
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()  
}

void keyPressed() {
  //example of stopping the current event stream and loading the second one
  if (key == RETURN || key == ENTER) {
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON2);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  }
    
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class Example implements NotificationListener {
  
  public Example() {
    //setup here
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + " ms");
    
    String debugOutput = ">>> ";
    ttsExamplePlayback(notification.getType().toString());
    switch (notification.getType()) {
      case Work:
        debugOutput += "notification from work";
        break;
      case personMove:
        debugOutput += "Person moved at home: ";
        break;
      case ChildLeaveSchool:
        debugOutput += "Child left school: ";
        break;
      case delivery:
        debugOutput += "Package Delivered ";
        break;
      case ChildAtSchool:
        debugOutput += "Child at School";
        break;
      case contractor:
        debugOutput += "Contractor working..";
        break;
      case Appliance:
        debugOutput += "Appliance";
        break;
      case DogIn:
        debugOutput += "Dog Inside";
        break;
      case DogOut:
        debugOutput += "Dog in Backyard";
        break;
    }
    debugOutput += notification.toString();
    //debugOutput += notification.getLocation() + ", " + notification.getTag();
    
    println(debugOutput);
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}

public void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}

public void gainLevel(float value) {
  masterGlide.setValue(value);
  println(masterGlide.getValue());
}
public void petOutside() {
  dogBark.setToLoopStart();
  dogBark.pause(false);
}
public void petInside() {
  dogCollar.setToLoopStart();
  dogCollar.pause(false);
}
public void delivery() {
  delivery.setToLoopStart();
  delivery.pause(false);
}
public void personMove() {
  walking.setToLoopStart();
  walking.pause(false);
}
public void childLeaveSchool() {
  schoolBell.setToLoopStart();
  schoolBell.pause(false);
}
public void childAtSchool() {
  schoolBus.setToLoopStart();
  schoolBus.pause(false);
}
public void contractor() {
  hammer.setToLoopStart();
  hammer.pause(false);
}
public void appliance() {
  appliance.setToLoopStart();
  appliance.pause(false);
}
public void worknotif() {
  worknotif.setToLoopStart();
  worknotif.pause(false);
}
