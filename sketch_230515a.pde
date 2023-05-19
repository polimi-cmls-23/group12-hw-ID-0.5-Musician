import oscP5.*;
import netP5.*;

OscP5 oscP5;


int x, y, z;
int circleColor;

void setup() {
  size(800, 600);
  circleColor = color(255);  // Initial color of the circle (white)
  oscP5 = new OscP5(this, 12000);

}

void oscEvent(OscMessage message) {
  if (message.checkAddrPattern("/data") && message.checkTypetag("iii")) {
    x = message.get(0).intValue();
    y = message.get(1).intValue();
    z = message.get(2).intValue();
    draw();
  }
}



void draw() {
  background(0);
  
  // Calculate the size and position of the coordinate system window
  float circleSize = min(width, height) / 4;  // Size of the circular window (1/4 of the main window size)
  float circleX = width - circleSize - 50;  // Position the circular window horizontally with a 50px margin from the left
  float circleY = 50;  // Position the circular window vertically with a 50px margin from the top
  
  // Draw boundaries between the main window and the circular window
  stroke(255, 100);
  noFill();
  strokeWeight(4);
  rect(0, 0, width, height);
  
  // Draw the circular window with emphasized boundaries
  stroke(255, 200);
  noFill();
  strokeWeight(2);
  rect(circleX, circleY, circleSize, circleSize);
  
  // Generate random values for x, y, and z
  
  
  
  // Map x and y values to the coordinate system window
  float mappedX = map(x, 0, 1023, circleX, circleX + circleSize);
  float mappedY = map(y, 0, 1023, circleY + circleSize, circleY); // Subtract y from the height of the window
  
  // Draw coordinate system lines inside the circular window
  stroke(255, 100);
  line(circleX, circleY + circleSize / 2, circleX + circleSize, circleY + circleSize / 2);  // Horizontal line
  line(circleX + circleSize / 2, circleY, circleX + circleSize / 2, circleY + circleSize);  // Vertical line
  
  // Draw the circle at the mapped x, y position
  noStroke();
  fill(circleColor);
  float circleSizeMapped = circleSize / 10;  // Adjust the size of the circle
  ellipse(mappedX, mappedY, circleSizeMapped, circleSizeMapped);
  
  // Display the x and y values inside the coordinate system
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(16);


  
  
  // Change the circle's color based on the value of z
  if (z == 0) {
    circleColor = color(255, 0, 0);  // Red color when z is 0
  } else {
    circleColor = color(0, 255, 0);  // Green color when z is 1
  }
}
