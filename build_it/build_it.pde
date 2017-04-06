import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

int cols = 64;
int rows;
int scaleW = 25; // width of columns
int scale = 19; // height of rows
int circw = 5;
int w = 1450;
int h = 1000;
int r = 1;
int space = 30;
boolean checkside = true;
int side=0; // which side enter from

int colorCount = 0; // counting colored area

float move = 0;  
float [][] grid; 
float linesL;
float linesR;
color[][] colors;
float still;

int mode = 0;

int savedTime;
int passedTime;
int totalTime = 5000;

float prev_avgX = 0;
float prev_avgY = 0;

float smoothX = 0;
float smoothY = 0;

// Kinect Library object
Kinect2 kinect2;
PImage img;

int totalChange = 0;

float sumX = 0;
float sumY = 0;
float totalPixels = 0;

float avgX;
float avgY;
  
int person_box_x;
int person_box_y;
  
float person_p_x;
float person_p_y; 

int[] depth;

int kinectSize = 217088;
int[] previous = new int[kinectSize];
int[] change = new int[kinectSize];

void setup () {
  size (1450, 1000, P3D);
  rows = 56;
  grid = new float [cols][rows];
  colors = new color[cols][rows];
  savedTime = millis();

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);

  for (int i=2; i<cols; i++) {
    for (int j=1; j<rows; j++) {
      colors[i][j] = color(255); // set color to white
    }
  } 
  
  previous = kinect2.getRawDepth();
  change = kinect2.getRawDepth();
  for(int i = 0; i < kinectSize; i++) {
    previous[i] = 0;
    change[i] = 0;
  }
}

void draw () {
  background(255);
  frameRate(60);
  translate(-20, 0);
  
  depth = kinect2.getRawDepth();
  
  sumX = 0;
  sumY = 0;
  totalPixels = 0;
  
  for(int x = 0; x < kinect2.depthWidth; x+=5){
    for(int y = 0; y < kinect2.depthHeight; y+=5){
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];
      
      if(d > 480 && d < 1800){
        sumX += x;
        sumY += y;
        totalPixels++;
      }
    }
  }
  
  avgX = sumX / totalPixels;
  avgY = sumY / totalPixels;
  
  if(Float.isNaN(smoothX)){
     smoothX = 0; 
  }
  if(Float.isNaN(smoothY)){
     smoothY = 0; 
  }
  
  smoothX = lerp(smoothX, avgX, 0.4);
  smoothY = lerp(smoothY, avgY, 0.4);
  
  //println(avgX + ", " + avgY);
  //println(smoothX + ", " + smoothY);
  
  //if(abs(prev_avgX - avgX) > 60){
  //   println(abs(prev_avgX - avgX));
  //  //println("hit");
  //  avgX = prev_avgX;
  //  avgY = prev_avgY;
  //}
  
  person_box_x = (int) smoothX/8;
  person_box_y = (int) smoothY/8;
  
  //println(person_box_x + " " + person_box_y);
  
  fill(255, 79, 79);
  ellipse(person_box_x * scaleW , person_box_y * scale, 32, 32);
  
  person_p_x = smoothX * (width)/512;
  person_p_y = smoothY * (height)/424;
  
  //prev_avgX = avgX; 
  //prev_avgY = avgY;
  
  
  // animating z coordinate
  move += 0.05;  
  float yoff = move;
  for (int x = 0; x < cols; x++) {
    float xoff = 0;
    for (int y = 0; y < rows; y++) {
      grid[x][y] = map(sin(yoff), 0, 1, -10, 10);
      xoff += 0.3;
    }
    yoff += 0.3;
  }
  
  // modes
  if (mode == 0) {
    colorCount = 0;
    for (int i=2; i<cols; i++) {
        for (int j=1; j<rows; j++) {
         colors[i][j] = color(255); // set color to white
        }
     } 
    // check side of entry
    if (checkside == true) {
     if (overRectKinect(0,0,width/2,height)== true) {
       side = 1;   //if enter from left side
       checkside = false;
     } else if (overRectKinect(width/2,0,width,height)== true) {
       side = 2; //if enter from right side
       checkside = false;
     } 
     pointgrid();
    }
    
    //println("SIDE: " + side);
  
    //grid lines
    if (side == 1) {
        linegridL();
        pointgrid();
    } else if (side == 2) {
        linegridR();
        pointgrid();
    }
    
  } else if (mode == 1) {
    colorAddKinect();
    side = 0;
  } else if (mode == 2) {
    popEffectKinect();
    checkside = true;
  }  else if (mode == 3) {
    disappear();
  } else if (mode == 4) {
    pointgrid();
        passedTime = millis() - savedTime;
        if (passedTime > 2000) {
          //println("5 seconds have passed!");
          //savedTime = millis(); // restart the timer
          mode = 0;
        }
  }
  resetVariables();
}
   
void linegridL() {
  //float percentl = map(mouseX, 0, width-20, 0, 1);
  float percentl = map(person_p_x, 0, width, 0, 1);
  float linesL = lerp(0, cols, percentl);
  //linesL = max(newlinesL, linesL);'
  
  // set mode to next mode
  if (linesL >= (cols) && mode == 0) {
    mode=1;
    linesL = 0;
    //newlinesL = 0;
  }  
  fill(255);
  stroke(0);
  float lineCount = linesL;
  
  if (mode > 0) {
    lineCount = cols;
  } 
  float z;
  for (int i = 2; i < lineCount; i++) {
    for (int j = 1; j < rows; j++) {
      for (int y = j-1; y < j; y++) {
        beginShape(QUAD_STRIP);
        for (int x = i-2; x < i; x++) { 
          z = grid[x][y];
          vertex(x*(scaleW), height - y*(scale), z);
          vertex(x*(scaleW), height - (y+1)*(scale), z); 
        }
        endShape();
      }
    }
  }
}


void linegridR() {
  //float percentr = map(mouseX, 0, width-15, 0, 1);
  float percentr = map(person_p_x, 0, width, 0, 1);
  float linesR = lerp(0, cols, percentr);
  //linesR = min(linesR, newlinesR);
  
  mode = 1;
  
  if (linesR <= 1 && mode == 0) {
    mode=1;
    linesR = 0;
    //newlinesL = 0;
  }
  
  fill(255);
  stroke(0);
  float lineCount = linesR;
  if (mode > 0) {
    lineCount = 0;
  }
  
   for (int j = 1; j < rows; j++) {
     for (int i = cols; ((i >=2) && (i > lineCount)); i--) {
       for (int y = j-1; y < j; y++) {
       beginShape(QUAD_STRIP);
       for (int x = i-2; x < i; x++) {
         vertex(x*scaleW, height-y*(scale), grid[x][y]);
         vertex(x*(scaleW), height-(y+1)*(scale), grid[x][y]); 
       }
     endShape();
     }  
    }
   }
}

// grid of points
void pointgrid() {

 for (int y = 0; y < rows; y++) {
    for (int x=0; x < cols; x++) {
      pushMatrix();
      fill(0);
      lights();
      translate(x*(scaleW), height - y*(scale), grid[x][y]);
      ellipse(0,0,r,r);
      popMatrix();
    }
  }
}

void colorAddKinect(){
   float z;
  for (int i=2; i<cols; i++) {
    for (int j=1; j<rows; j++) {
       for (int y = j-1; y < j; y++) {
       beginShape(QUAD_STRIP);
       for (int x = i-2; x < i; x++) {
        fill(colors[i][j]);
        z = grid[x][y];
        int c = x*scale+200;
        int r = height-y*scale-50;
        if (person_p_x > (c-scaleW) && person_p_x < (c + 3*scaleW) && person_p_y > (r) && person_p_y < (r + 5*scale)) {          
          if (colors[i][j] == color(255)) {
            colors[i][j] = color(#4c4491);
            colorCount+=1;
            //print(colorCount + "   ");
            //if (colorCount > 3120) {
            if (colorCount > 1500){
              mode = 2;
            }
          }
          if (colors[i][j] == color(#4c4491)) {
            z +=20;
          }
        }
       
         vertex(x*scaleW, height-y*(scale), z);
         vertex(x*(scaleW), height-(y+1)*(scale), z); 
       }
     endShape();
     } 
    } 
    
  }
}
void colorAdd() {

  float z;
  for (int i=2; i<cols; i++) {
    for (int j=1; j<rows; j++) {
       for (int y = j-1; y < j; y++) {
       beginShape(QUAD_STRIP);
       for (int x = i-2; x < i; x++) {
        fill(colors[i][j]);
        z = grid[x][y];
        int c = x*scale+200;
        int r = height-y*scale-50;
        if (mouseX > (c-scaleW) && mouseX < (c + 3*scaleW) && mouseY > (r) && mouseY < (r + 4*scale)) {          
          if (colors[i][j] == color(255)) {
            colors[i][j] = color(#4c4491);
            colorCount+=1;
            //print(colorCount + "   ");
            //if (colorCount > 3120) {
            if(colorCount > 1500){
              mode = 2;
            }
          }
          if (colors[i][j] == color(#4c4491)) {
            z +=20;
          }
        }
       
         vertex(x*scaleW, height-y*(scale), z);
         vertex(x*(scaleW), height-(y+1)*(scale), z); 
       }
     endShape();
     } 
    } 
    
  }
}

void popEffectKinect() {
  background(#f15e64);
  float z; 
  float w = 2; // width of reacting area
  float h = 1.7; //height of reacting area
  for (int i=2; i<cols; i++) {
    for (int j=1; j<rows; j++) {
       for (int y = j-1; y < j; y++) {
       beginShape(QUAD_STRIP);
       for (int x = i-2; x < i; x++) {
        fill(#4c4491);
        z = grid[x][y];
        int c = x*scale+200;
        int r = height-y*scale-60;
        if (person_p_x > c && person_p_x < (c + w*scaleW) && person_p_y > r && person_p_y < (r + h*scale)) {
          still = 20 + 8*sin(PI/2);
          z = still;
          if (KinectChaos()) {
            savedTime = millis(); // restart the timer
            z += random(20,50);
            mode = 3;
          }
        }
        vertex(x*scaleW, height-y*(scale), z);
        vertex(x*(scaleW), height-(y+1)*(scale), z);  
       }
     endShape();
     } 
    } 
  }
}

boolean KinectChaos(){
  totalChange = 0;
   for(int x = 0; x < kinect2.depthWidth; x += 32){
      for(int y = 0; y < kinect2.depthHeight; y += 32){
         int offset = x + y * kinect2.depthWidth;
         int d = depth[offset];
         int delta = abs(previous[offset] - depth[offset]);
         if (d > 480 && d < 830){
             if (delta > 500){
                change[offset] = delta; 
             }
         }
         else{
           change[offset] = 0; 
         }
         totalChange += change[offset];
      }
   }
   //println(totalChange);
   if(totalChange < 40000){
      totalChange = 0;
      return false;
   }
   return true;
}

void popEffect() {
  background(#f15e64);
  float z; 
  float w = 2; // width of reacting area
  float h = 1.7; //height of reacting area
  for (int i=2; i<cols; i++) {
    for (int j=1; j<rows; j++) {
       for (int y = j-1; y < j; y++) {
       beginShape(QUAD_STRIP);
       for (int x = i-2; x < i; x++) {
        fill(#4c4491);
        z = grid[x][y];
        int c = x*scale+200;
        int r = height-y*scale-60;
        if (mouseX > c && mouseX < (c + w*scaleW) && mouseY > r && mouseY < (r + h*scale)) {
          still = 20 + 8*sin(PI/2);
          z = still;
          if (mousePressed == true) {
            z += random(20,50);
            passedTime = millis() - savedTime;
            if (passedTime > totalTime) {
              println("5 seconds have passed!");
              savedTime = millis(); // restart the timer
              mode = 3;
            }  
          }
        }
        vertex(x*scaleW, height-y*(scale), z);
        vertex(x*(scaleW), height-(y+1)*(scale), z);  
       }
     endShape();
     } 
    } 
  }
}

void mousePressed () {
  savedTime = millis();
}

void disappear(){
  background(#f15e64);
  float z;
  for (int i=2; i<cols; i++) {
    for (int j=1; j<rows; j++) {
       for (int y = j-1; y < j; y++) {
       beginShape(QUAD_STRIP);
       for (int x = i-2; x < i; x++) {
        fill(#4c4491);
        z = grid[x][y];
        int c = x*scale-40;
        int r = height-y*scale-20;
        z += random(20,50);  
        passedTime = millis() - savedTime;
        if (passedTime > totalTime) {
           //println("5 seconds have passed!");
           savedTime = millis(); // restart the timer
           mode = 4;
        }
        vertex(x*scaleW, height-y*(scale), z);
        vertex(x*(scaleW), height-(y+1)*(scale), z);  
       }
     endShape();
     } 
    } 
    
  }
}

boolean overRectKinect(int xi, int yi, int wi, int hi){
  if(((int)person_p_x > xi) && ((int)person_p_x < xi + wi)){
    return true;
  }
  else{
    return false;
  }
}

boolean overRectMouse(int xi, int yi, int wi, int hi) {
  if ((mouseX > xi) && (mouseX < xi+wi) && (mouseY > yi) && (mouseY < yi+hi)) {
    return true;
  } else { 
    return false;
  }
}

void resetVariables(){
  totalChange = 0;
  previous = depth;
  change = depth;
}