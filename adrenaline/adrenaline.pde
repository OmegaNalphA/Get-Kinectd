//Constants
final int totalHeight = 500;
final int totalWidth = 500;

int Y_AXIS = 1;
int X_AXIS = 2;  
float percenGradientLine = 0;
color b1, b2, c1, c2;

void setup () {
  size(500, 500);
  c1 = color(253, 92, 99);
  c2 = color(41, 171, 226);
}

void draw () {
  background(c2);
  updateGradient(percentGradientLine);
  percentGradientLine = mouseY/(float)totalHeight * 100;
  println(gradientLine);
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
  int calculatedHeight = (int)(percent/100 * totalHeight);
  int newY = totalHeight - calculatedHeight;
  setGradient(0, newY, totalWidth, calculatedHeight, c2, c1, Y_AXIS);
}