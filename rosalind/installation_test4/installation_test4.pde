import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect2 kinect2;

float minThresh = 480;
float maxThresh = 2048;

int cols, rows;
int scale = 30;
final static float TILE_WIDTH = 35;
float scaleW = TILE_WIDTH;
int circw = 5;
int w = 700;
int h = 500;
int r = 1;
int space = 30;
boolean side; // which side enter from
float move = 0;  
float [][] grid; 
float linesL;
float linesR;
float colorL;


void setup () {
  size (512,424, P3D);
  
  cols = w/scale;
  rows = h/scale;
  grid = new float [cols][rows];
 
}


void draw () {
   background(255);
   frameRate(24);
   translate(-40,20);
 
  move += 0.03;  
  float yoff = move;
  for (int x = 0; x < cols; x++) {
    float xoff = 0;
     for (int y = 0; y < rows; y++) {
       grid[x][y] = map(sin(yoff),0,1,-10,10);
       xoff += 0.3;
     }
     yoff += 0.3;
   }
   
  //grid lines
  linegrid();
  pointgrid();
}
 
 void linegrid() {
   float percentl = map(mouseX, 0, width, 0,1);
   float percentr = map(mouseX, width, 0, 0,1);
   
   float newlinesL = lerp(0,cols,percentl);
   float newlinesR = lerp(cols,0,percentr);
   
   linesL = max(newlinesL, linesL);
   linesR = min(linesR, newlinesR);
   
  /*
   if (overRect(0,0,10,height)== true) {
     side = false;   //if enter from left side
   } else if (overRect(width-10,0,width/2,height)== true) {
     side = true; //if enter from right side
   } */
   
  // create lines
  //enter left
   fill(255);
   stroke(0);
     for (int j = 1; j < rows; j++) {
       for (int i = 2; i < linesL; i++) {
         for (int y = j-1; y < j; y++) {
           beginShape(QUAD_STRIP);
           for (int x = i-2; x < i; x++) {
             vertex(x*(scale), height - y*(scale), grid[x][y]);
             vertex(x*(scale), height - (y+1)*(scale), grid[x][y]); 
             if (x > cols - 4) {
             //add color
             float mx = x*scale;
             float my =  y*(scale);
             float X = mx + scaleW;
             float Y = my;
             PVector minXY = new PVector(X,Y);
             PVector maxXY = new PVector(X+scaleW,Y+scaleW);
             int p_mx = mouseX;
             int p_my = mouseY;
             if (minXY.x > p_mx && p_mx < maxXY.x && minXY.y > p_my && p_my < maxXY.y){
                fill(0,255,0);
             }
             }
           }
           endShape();
         }  
       }
     
     
   //enter right
   /*

     for (int j = 1; j < rows; j++) {
     for (int i = cols; ((i >=2) && (i > linesR)); i--) {
         for (int y = j-1; y < j; y++) {
           beginShape(QUAD_STRIP);
           for (int x = i-2; x < i; x++) {
             vertex(x*(scale), height-y*(scale), grid[x][y]);
             vertex(x*(scale), height-(y+1)*(scale), grid[x][y]); 
           }
           endShape();
         }  
       }
     }
   */
     }
    
 }
 
 // grid of points
 void pointgrid() {
   
   for (int y = 0; y < rows; y++) {
     for (int x=0; x < cols; x++) {
       pushMatrix();
         fill(0);
         lights();
         translate(x*(scale), height - y*(scale),grid[x][y]);
         sphere(r);
       popMatrix();
       //ellipse(x*(scale), y*(scale), r,r);
     }
   }
 }
 
 boolean overRect(int xi, int yi, int wi, int hi) {
  if ((mouseX > xi) && (mouseX < xi+wi) && (mouseY > yi) && (mouseY < yi+hi)) {
    return true;
  } else { 
    return false;
  }
}