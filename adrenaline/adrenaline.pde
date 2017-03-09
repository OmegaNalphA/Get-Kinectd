import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect2 kinect2;

//Constants
final int totalHeight = 500;
final int totalWidth = 500;
float minThresh = 1000;
float maxThresh = 2000;
float threshDivider = (maxThresh-minThresh)/2;
PImage img;
int kinectSize = 217088;
int[] depth;
int[] previous = new int[kinectSize];
int[] change = new int[kinectSize];
double spread = 40;
int timer = 0;



//Variables
float percentGradientLine;
color c1, c2;
int totalChange;
float increment;

void setup () {
  //fullScreen();
  size(500, 500);
  c1 = color(253, 92, 99);
  c2 = color(41, 171, 226);
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
}

void draw () {

  background(c2);

  img.loadPixels();

  depth = kinect2.getRawDepth();

  int skip = 32;

  for (int x = 0; x < kinect2.depthWidth; x+= skip) {
    for (int y = 0; y < kinect2.depthHeight; y+= skip) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];
      int delta = abs(previous[offset]-depth[offset]);
      //println(delta);
      if (d > minThresh && d < (minThresh + threshDivider) && delta > 500) {
        change[offset] = delta;
        //println(delta);
      } else if (d > (maxThresh - threshDivider) && d < maxThresh && delta > 500) {
        change[offset] = (int)(1.5 * delta);
        //println("reached");
      } else {
        change[offset] = 0;
      }
      
      totalChange += change[offset];
    }
  }
  
  //println(totalChange);
  if(totalChange < 500) {
    totalChange = 0;
  }
  
  increment = -1*(int)map(totalChange, 0, 500, 10, 0)/100;
  if(increment > 0) {}
  //println(increment);

  percentGradientLine += increment;
  //println(percentGradientLine);
  
  if(percentGradientLine > 0 && timer %  10 == 0) {    
    percentGradientLine--;
  }
  
  //println(timer);
  //println(percentGradientLine);
  
  //reset to bottom
  double overflow = 100*(spread/(double)totalHeight);
  //update line
  
  updateGradient(percentGradientLine); 
  if(percentGradientLine >= 100+overflow) {
    background(c1);
    updateGradient(0);
    textSize(64);
    fill(0, 0, 0);
    text("yay", 250, 228);
    delay(3000);
    percentGradientLine = 0;
  }
  totalChange = 0;
  previous = depth;
  change = depth;
  timer++;
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