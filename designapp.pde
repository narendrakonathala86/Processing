//Interactive Parameters
int screen = 0;
String options[] = {"Default", "Axis",  "Color", "Orbit"};
final int buttonDia = 15;
float scrollScale = 1; //Increase or decrease the size of planet

//GLobal defaults
final int numberOfStars = 25;
Star[] stars = new Star[numberOfStars];
Sphere sphere = new Sphere();
float noiseOffset = 0;
float noiseOffset1 = 0;
float axisRotate = 0;
final int numberOfArcs = 100;
TwoDimensionalArc[] arcs = new TwoDimensionalArc[numberOfArcs];

//Initialization 
void setup() {

    size(1080, 720, P3D);
    ellipseMode(CENTER);
    textAlign(CENTER);
    colorMode(HSB, 360 , 100, 100);
    pixelDensity(1);

    //Seed background Stars - Reuse same with infite loop
    for (int i = 0; i < numberOfStars; i++) {
        Star star = new Star();
        stars[i] = star;
    }

    //Seed spherical arcs
    for (int i = 0; i < numberOfArcs; i++) {
        TwoDimensionalArc arc = new TwoDimensionalArc();
        arcs[i] = arc;
    }
}        

//Runs for every frame
void draw() {
    noiseOffset += 0.005;

    //Aurora and stars common for all cases
    drawAurora(noiseOffset);
    drawStars();

    switch (screen) {
        case 0:
            drawPlanet(); 
            break;
        case 1:
            drawPlanet(); drawAxis();
            break;
        case 2:
            drawPlanet(); drawRaysReflection();
            break;
        case 3:
            drawRevolvingPlanet();
            break;
        default :
            println("default");
            break;
    }

    drawRings(); //Common for all use cases

    initializeFormOptions();
}

void keyPressed() {
    if (key == CODED && keyCode == LEFT) {
        if (screen > 0) {
            screen -= 1;
        }
    } else if (key == CODED && keyCode == RIGHT) {
        if (screen < options.length - 1) {
            screen += 1;
        }
    }
}

void mouseClicked() { 
    //Check whether the mouse is clicked within the form cirle
    int interval = (int) (width / (options.length + 1));
    int y = height - 50;

    for (int i = 0; i < options.length; i++) {
        int x = (i + 1) * interval;

        //Check the distance between center and the point . Should be less than radius of ellipse
        float dist = (float) (Math.sqrt(Math.pow(mouseX - x, 2) + Math.pow(mouseY - y,2)));

        if (dist <= buttonDia / 2) {
            screen = i;
            return;
        }
    }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  
  if ( (scrollScale + e * 0.001) < 2 && (scrollScale + e * 0.001) > 0.5 ) {
        scrollScale = scrollScale + e * 0.001;
        sphere.setScale(scrollScale);
  }

}


void initializeFormOptions() {

    int interval = (int) (width / (options.length + 1));
    int start = interval;
    int y = height - 50;

    noStroke();
    fill(0, 0, 50);
    rect(start, y - 1, (options.length - 1) * interval, 2);

    for (int i = 0; i < options.length; i++) {
        int x = (i + 1) * interval;
        fill(0, 0, i <= screen ? 75 : 50);
        if (screen == i) {
            rect(start, y - 1, x - interval, 2);
        }
        ellipse(x, y, buttonDia, buttonDia);
        textSize(10);
        text(options[i], x , y + 25);
    }
}


//Tried drawing a aurora borealis  background using noise function
void drawAurora(float interval) {

    float noiseScale = 0.01;
    
    //Decides how big or small the cluster should be
    int xRange = 4; //size of the rect
    int yRange = 2;

    float xOff = interval;
    for (int x = width; x >= 0; x -=xRange) {
        float yOff = interval; 
        for (int y = height; y >= 0; y -= yRange) {
            int index = (y * width + x);
            float noise = noise(xOff, yOff);
            pushMatrix();
            translate(x, y, 0);
            noStroke();

            //Aurora color 
            if (noise > 0.5) {
                fill(color(165, noise * 100 , abs(noise - 0.5) * 100)); //brighter green
            } else {
                fill(color(165, noise * 50 , abs(noise - 0.5) * 50)); 
            }
    
            rect(0, 0, xRange, yRange);    
            popMatrix();

            yOff += noiseScale;
        }
        xOff += noiseScale;
    }

    
}

void drawStars() {
    for (int i = 0; i < numberOfStars; i++) { 
        stars[i].draw();
    }
}

void drawPlanet() {
    sphere.setRevolve(false);
    sphere.draw();  
}

void drawRevolvingPlanet() {
    sphere.setRevolve(true);
    sphere.draw();  
}

void drawRings() {

    if (scrollScale < 0.75) {
        return; //No rings if the planet is too far
    }

    int gap = 2;
    //13 rings for Uranus
    for (int i = 0; i < 13; ++i) {
        pushMatrix();
        translate(width/2 - 30 * scrollScale , height/2, 100);
        scale(scrollScale);
        rotateY(PI / 2 + 0.2);
        rotateX(-0.1);
        noFill();
        strokeWeight(1);
        stroke(0, 0, i * gap * scrollScale + 50, i * gap * scrollScale + 10);
        ellipse(0,0, 350 + i * gap * scrollScale, 350 + i * gap * scrollScale);
        popMatrix();
    }
}

void drawAxis() {

    axisRotate -= 0.1;
    pushMatrix();
    translate(width/2 + 125 * scrollScale , height/2, 100);
    scale(scrollScale);
    rotateY(PI / 2 - 0.6);
    rotateX(-0.1);
    rotateZ(axisRotate);
    noFill();
    strokeWeight(1);
    stroke(0, 0, 50);
    arc(0, 0 , 50 , 10, PI, 1.2 * PI); //To get an arrow feel
    arc(0, 0 , 50 , 50, PI, 2.5 * PI); 
    popMatrix();
}


void drawRaysReflection() {
    //Get a value between 50 to 100 with time lapse
    int percent = (int) Math.abs(50 - (System.currentTimeMillis() / 100) % 100);

    beginShape();
    float val = noise(noiseOffset1);
    for (int x = 0; x < width/2; x += 30) {

        int y = (int) (sin(val + x) * 30 + height/2) ;
        pushMatrix();
        strokeWeight(2);
        stroke(93, 36, 100, percent);
        curveVertex(x, y);
        popMatrix();
    }
    endShape();

    for (int i = 0; i < numberOfArcs; i++) {
        arcs[i].setScale(scrollScale);
        arcs[i].draw(percent);
    }

    noiseOffset1 += 0.01;
}

//Random star 
class Star {
    float x = (float) (Math.random() * width);
    float y = (float) (Math.random() * height);
    float z = (float) (Math.random() * 100); //
    final int radius = (int) (Math.random() * 2 + 1);

    public void draw() {
        x = (x > width) ? 0 : x + 0.5; //To make it move from right to left
        pushMatrix();
        translate(x, y , z);
        noStroke();
        fill(0, 0, (int) (Math.random() * 100 + 50));
        ellipse(0,0,radius,radius);
        popMatrix();
    }
}

//Custom Replica of Sphere and light functionality in processing. 
//Created sphere with ellipses
class Sphere {
    int radius = 200;
    float interval = 0.01; //0.01; //radians
    float rotate = -1.74; //Default position
    boolean revolve = false;
    float scale = 1;

    public void setRevolve(boolean val) {
        revolve = val;
    }

    public void setScale(float val) {
        scale = val;
    }

    public void draw() {
        rotate = revolve ? rotate - 0.02 : rotate; //Incremental roation in counter clockwise

        float j=0;  
        for (float i = 0; i < TWO_PI; i += interval) {
            pushMatrix();
            translate(width/2, height/2, 100);
            rotateY(i + (revolve ? rotate : -1.74));
            rotateX(-0.1);
            scale(scale);
            strokeWeight(5);
            noFill();

            if (i > 0.7 * PI) {
                j -= 0.25;
                stroke(198, 28,(int) j );
            }else {
                j +=0.25;
                stroke(198, 28, (int) j);
            }

            arc(0,0,radius,radius, 0.5* PI, 1.5 * PI);
            popMatrix();
        }

    }
}


class TwoDimensionalArc {
    float alphaX = (float) Math.random() * TWO_PI;
    float alphaY = (float) Math.random() * TWO_PI;
    float start;
    float end;
    final int radius = 210;
    final float speed = 0.005;
    float scale = 1;

    public TwoDimensionalArc() {
        start = (float) ((Math.random() * TWO_PI) / 2); 
        end = start + (float) ((Math.random() * TWO_PI) / 4); 
    }

    public void setScale(float val) {
        scale = val;
    }

    void move() {
        start += speed;
        end += speed;
    }

    void draw(int percent) {
        move();
        pushMatrix();
        translate(width/2, height /2, 100);
        scale(scale);
        noFill();
        rotateX(alphaX);
        rotateY(alphaY);
        stroke(93, 36, 100, percent);
        arc(0, 0 , radius , radius, start, end); 
        popMatrix();
    }
}

