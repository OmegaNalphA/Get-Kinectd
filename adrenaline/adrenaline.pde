import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect2 kinect2;

//Constants
final int totalHeight = 500;
final int totalWidth = 500;
float minThresh = 480;
float maxThresh = 830;
PImage img;
int kinectSize = 217088;
int[] depth;
int[] previous = new int[kinectSize];
int[] change = new int[kinectSize];

//Variables
float percentGradientLine;
color c1, c2;
int totalChange;

void setup () {
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
      if (d > minThresh && d < maxThresh && x > 100 && delta > 500) {
        change[offset] = delta;
        //println(delta);
      } else {
        change[offset] = 0;
      }
      
      totalChange += change[offset];
    }
  }
  
  println(totalChange);
  percentGradientLine += map(totalChange, 0, 1000, 10, 0)/100;
  println(percentGradientLine);
  if(percentGradientLine >= 120) percentGradientLine = 0;
  updateGradient(percentGradientLine); 
  
  totalChange = 0;
  previous = depth;
  change = depth;
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
  setGradient(0, newY, totalWidth, 20, c2, c1);
}