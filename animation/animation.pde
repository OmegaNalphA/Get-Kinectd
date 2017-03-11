final int totalHeight = 500;
final int totalWidth = 500;
color c1, c2, c3;
PShape box;

void setup() {
  size(500, 500);
  c1 = color(253, 92, 99);
  c2 = color(41, 171, 226);
  c3 = color(255,0);
  box = createShape(RECT,-50,-50,100,100);
  box.setStroke(c1);
  box.setStrokeWeight(40);
  box.setFill(c3);
}

void draw() {
  background(0);
  box.rotate(2*PI/180);
  translate(250, 250);
  shape(box);
}