/*  InstArt prototype www.mci.supsi.ch/senseable-art/instart
 *  Senseable Art Workshop www.mci.supsi.ch/senseable-art
 *  MCI project www.mci.supsi.ch
 *  CC BY-NC-SA
 */

import processing.video.*;
import processing.sound.*;

Capture cam;
SoundFile click;;

float contrast, brightness;
int actual_filter;

color brand = color(194, 15, 47);

int[] camres = {640, 480};

Button photoB;
Button satB;

PShape cam_ico, sat_ico, filter_ico;

String[] filters = {"no_filter", "threshold", "gray", "invert", "posterize"};

boolean functionswitch = false;    // false: contrast + brightness, true: saturation


class Button {
  
  int[] limits = new int[4];
  String id;
  
  Button (String iid, int[] ilmits) {
    id = iid;
    limits = ilmits;
    
    //println(limits);
  }
  
  boolean pressed(int x, int y) {
    if(x > limits[0] && x < limits[2] && y > limits[1] && y < limits[3]) {
      println("Button " + id + " pressed!");
      return true;
    }
    else {
      return false;
    }
  }
    
}


void setup() {
  fullScreen();
  //size(1024, 768);
  
  
 int[] photo_button = {int(0.8*width), int(height/3), width, int(2*height/3)};
 int[] sat_button = {int(0.8*width), int(2*height/3), width, height };
  
  
  photoB = new Button("Photo", photo_button);
  satB = new Button("Saturation", sat_button);
  
  click = new SoundFile(this, "click.mp3");
  
  cam_ico = loadShape("camera.svg");
  sat_ico = loadShape("saturation.svg");
  filter_ico = loadShape("filters.svg");
  
  
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println("i: " + i + " " + cameras[i]);
    }
    
    cam = new Capture(this, cameras[0]);
    cam.start();     
  }
  
  println("camres[0]: " + camres[0] + ", camres[1]: " + camres[1]);
      
}

void picUpdate(float contrast, float brightness) {
  
  cam.loadPixels();  
  
  for(int i = 0; i < camres[0]*camres[1]; i++) {
    
    int r = (int) red(cam.pixels[i]);
    int g = (int) green(cam.pixels[i]);
    int b = (int) blue(cam.pixels[i]);
    
    r = (int)(r * pow(10, contrast) + brightness);
    g = (int)(g * pow(10, contrast) + brightness);
    b = (int)(b * pow(10, contrast) + brightness);
    
    r = r < 0 ? 0 : r > 255 ? 255 : r;
    g = g < 0 ? 0 : g > 255 ? 255 : g;
    b = b < 0 ? 0 : b > 255 ? 255 : b;
    
    cam.pixels[i] = color(r, g, b); 
  }
}

void draw() {
  
  if (cam.available() == true) {
    cam.read();
    
    if(mouseX < width*0.8 && mousePressed) {
      if(!functionswitch) {
        contrast = map(mouseY, 0, height, 1, -1);
        brightness = map(mouseX, 0, width*0.8, -255, 255);
      } else {
        actual_filter = int(map(mouseX, 0, width*0.8, 0, filters.length));
      }
      
      println(actual_filter);
    }
    
    //println("contrast: " + contrast + "\t brightness: " + brightness);
    
    picUpdate(contrast, brightness);
    
    cam.resize(width, height);
    background(0);
    image(cam, 0, 0);
    activateFilter();
    
    noStroke();
    fill(brand);
    rect(width*0.8, 0, width*.2, height);
    fill(255);
    ellipseMode(CORNER);
    ellipse(width*0.825, height/3+width*0.025, width*0.15, width*0.15);
    ellipse(width*0.825, 2*height/3+width*0.025, width*0.15, width*0.15);
    
    shape(cam_ico, width*0.825, height/3+width*0.025, width*0.15, width*0.15 );
    
    if(!functionswitch) {
      shape(sat_ico, width*0.825, 2*height/3+width*0.025, width*0.15, width*0.15);
    } else {
      shape(filter_ico, width*0.825, 2*height/3+width*0.025, width*0.15, width*0.15);
    }
    cam.resize(camres[0], camres[1]);
    
  }
}

void activateFilter() {
  
  switch(actual_filter) {
    case 0:
      break;
    case 1:
      filter(THRESHOLD);
      break;
    case 2:
      filter(GRAY);
      break;
    case 3:
      filter(INVERT);
      break;
    case 4:
      filter(POSTERIZE, 4);
      break;
  }
}

void mouseClicked() {
  
  if(photoB.pressed(mouseX, mouseY)) {
    get(0, 0, int(width*0.8), height).save(savePath("/Users/marco/Dropbox/senseableart/LCV_team/how-they-see-it/assets/img/" + year() + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + "-" + nfc(pow(10, contrast), 1) + "-" + int(map(brightness, -255, 255, 0, 200)) + "-" + filters[actual_filter] + ".jpg"));
    
    int start_time = millis();
    click.play();
    while(millis() < (start_time + 1000)) {
      background(255);
    }
    //cam.save(savePath("/Users/marco/Dropbox/senseableart/LCV_team/how-they-see-it/assets/img/" + year() + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + "-" + nfc(pow(10, contrast), 1) + "-" + int(map(brightness, -255, 255, 0, 200)) + "-" + filters[actual_filter] + ".jpg"));
    //saveFrame(savePath("/Users/marco/Dropbox/senseableart/LCV_team/how-they-see-it/assets/img/" + year() + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + "-" + nfc(pow(10, contrast), 1) + "-" + int(map(brightness, -255, 255, 0, 200)) + "-" + filters[actual_filter] + ".jpg"));
  }
  
  if(satB.pressed(mouseX, mouseY)) {
    functionswitch = !functionswitch;
  }
  
  //println("contrast: " + contrast + ", brightness: " + brightness);
  //println("filename - contrast: " + pow(10, contrast) + ", brightness: " + map(brightness, -255, 255, 0, 200));
  
  //cam.save(savePath("/Users/marco/Dropbox/senseableart/LCV_team/how-they-see-it/assets/img/" + year() + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + "-" + nfc(pow(10, contrast), 1) + "-" + int(map(brightness, -255, 255, 0, 200)) + ".jpg"));
}