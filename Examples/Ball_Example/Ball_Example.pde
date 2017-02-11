import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect2 kinect2;

float x;
float y;
float easing = 0.05;

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
  //image(img, 0, 0);
  /*
  float skip = 20;
  for(int x = 0; x < img.width; x++){
    for(int y = 0; y < img.height; y++){
      int index = x + y * img.width;
      float b = brightness(img.pixels[index]);
      fill(b);
      pushMatrix();
      translate(x, y);
      rect(0, 0, skip, skip);
      popMatrix();
    }
  }
  */
  
  float targetX = mouseX;
  float dx = targetX - x;
  x += dx * easing;
  
  float targetY = mouseY;
  float dy = targetY - y;
  y += dy * easing;
  
  ellipse(x, y, 66, 66);
}