// Launches your webcam and when you select an object it will track it
/*Tracker will tack object color and draw with object and general color
  of the object*/


import processing.video.*;
import boofcv.processing.*;
import boofcv.struct.image.*;
import georegression.struct.point.*;
import georegression.struct.shapes.*;

Capture cam;
SimpleTrackerObject tracker;

//Storage for where the use selects the target and the current target location.
Quadrilateral_F64 target = new Quadrilateral_F64();
//If true the target has been detected by the tracker.
boolean targetVisible = false;
PFont f;
//Indicates if the user is selecting a target or if the tracker is tracking it.
PGraphics img;
color trackColor;
float transparency = 70;
int func = 0;
int mode = 0;

void setup() {
  // Open up the camera so that it has a video feed to process
  initializeCamera(640, 480);
  surface.setSize(cam.width, cam.height);
  img = createGraphics(cam.width, cam.height);
  //Tracker Declaration
  tracker = Boof.trackerTld(null,ImageDataType.F32);
  //Font
  f = createFont("Arial", 24, true);
}

void draw() {
  if (cam.available() == true) {
    cam.read();

    if ( mode == 1 ) {
      targetVisible = true;
    } else if ( mode == 2 ) {
      //User has selected the object to track so initialize the tracker using
      //an ellipse.
      if ( !tracker.initialize(cam, target.a.x, target.a.y, target.c.x, target.c.y) ) {
        mode = 100;
      } else {
        targetVisible = true;
        mode = 3;
      }
    } else if ( mode == 3 ) {
      //Update the track state using the next image in the sequence
      if ( !tracker.process(cam) ) {
        /*It failed to detect the target. This could mean the item is out of range or sight.
        It can be recovered when it becomes visible again.*/
        targetVisible = false;
      } else {
        //Tracking worked, save the results
        targetVisible = true;
        target.set(tracker.getLocation());
      }
    }
  }
  image(cam, 0, 0);



  // The code below deals with visualizing the results
  textFont(f);
  textAlign(CENTER);
  fill(0, 0xFF, 0);
  if ( mode == 0 ) {
    text("Click and Drag", width/2, height/4);
  } else if ( mode == 1 || mode == 2 || mode == 3) {
    if ( targetVisible ) {
      drawTarget();
    } else {
      text("Can't Detect Target", width/2, height/4);
    }
  } else if ( mode == 100 ) {
    text("Initialization Failed.\nSelect again.", width/2, height/4);
  }
  image(img, 0, 0);
}

void mousePressed() {
  //Selects pixel and mode. Also resets ellipse.
  mode = 1;
  func = 0;
  //Set coordinates
  target.a.set(mouseX, mouseY);
  target.b.set(mouseX, mouseY);
  target.c.set(mouseX, mouseY);
  target.d.set(mouseX, mouseY);
  //Track color on pixel mouse clicks on
  int loc = mouseX + mouseY*cam.width;
  trackColor = cam.pixels[loc];
}

void mouseDragged() {
  //User defines size of circle.
  target.b.x = mouseX;
  target.c.set(mouseX, mouseY);
  target.d.y = mouseY;
}

void mouseReleased() {
  // After the mouse is released tell it to initialize tracking.
  mode = 2;
  func = 1;
}

//Changes transparency of ellipse.
void keyPressed(){
  if (key == 'w'){
    transparency+=5;
  } else if (key == 's') {
    transparency-=5;}
}

//Track color of pixel mouse clicks on and track pbject while drawing and ellipse.
void drawTarget() {
  double radiusx =  (target.a.x - target.b.x)/2.0;
  double radiusy =  (target.a.y - target.d.y)/2.0;
  img.beginDraw();
  if(func == 0){
    img.clear();
  }
  img.fill(color(red(trackColor), green(trackColor), blue(trackColor), transparency));
  img.noStroke();
  img.ellipse((float)(target.a.x - radiusx), (float)(target.a.y - radiusy), (float)radiusx*2.0, (float)radiusy*2.0);
  img.endDraw();
}

//Checks for available camera and outputs to user without camera.
void initializeCamera( int desiredWidth, int desiredHeight ) {
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    cam = new Capture(this, desiredWidth, desiredHeight);
    cam.start();
  }
}
