import processing.pdf.*;

import processing.opengl.*;

// Sand Traveler 
// Special commission for Snar 2004, Barcelona
// sand painter implementation of City Traveler + complexification.net

// j.tarbell   May, 2004
// Albuquerque, New Mexico
// complexification.net

// Processing 0085 Beta syntax update
// j.tarbell   April, 2005

// Modified by Ben Callam August, 8, 2008
// Updated algorithm and added ability to output SUPER highres images for print


int dimX = 324;
int dimY = 864;
int shapeW = 2;
int shapeH = 2;
int fileNum = 0;
float scaleFactor = 20;

float t;
int bgColor = 255;
int dx, dy;
int num = 200;
int maxnum = 201;
int cnt = 0;
// minimum distance to draw connections
int mind = dimY+dimX/3;//333;

PGraphics bigImage;

City[] cities;
// GRAYS
color[] goodcolor = { #000000, #6A715D, #191919, #333333, #4C4C4C, #666666, #7F7F7F, #999999, #B2B2B2, #CCCCCC, #E5E5E5, #F2F2F2,  #FFFFFF,#FFFFFF,#FFFFFF, #FFFFFF,
// ORANGES
#C85B28, #CE6D39, #E7B799, #B3B3B3, #E6E6E6};
// GREENS  #9FA987, #8CB689, #A3C090, #C0C090, #B6B188, #CED1BF
// #3a242b, #3b2426, #352325, #836454, #7d5533, #8b7352, #b1a181, #a4632e, #bb6b33, #b47249, #ca7239, #d29057, #e0b87e, #d9b166, #f5eabe, #fcfadf, #d9d1b0, #fcfadf, #d1d1ca, #a7b1ac, #879a8c, #9186ad, #776a8e, #000000,#000000,#000000,#000000,#000000,#FFFFFF,#FFFFFF,#FFFFFF,#FFFFFF,#FFFFFF
void setup() {
  size(dimX,dimY,P3D);
  bigImage = createGraphics(int(dimX*scaleFactor),int(dimY*scaleFactor), P3D);

  colorMode(RGB, 255);
  background(bgColor);
  
  bigImage.colorMode(RGB, 255);
  bigImage.background(bgColor);
  
  cities = new City[maxnum];
 
  resetAll();
}

void draw() {
  noStroke();
  bigImage.noStroke();
  
  // move cities
  for (int c=0;c<num;c++) {
    cities[c].move();
  }
  // cycle limiter
  if (cnt++>(120*30)) {
    cnt=0;
    resetAll();
  }
  
  // Save a huge .tif
  if(keyPressed) {
    if (key == 'b' || key == 'B') {
    println("Saving Image...");
    bigImage.dispose();
    bigImage.endDraw();
    bigImage.save(fileNum + ".tif");
    fileNum++;
    bigImage.beginDraw();  
    println("Image " + fileNum + ".tif Saved");
    }
  }
}


void mousePressed() {
  resetAll();
}

// METHODS -------------------------------------------------------------------

void resetAll() {
  background(bgColor);
  bigImage.background(bgColor);
  
  float vt = 4.2;
  float vvt = 0.2;
  float ot = random(TWO_PI);
  for (int t=0;t<num;t++) {
    float tinc = ot+(1.1-t/num)*2*t*TWO_PI/num;
    float vx = vt*sin(tinc);
    float vy = vt*cos(tinc);
    cities[t] = new City(dimX/2+vx*3,dimY/3+vy*3,vx,vy,t);
    vvt-=0.00033;
    vt+=vvt;
  }
  
  for (int t=0;t<num;t++) {
    cities[t].findFriend();
  }

   bigImage.beginDraw();
   
}

float citydistance(int a, int b) {
  if (a!=b) {
    // calculate and return distance between cities
    float dx = cities[b].x-cities[a].x;
    float dy = cities[b].y-cities[a].y;
    float d = sqrt(dx*dx+dy*dy);
    return d;
  } else {
    return 0.0;
  }
}


// OBJECTS ------------------------------------------------------------------

class City {

  float x,y;
  int friend;
  float vx, vy;
  int idx;
  color myc = somecolor();
  
  // sand painters
  int numsands = 3;
  SandPainter[] sands = new SandPainter[numsands];

  City(float Dx, float Dy, float Vx, float Vy, int Idx) {
    // position
    x = Dx;
    y = Dy;
    vx = Vx;
    vy = Vy;
    idx = Idx;

    // create sand painters
    for (int n=0;n<numsands;n++) {
      sands[n] = new SandPainter();
    }
  }

  void move() {
    vx+=(cities[friend].x-x)/1000;
    vy+=(cities[friend].y-y)/1000;

    vx*=.936;
    vy*=.936;
    x+=vx;
    y+=vy;

    drawTravelers();
  }
  void findFriend() {
    friend = (idx + int(random(num/5)))%num;
  }
    
  void drawTravelers() {
    int nt = 11;
    for (int i=0;i<nt;i++) {
      // pick random distance between city
      t = random(TWO_PI);
      // draw traveler      
      float dx = sin(t)*(x-cities[friend].x)/2+(x+cities[friend].x)/2;
      float dy = sin(t)*(y-cities[friend].y)/2+(y+cities[friend].y)/2;
      if (random(1000)>990) {
        // noise
        dx+=random(3)-random(3);
        dy+=random(3)-random(3);
      }
      
      fill(red(cities[friend].myc),green(cities[friend].myc),blue(cities[friend].myc),48);
      ellipse(dx,dy ,shapeW, shapeH);
      bigImage.fill(red(cities[friend].myc),green(cities[friend].myc),blue(cities[friend].myc),48);      
      bigImage.ellipse(dx*scaleFactor,dy*scaleFactor ,shapeW*scaleFactor, shapeH*scaleFactor);
      
      // draw anti-traveler
      dx = -1*sin(t)*(x-cities[friend].x)/2+(x+cities[friend].x)/2;
      dy = -1*sin(t)*(y-cities[friend].y)/2+(y+cities[friend].y)/2;
      if (random(1000)>990) {
        // noise
        dx+=random(3)-random(3);
        dy+=random(3)-random(3);
      }
      
      ellipse(dx,dy ,shapeW, shapeH);
      bigImage.ellipse(dx*scaleFactor,dy*scaleFactor ,shapeW*scaleFactor, shapeH*scaleFactor);
     
     }
   }
   
  void drawSandPainters() {
    for (int s=0;s<numsands;s++) {
      sands[s].render(x,y,cities[friend].x,cities[friend].y);
    }
  }
}

class SandPainter {

  float p;
  color c;
  float g;

  SandPainter() {

    p = random(1.0);
    c = somecolor();
    g = random(0.01,0.1);
  }
  void render(float x, float y, float ox, float oy) {
    // draw painting sweeps
    fill(red(c),green(c),blue(c),28);
    ellipse(ox+(x-ox)*sin(p),oy+(y-oy)*sin(p) ,shapeW, shapeH);
    
    bigImage.fill(red(c),green(c),blue(c),28);        
    bigImage.ellipse(ox+(x-ox)*sin(p)*scaleFactor,oy+(y-oy)*sin(p)*scaleFactor,shapeW*scaleFactor,shapeH*scaleFactor);

    g+=random(-0.050,0.050);
    float maxg = 0.22;
    if (g<-maxg) g=-maxg;
    if (g>maxg) g=maxg;
    p+=random(-0.050,0.050);
    if (p<0) p=0;
    if (p>1.0) p=1.0;

    float w = g/10.0;
    for (int i=0;i<11;i++) {
      float a = 0.1-i/110.0;
      
      fill(red(c),green(c),blue(c),a*256);
      ellipse(ox+(x-ox)*sin(p + sin(i*w)),oy+(y-oy)*sin(p + sin(i*w)) ,shapeW, shapeH);
      ellipse(ox+(x-ox)*sin(p - sin(i*w)),oy+(y-oy)*sin(p - sin(i*w)) ,shapeW, shapeH);
      
      bigImage.fill(red(c),green(c),blue(c),a*256);
      bigImage.ellipse(ox+(x-ox)*sin(p + sin(i*w))*scaleFactor,oy+(y-oy)*sin(p + sin(i*w))*scaleFactor ,shapeW*scaleFactor, shapeH*scaleFactor);
      bigImage.ellipse(ox+(x-ox)*sin(p - sin(i*w))*scaleFactor,oy+(y-oy)*sin(p - sin(i*w))*scaleFactor ,shapeW*scaleFactor, shapeH*scaleFactor);
    }
  }

  void renderPerp(float x, float y, float ox, float oy) {
    // transform perpendicular
    float mx = (x+ox)/2;
    float my = (y+oy)/2;
    
    float g = 0.42;
    float x1 = mx + (y-my)*g;
    float y1 = my - (x-mx)*g;
    
    float ox1 = mx + (oy-my)*g;
    float oy1 = my - (ox-mx)*g;
  
    // draw painting sweeps
    fill(red(c),green(c),blue(c),28);
    ellipse(ox1+(x1-ox1)*sin(p),oy1+(y1-oy1)*sin(p) ,shapeW, shapeH);

    bigImage.fill(red(c),green(c),blue(c),28);
    bigImage.ellipse(ox1+(x1-ox1)*sin(p)*scaleFactor,oy1+(y1-oy1)*sin(p)*scaleFactor ,shapeW*scaleFactor, shapeH*scaleFactor);

    g+=random(-0.050,0.050);
    float maxg = 0.22;
    if (g<-maxg) g=-maxg;
    if (g>maxg) g=maxg;
    p+=random(-0.050,0.050);
    if (p<0) p=0;
    if (p>1.0) p=1.0;

    float w = g/10.0;
    for (int i=0;i<11;i++) {
      float a = 0.1-i/110.0;

      fill(red(c),green(c),blue(c),a*256);
      ellipse(ox1+(x1-ox1)*sin(p + sin(i*w)),oy1+(y1-oy1)*sin(p + sin(i*w)) ,shapeW, shapeH);
      ellipse(ox1+(x1-ox1)*sin(p - sin(i*w)),oy1+(y1-oy1)*sin(p - sin(i*w)) ,shapeW, shapeH);

      bigImage.fill(red(c),green(c),blue(c),a*256);
      bigImage.ellipse(ox1+(x1-ox1)*sin(p + sin(i*w))*scaleFactor,oy1+(y1-oy1)*sin(p + sin(i*w))*scaleFactor ,shapeW*scaleFactor, shapeH*scaleFactor);
      bigImage.ellipse(ox1+(x1-ox1)*sin(p - sin(i*w))*scaleFactor,oy1+(y1-oy1)*sin(p - sin(i*w))*scaleFactor ,shapeW*scaleFactor, shapeH*scaleFactor);
    }
  }
}


// COLOR ROUTINES -------------------------------------------------------------

color somecolor() {
  // pick some random good color
  return goodcolor[int(random(goodcolor.length))];
}
