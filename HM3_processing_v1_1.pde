import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress sender;
NetAddress receiver;

int X_AXIS = 2;
int Y_AXIS = 1;



PFont customFont;
color backgroundColor;
color b1, b2;


//Play Button param
int circleX, circleY;  // Position of circle button
int circleSize = 77;   // Diameter of circle
color ActivePlayBtn, PassivePlayBtn, BtnPlayColor;
boolean circleOver = false;
int PlayButtonState = 0;

//MODES param
color activeColorMode, passiveColorMode;
int ModeState = 0;
int rectWidth = 150; // Width of rectangle
int rectHeight = 40; // Height of rectangle

int rectX1, rectY1; // Position of rectangle 1
color rectColor1; // Color of rectangle 1
boolean rectOver1 = false; // Mouse over rectangle 1

int rectX2, rectY2; // Position of rectangle 2
color rectColor2; // Color of rectangle 2
boolean rectOver2 = false; // Mouse over rectangle 2

int rectX3, rectY3; // Position of rectangle 3
color rectColor3; // Color of rectangle 3
boolean rectOver3 = false; // Mouse over rectangle 3

//joyStick param
int JSx, JSy, JSz, buttonState, lastButtonState, stateCounter, effect = 0;
color JoyStickCircleColor;
int circleSizeMapped = 15;  // Adjust the size of the circle (x,y) position

void setup() {
  size(800, 600);
  oscP5 = new OscP5(this, 12000);

  //Joystick view setup
  JoyStickCircleColor = color(255);
  //gradient
  b1 = color(23,38,97);
  b2 = color(236,157,170);
  
  //Modes
  
  activeColorMode = color(240,154,37,170);
  passiveColorMode = color(51,168,194,130);
  backgroundColor = color(23,38,97);
  pixelDensity(2);  // Increase pixel density
  //instrumental
  rectX1 = width / 2 + 150;
  rectY1 = height / 2 - rectHeight / 2 - 80;
  rectColor1 = activeColorMode;
  //Demo
  rectX2 = width / 2 + 150;
  rectY2 = height / 2 - rectHeight / 2 - 30;
  rectColor2 = passiveColorMode;
  //Noise
  rectX3 = width / 2 + 150;
  rectY3 = height / 2 - rectHeight / 2 + 20;
  rectColor3 = passiveColorMode;
 
 //Play button
  ActivePlayBtn = color(55,118,33,255);
  PassivePlayBtn = color(50,58,112,255);
  BtnPlayColor = PassivePlayBtn;
  circleX = 48;
  circleY = 50;
  
 
  ellipseMode(CENTER);
  rectMode(CENTER); 
  textAlign(CENTER, CENTER);

  oscP5 = new OscP5(this,12000);  //rec
  sender = new NetAddress("127.0.0.1",57120);  //send to SC recAddress
}

void oscEvent(OscMessage message) {
  if (message.checkAddrPattern("/data") && message.checkTypetag("iii")) {
    JSx = message.get(0).intValue();
    JSy = message.get(1).intValue();
    JSz = message.get(2).intValue();
    draw();
  }
}

synchronized void draw() {
  
  update();
  //background(backgroundColor);
  setGradient(0, 0, width, height, b1, b2, X_AXIS);

  //JoyStick visualization
 
  // Draw the rect with emphasized boundaries
  stroke(255, 200);
  noFill();
  strokeWeight(2);
  rect(width/2 - 100, height/2 - 50, 200, 200);
  
  // Map x and y values to the coordinate system window
  float mappedX = map(JSx, 0, 1023, width/2 - 200, width/2);
  float mappedY = map(JSy, 0, 1023, height/2 + 50, height/2 - 150);
  
  // Draw coordinate system lines inside the rect
  stroke(255, 100);
  line(width/2 - 200, height/2 - 50, width/2, height/2 - 50); // Horizontal line
  line(width/2 - 100, height/2 - 150, width/2 - 100, height/2 + 50); // Vertical line

  // Draw the circle at the mapped x, y position
  noStroke();
  fill(JoyStickCircleColor);
  ellipse(mappedX, mappedY, circleSizeMapped, circleSizeMapped);
  
    
  // Draw rectangles for Modes
  fill(rectColor1);
  rect(rectX1, rectY1, rectWidth, rectHeight);
  
  fill(rectColor2);
  rect(rectX2, rectY2, rectWidth, rectHeight);
  
  fill(rectColor3);
  rect(rectX3, rectY3, rectWidth, rectHeight);
  
  // Draw playBtn
  fill(BtnPlayColor);
  ellipse(circleX, circleY, circleSize, circleSize);
  
  fill(204);
  triangle(70, 50, 36, 32, 36, 68);
   
  // Set the text properties
  textSize(25); // Set the font size
  fill(255); // Set the text color
  text("Instrumental", rectX1, rectY1 - 5);  
  text("Demo", rectX2, rectY2 - 5);
  text("WhiteNoise", rectX3, rectY3 - 5);
  println("Play: " + PlayButtonState + ", Mode: " + ModeState);


  // show effect name
  if (effect == 0) {
    text("wahwah", width/2 - 100, height/2 + 80);
  } else if (effect == 1) {
    text("phaser", width/2 - 100, height/2 + 80);
  } else if (effect == 2) {
    text("flanger", width/2 - 100, height/2 + 80);
  }
  
  
  OscMessage MessageToSend = new OscMessage("/mode");
  MessageToSend.add(ModeState);
  MessageToSend.add(PlayButtonState);
    
  oscP5.send(MessageToSend, sender);
  MessageToSend.print();
}


void update() {
  // Check if the mouse is over the Modes
  rectOver1 = overRect(rectX1, rectY1, rectWidth, rectHeight);
  rectOver2 = overRect(rectX2, rectY2, rectWidth, rectHeight);
  rectOver3 = overRect(rectX3, rectY3, rectWidth, rectHeight);
  
  // Check if the mouse is over the PlayBtn
  if (overCircle(circleX, circleY, circleSize)) {
    circleOver = true;
  } else {
    circleOver = false;
  }
  //JoyStick z status
  if (JSz == 0) {
    JoyStickCircleColor = color(255, 0, 0);  // Red color when z is 0
  } else {
    JoyStickCircleColor = color(0, 255, 0);  // Green color when z is 1
  }
  if (JSz != buttonState) { // Detect button state change
        lastButtonState = buttonState;
        buttonState = JSz;
        
        if (buttonState == 0 && lastButtonState == 1) { // Button changed from not pressed to pressed
          stateCounter = stateCounter + 1;
          effect = stateCounter % 3;
        }
  }
}

void mousePressed() {
  
  // Change color of Modes
  if (rectOver1) {
    rectColor1 = activeColorMode;
    rectColor2 = passiveColorMode;
    rectColor3 = passiveColorMode;
    ModeState = 0;
  } else if (rectOver2) {
    rectColor2 = activeColorMode;
    rectColor1 = passiveColorMode;
    rectColor3 = passiveColorMode;
    ModeState = 1;
  } else if (rectOver3) {
    rectColor3 = activeColorMode;
    rectColor1 = passiveColorMode;
    rectColor2 = passiveColorMode;
    ModeState = 2;
    
  }
  
  // Change color of playBtn
  if (circleOver) {
    if (PlayButtonState == 0) {
      PlayButtonState = 1;
      BtnPlayColor = ActivePlayBtn;
    } else {
      PlayButtonState = 0;
      BtnPlayColor = PassivePlayBtn;
    }
  }
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x - width/2 && mouseX <= x + width/2 &&
      mouseY >= y - height/2 && mouseY <= y + height/2) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter / 2) {
    return true;
  } else {
    return false;
  }
}
void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}
