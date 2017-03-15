// Class for animating a sequence of GIFs

class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  
  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];
    
    String imagenum;
    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      imagenum = str(i+1);
      String filename = imagePrefix + imagenum+  ".png";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos) {
    frame = ((frame+1) % imageCount);
    //println(frame);
    image(images[frame], xpos, ypos, images[frame].width/9, images[frame].height/9);
  }
  
  int getWidth() {
    return images[0].width;
  }
}