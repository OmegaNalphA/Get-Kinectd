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
int Y_AXIS = 1;
int X_AXIS = 2;

//Variables
float percentGradientLine;
color b1, b2, c1, c2;
int[] change;

void setup () {
  size(500, 500);
  c1 = color(253, 92, 99);
  c2 = color(41, 171, 226);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
}

void draw () {
  background(c2);
  updateGradient(percentGradientLine);
  percentGradientLine = mouseY/(float)totalHeight * 100;
  println(percentGradientLine);
  img.loadPixels();
  
  int[] depth = kinect2.getRawDepth();
  
  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;
  
  int skip = 16;
  
  
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];

      if (d > minThresh && d < maxThresh && x > 100) {
        //img.pixels[offset] = color(255, 0, 150);
         
        //sumX += x;
        //sumY += y;
        //totalPixels++;
        
      } else {
        //img.pixels[offset] = color(0);
      }  
    }
  }

  //img.updatePixels();
  //image(img, 0, 0);
  
  //float avgX = sumX / totalPixels;
  //float avgY = sumY / totalPixels;
  //fill(150,0,255);
  //ellipse(avgX, avgY, 64, 64);
  
  //fill(255);
  //textSize(32);
  //text(minThresh + " " + maxThresh, 10, 64);
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

void updateGradient (float percent) {
  int calculatedHeight = (int)((100-percent)/100 * totalHeight);
  int newY = totalHeight - calculatedHeight;
  setGradient(0, newY, totalWidth, calculatedHeight, c2, c1, Y_AXIS);
}