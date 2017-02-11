import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect2 kinect2;

float x;
float y;
float easing = 0.05;
int xmax = 0;
int ymax = 0;
float max = 0;
void setup() {
  size(512, 424, P3D);
  noStroke();  
    
  kinect2 = new Kinect2(this);
 
  kinect2.initDepth();
  kinect2.initDevice();
}

void draw() {
  background(0);
  
  PImage img = kinect2.getDepthImage();
  int[] depth = kinect2.getRawDepth();
  //image(img, 0, 0);
  
  int skip = 16;

  //float skip = 10;
  for(int i = 0; i < img.width; i+=skip){
    for(int j = 0; j < img.height; j+=skip){
      int index = i + j * img.width;
      float b = brightness(img.pixels[index]);
      if(b > max){
        max = b;
        xmax = i;
        ymax = j;
      }
      //fill(b);
      //pushMatrix();
      //translate(x, y);
      //rect(0, 0, skip, skip);
      //popMatrix();
    }
  }
  
  
  //float targetX = mouseX;
  float targetX = xmax;
  float dx = targetX - x;
  x += dx * easing;
  
  //float targetY = mouseY;
  float targetY = ymax;
  float dy = targetY - y;
  y += dy * easing;
  
  ellipse(x, y, 66, 66);
}