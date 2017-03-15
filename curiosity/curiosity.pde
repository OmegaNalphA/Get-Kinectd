// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/17WoOqgXsRM
//import org.openkinect.processing.*;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;


// I create an array named "stars",
// it will be filled with 800 elements made with the Star() class.
Star[] stars = new Star[800];

// I create a variable "speed", it'll be useful to control the speed of stars.
float speed;
float xstart, xnoise, ystart, ynoise; 

Kinect2 kinect2;
Animation rocketan;

int kinectSize = 512*424;
int totalChange;
int minDepth = 2000;
int totalDepth=1;
int numPixels = 1;
int depthMean=0;
int oldDepthMean =0;

float xpos, ypos, xdiff, ydiff, rxpos, rypos, oldx, oldy;


void setup() {
  size(512, 424);
  kinect2 = new Kinect2(this);
  smooth(); 
  background(0);
  kinect2.initDepth();
  kinect2.initDevice();
  
  xstart = random(10); 
  ystart = random(10);
  // I fill the array with a for loop;
  // running 800 times, it creates a new star using the Star() class.
  for (int i = 0; i < stars.length; i++) {
    stars[i] = new Star();
  }
  
  rocketan = new Animation("Rocket", 5);
  frameRate(24);
}

void draw() {
  // i link the value of the speed variable to the mouse position.
  xstart += 0.01;  // increments x/y noise start values
  ystart += 0.01;
  PImage img = kinect2.getDepthImage();
  int[] depth = kinect2.getRawDepth();
  
  oldDepthMean = depthMean;
  int offset;
  int d;  
  
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      offset = i + j * img.width;
      d = depth[offset];
      if(d >200 && d<1000)
        { 
          totalDepth+=d;
          numPixels++;
        }
    }
  }
   
   depthMean = abs(totalDepth/numPixels);
   int deriv = abs(oldDepthMean - depthMean);

   xpos = width; //these values put the rocket in the right place
   ypos = height/2;
  
  //xdiff and ydiff are just values that change how the rocket moves depending on depth data
   if(deriv ==0)
   {
    speed = 0 ;
    xdiff = 2;
    ydiff = 0;
   }
  else if(deriv ==1  )
  {
    speed =2;
    xdiff=1.8;
    ydiff = height/2;
  }
  else if(deriv==2 )
  {
    speed = 5;
    xdiff=1.7;
    ydiff =height/3;
  }
  else if(deriv>2 && deriv<5)
  {
    speed =8;
    xdiff=1.5;
    ydiff = height/4;
  }
  else 
  {
    speed = 12;
    xdiff=1.3;
    ydiff = height/6;
  }
  
  //these change the position of the rocket and enable it to move smoothly
  float newx = xpos*xdiff;
  float dx = newx-oldx;
  rxpos= oldx + dx/30;
  
  float newy = ypos-ydiff;
  float dy = newy-oldy;
  rypos = oldy +dy/30;
  
  oldx = rxpos;
  oldy= rypos;

  background(0);
  // draw each star, running the "update" method to update its position and
  // the "show" method to show it on the canvas.
  for (int i = 0; i < stars.length; i++) {
    stars[i].update();
    stars[i].show();
  }
   rocketan.display(rxpos-rocketan.getWidth()/2, rypos);
}  

// draws concentric circles to give the effect of a gradient around the point
  void drawPoint(float x, float y, float noiseFactor) {    
  pushMatrix();
  translate(x, y);
  rotate(noiseFactor * radians(540));
  float edgeSize = noiseFactor * 35;
  float grey = 150 + (noiseFactor * 120);
  float alph = 150 + (noiseFactor * 120);
  noStroke();
  fill(grey, alph);
  ellipse(0, 0, edgeSize, edgeSize/2);
  popMatrix();
}