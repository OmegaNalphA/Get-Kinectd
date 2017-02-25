import org.openkinect.processing.*;

// Kinect Library object
Kinect2 kinect2;

float minThresh = 480;
float maxThresh = 830;
PImage img;
PFont f; 

void setup() {
  //fullScreen();
  size(512, 424);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  //img = createImage(displayWidth, displayHeight, RGB);
  f = createFont("Arial", 16, true);
}


void draw() {
  background(0);
  textFont(f, 16);
  fill(255);
  img.loadPixels();
  
  //minThresh = map(mouseX, 0, width, 0, 4500);
  //maxThresh = map(mouseY, 0, height, 0, 4500);
  

  // Get the raw depth as array of integers
  int[] depth = kinect2.getRawDepth();
    
  //make new pixel object then scale that using.resize
  
  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;
  
  for (int x = 0; x < kinect2.depthWidth; x+=10) {
    for (int y = 0; y < kinect2.depthHeight; y+=10) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];
      
    
      if (d > minThresh && d < maxThresh) {
        img.pixels[offset] = color(255, 0, 150);
        text("hello", x, y); 
        sumX += x;
        sumY += y;
        totalPixels++;
        
      } else {
        img.pixels[offset] = color(0);
      }  
    }
  }
  /*
  for(int x = 0; x < displayWidth; x+=30){
    for(int y = 0; y < displayHeight; y+=30){
       int offset = x + y * width;
       
       img.pixels[offset] = color(255, 255, 255);
    }
  }
  */
  

  img.updatePixels();
  image(img, 0, 0);
  
  float avgX = sumX / totalPixels;
  float avgY = sumY / totalPixels;
  fill(150,0,255);
  ellipse(avgX, avgY, 64, 64);
  
  //fill(255);
  //textSize(32);
  //text(minThresh + " " + maxThresh, 10, 64);
}