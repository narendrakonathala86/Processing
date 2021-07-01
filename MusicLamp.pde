import processing.serial.*;
import java.util.LinkedList;
import java.util.Queue;
import java.time.*;

Serial arduinoPort;
final String portStart = "/dev/cu.usbmodem";

Queue<NoteData> queue = new LinkedList();   // Used to store the note frequncies using 1st in 1st out method


final int numOfNotes = 50;
Note[] notes = new Note[numOfNotes];
NoteData activeNode = null;                 //Used to change the background color
int offset = 200;                             //Used to centered the frequencies of notes
ZonedDateTime pastEventTime;                //To calculate idle time of Arduino
String keyNote[] = {"Do", "Re", "Mi", "Fa", "Sol", "La", "Ti", "Do#"};
boolean badPort = false;

void setup() {
  //fullScreen();
  size(1080, 720);
  background(0);
  
  arduinoPort = getPort();
  
  if (arduinoPort == null) {                //Error handling - No Port found
      translate(width/2, height/2);
      textAlign(CENTER);
      textSize(32);
      text("Cannot establist connection with Arduino", 0, 0);
      textSize(24);
      text("Please check connection and try again", 0, 50);
      noLoop();
      badPort = true;
      return;
  }

  for (int i = offset; i < width-offset; i++) {
    queue.add(new NoteData());              //Initiate an empty queue for the length of the graph
  }

  for (int i = 0; i < numOfNotes; i++) {    //Notes - Reused for performance
    Note note = new Note();
    notes[i] = note;
  }

}


void draw() {
  if (badPort == true) { return ;}
  background(0);

  if (pastEventTime == null || isArduinoIdle(pastEventTime)) {  
    pushMatrix();
    fill(125);
    translate(width/2, height/2);
    textAlign(CENTER);
    textSize(32);
    text("Arduino is idle", 0, 0);        //Notify user the idle case - when no data is transmitted
    textSize(16);
    text("Perform some interactions to transmit data", 0, 50);
    popMatrix();
    return;                                
  }

  readSerialData(arduinoPort);             //Reads data to a queue

  drawBackground();
  drawFrequencyGraph();
  drawAxis();
}



void drawFrequencyGraph() {               //Draw frequencies with color codes
  int i = offset;                         //starts from offset to the length of the queue

  for (NoteData element : queue) {
    pushMatrix();
    translate(0, height/2);

    if (element.frequency == 0) { 
      strokeWeight(1);
      stroke(element.noteColor, 50);
      line(i, 0, i, 1);                   //Flat Line when no sound is made
    } else {
      float val = map(element.frequency, 0, 1200, 0, height / 4);  //Map Hz to Height
      strokeWeight(2);
      stroke(element.noteColor);
      line(i, val, i, -1 * val);

      fill(255);                          //In addition to color code display the note on 
      textAlign(CENTER);                  //the bottom for better data representation
      textSize(8);
      text( keyNote[element.index] , i, height / 4 + 16);
    }
    popMatrix();
    i++;
  }
}

void drawBackground() {
  for (int j = 0; j < numOfNotes; j++) {
    if (activeNode == null) {
      notes[j].draw(-1, -1);
    }else {                             //Highlight the note which is active in the background
      notes[j].draw(activeNode.index, activeNode.noteColor); 
    }
  }

  pushMatrix();                         //Block middle area for Graph
  translate(0, height/2);
  noStroke();
  fill(0);
  rect(offset - 50, -1 * height / 4, width - 2 * (offset - 50), height / 2);
  popMatrix();
}

void drawAxis() {                       //Frequencies - Y Axis
    for (int i = -1200 ; i <= 1200; i = i + 200) {  
      if (i == 0) continue;
      pushMatrix();
      textAlign(CENTER);
      textSize(8);
      translate(0 ,height/2);
      stroke(0);
      strokeWeight(2);
      int y = (int) map(i, -1200, 1200, -1 * height / 4, height / 4);
      line(offset, y, width - offset, y);
      popMatrix();
    }
}

void serialEvent(Serial p) {            //Used for calculating idle time of Arduino
  pastEventTime = ZonedDateTime.now();  
} 

boolean isArduinoIdle(ZonedDateTime oldTime) {
  Duration duration = Duration.between(oldTime, ZonedDateTime.now());
  if (duration.getSeconds() > 10) {    //Idle timeout set to 10 sec...
    return true;                       //Returns idle if no data is transmitted for 10Secs 
  }
  return false;
}

void readSerialData(Serial port){      //Function to read each set of Serial data trasmitted from Arduino

  String inBuffer = port.readStringUntil('#');  
  NoteData data = null;
    if (inBuffer != null) {
      data = new NoteData(inBuffer.trim());
      activeNode = data;
    } else {
      data = new NoteData();          //No sound
    }
    queue.poll();                     //Removes the 1st element from queue
    queue.add(data);                  //Add new data to the end. 
}


Serial getPort() {                    //Gets the Arduino port and creates a listener
  String[] portList = Serial.list();
  for (int i = 0; i < portList.length; i++) {
    if (portList[i].startsWith(portStart)) { 
      return new Serial(this, portList[i], 9600);
    }
  }
  return null;
}

class NoteData {                      //Data structure to hold each note data recieved from Arduino
  public color noteColor;
  public int frequency;
  public int interval;
  public int index;

  public NoteData() {               //Empty Note -  default constructor
    noteColor = color(255);         //When no music or data trasmitted
  }

  public NoteData(String rawText) { //override constructor
    try {
      String arr[] = rawText.split("\\n");
      this.noteColor = color(Integer.parseInt(arr[0].trim()), Integer.parseInt(arr[1].trim()), Integer.parseInt(arr[2].trim()));
      this.frequency = Integer.parseInt(arr[3].trim());
      this.interval = Integer.parseInt(arr[4].trim());
      this.index = Integer.parseInt(arr[5].trim());
    } catch (Exception e) {
      println(e);
    }
  }
}

public class Note {                  //Data to represent background
    public float x;
    public float y;
    int size = 0;
    float distance;
    float angle = 0;
    final float boundRadius = width /2;
    int rindex = (int) (Math.random() * 8);
    float inclination = (float) Math.random() * TWO_PI / 20;
    float scale = 0.1;

    int type = (int) (Math.random() * 2 + 1);
    int type1 = (int) (Math.random() * 3 + 1);

    public Note() {                 //Random point on the canvas
        angle = (float) Math.random() * TWO_PI;
        distance = (float) Math.sqrt(Math.random()) * boundRadius + 200; 
        setX(); setY();
    }

    private void setX() {
        x =  (float) (distance * cos( (float) angle));
    }

    private void setY() {
        y = (float) (distance * sin( (float) angle));
    }

    private void move() {            //For 3D feel
        distance = distance + 2;
        size++;
        if (distance > boundRadius + 200) {
          distance = (float) Math.sqrt(Math.random()) * boundRadius+ 200; 
          scale = 0.1;
        }
        size = (int) ((distance) * 0.04);
        scale = distance / 1000;

        if ( size < 4 ) { size = 4 ;};
        setX(); setY();
    }

    void draw(int index, color noteColor) {
        move();                                           //Move the object towards the circumference
        pushMatrix();                                     //This function draws random notes. 
        fill(noteColor);
        translate(width/2, height/2);
        scale(scale);
        rotate(inclination);
        noStroke();

        for (int i = 0; i < type1; i++) {
          rect(x + 20 * i, y - i * 5, 5, 25);               //# string
          ellipse(x + 20 * i, y - i * 5 + 25,  15, 10);
          
          if (type > 1 && i == type1 -1) {
            strokeWeight(5);
            stroke(noteColor);
            line(x  + 5, y, x + 20 * (i), y  - 5 * (i +1));  //With Bar
          }
        }
        popMatrix();
    }



}