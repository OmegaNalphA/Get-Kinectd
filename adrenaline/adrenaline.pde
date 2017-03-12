import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect2 kinect2;

//Constants
final int totalHeight = 800;
final int totalWidth = 1200;
float minThresh = 1000;
float maxThresh = 2000;
float threshDivider = (maxThresh-minThresh)/2;
color c1, c2, c3;
PImage img;
int kinectSize = 217088;
double spread = 40;
int timer = 0;
double overflow;
PShape b;
Box b1, b2, b3, b4, b5, b6, b7;

//Variables
float percentGradientLine;
int totalChange;
float increment;
int countdownTimer = 500;
boolean complete = false;
int[] depth;
int[] previous = new int[kinectSize];
int[] change = new int[kinectSize];


void setup () {
  //fullScreen();
  size(1200, 800);
  //size(displayWidth, displayHeight);
  c1 = color(253, 92, 99);
  c2 = color(41, 171, 226);
  c3 = color(255, 255, 255);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  previous = kinect2.getRawDepth();
  change = kinect2.getRawDepth();
  for(int i = 0; i < kinectSize; i++) {
    previous[i] = 0;
    change[i] = 0;
  }
  b1 = new Box(50, 50, 120, c3);
  b2 = new Box(-20, 10, 70, c3);
  b3 = new Box(-10,-40, 60, c3);
  b4 = new Box(-10, 70, 100, c3);
  b5 = new Box(70, -20, 90, c3);
  b6 = new Box(-10, -50, 150, c3);
  b7 = new Box(-20, 60, 80, c3);
}

/////////////////////////////////////////////////
////////////////////LOOP/////////////////////////
/////////////////////////////////////////////////

void draw () {
  if(!complete) {
    getAdrenaline();
    updateGradient(percentGradientLine);
    resetVariables();
  }
  if(percentGradientLine >= 100 + overflow) {
    startCountdown();
    victoryMessage();
  }
}

/////////////////////////////////////////////////
/////////////////PHASE 1/////////////////////////
/////////////////////////////////////////////////

void getAdrenaline () {
  background(c2);
  img.loadPixels();
  depth = kinect2.getRawDepth();
  int skip = 32;
  for (int x = 0; x < kinect2.depthWidth; x+= skip) {
    for (int y = 0; y < kinect2.depthHeight; y+= skip) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];
      int delta = abs(previous[offset]-depth[offset]);
      if (d > minThresh && d < (minThresh + threshDivider) && delta > 500) {change[offset] = delta;}
      else if (d > (maxThresh - threshDivider) && d < maxThresh && delta > 500) {change[offset] = (int)(1.5 * delta);} 
      else {change[offset] = 0;}
      totalChange += change[offset];
    }
  }
  if(totalChange < 500) {totalChange = 0;}
  increment = -1*(int)map(totalChange, 0, 500, 10, 0)/100;
  if(increment > 0) {}
  percentGradientLine += increment;
  if(percentGradientLine > 0 && timer %  10 == 0) {percentGradientLine--;}
  overflow = 100*(spread/(double)totalHeight);
}

void setGradient(int x, int y, float w, float h, color c1, color c2) {
  noFill();
  for (int i = y; i <= y+h; i++) {
    float inter = map(i, y, y+h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, x+w, i);
  }
}

void updateGradient (float percent) {
  int calculatedHeight = (int)((100-percent)/100 * totalHeight);
  int newY = calculatedHeight;
  setGradient(0, newY, totalWidth, (int)spread, c2, c1);
  fill(c1);  
  rect(0, calculatedHeight+(int)spread, totalWidth, totalHeight);
}

void resetVariables () {
  totalChange = 0;
  previous = depth;
  change = depth;
  timer++;
}

/////////////////////////////////////////////////
/////////////////PHASE 2/////////////////////////
/////////////////////////////////////////////////

void victoryMessage () { 
  background(c1);
  b1.update();
  b2.update();
  b3.update();
  b4.update();
  b5.update();
  b6.update();
  b7.update();
}

void startCountdown() {
  if(countdownTimer==500) {
    complete = true;
  }
  countdownTimer--;
  println(countdownTimer);
  if(countdownTimer <= 0) {
    println("reached");
    complete = false;
    updateGradient(0);
    percentGradientLine = 0;
    countdownTimer = 500;
  }
}

class Box {
  int posX, posY, size;
  PShape box;
  Box (int perX, int perY, int size, color c) {
     box = createShape(RECT, (-1*size)/2, (-1*size)/2, size, size);
     box.setStroke(c);
     box.setFill(color(255,0));
     box.setStrokeWeight(2*(size/5));
     posX = (int) ((perX/100.0) * totalWidth);
     posY = (int) ((perY/100.0) * totalHeight);
  }
  void update() {
    box.rotate(4*PI/180);
    translate(posX, posY);
    shape(box);
  }
}