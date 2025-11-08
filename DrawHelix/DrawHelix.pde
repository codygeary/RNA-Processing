/**
 * Draw Helix
 * by Cody Geary
 * 10 July 2013
 *
 * Generates an RNA or DNA helix of specified length and plots it in P3D
 */

// ***Settings***=
int length_NA = 100; //set the max length, to calculate
int polymer = 1 ;   // (1) RNA,  (2) DNA, (3) LNA
int style = 2 ;     // (1) wireframe, (2) solid, (3) wire with bps through axis, (4) solid axis
int showaxis = 1  ; // (1) axis, (0) no axis
int showatoms = 0 ; // (1) show spheres, (0) no spheres
int persp_mode = 0; // (1) perspective, (0) orthographic projection
int inverter = -1; //this flips the right-handed coordinates into left-handed for displaying

float viewangleX = 0;   // horizontal axis
float viewangleY = 0;   // vertical axis
float viewangleZ = 0;   // in-plane axis
float zoomlevel = 9;
float anglechangeX = 1;  // sets the rotation angle step size, set to 0 for stationary
float anglechangeY = 0; 
float anglechangeZ = 0;

// Initialize Arrays for drawing helices
float[][] phos_one = new float[length_NA+1][3]; // arrays of coordinatess for main-strand phosphates  [atom number], [x,y,z]
float[][] phos_two = new float[length_NA+1][3]; // arrays of coordinatess for anti-parallel strand phosphates  [atom number], [x,y,z]
float[][] centerax = new float[length_NA+1][3]; // [atom number], [x,y,z] data for the central axis 
float radius; float twist; float rise; float tilt; float axis; float helixspace; int len;//initialize vars


float xpos=0; float ypos=0;
float xdrag=0; float ydrag=0;
float xvect=0; float yvect=0;
float com_x=0; float com_y=0; float com_z=0;
int mousepress_set=0;


import controlP5.*;
ControlP5 cp5;  //invoke GUI controls

void setup() {
   size(1000, 700, OPENGL); //set the window size, 3D viewer

   cp5 = new ControlP5(this);
   cp5.setAutoDraw(false);
   
          cp5.addSlider("anglechangeX",-1,1,20,10,15,50) //min,max,posx,posy,width,height
             .setLabel("X Spin")
             .setValue(.33)
             .setNumberOfTickMarks(7);
          cp5.addSlider("anglechangeY",-1,1,100,10,15,50)
             .setLabel("Y Spin")
             .setValue(0)
             .setNumberOfTickMarks(7);
          cp5.addSlider("anglechangeZ",-1,1,180,10,15,50)
             .setLabel("Z Spin")
             .setValue(0)
             .setNumberOfTickMarks(7);              
          cp5.addSlider("viewangleX",0,180,20,90,15,50)
             .setLabel("X Angle")
             .setValue(0)
             .setNumberOfTickMarks(25)
             .showTickMarks(false);
          cp5.addSlider("viewangleY",0,180,100,90,15,50)
             .setLabel("Y Angle")
             .setValue(0)
             .setNumberOfTickMarks(25)
             .showTickMarks(false);
          cp5.addSlider("viewangleZ",0,180,180,90,15,50)
             .setLabel("Z Angle")
             .setValue(0)
             .setNumberOfTickMarks(25)
             .showTickMarks(false);        
          cp5.addSlider("style",1,4,250,25,130,15)
             .setLabel("Wire       Solid         Axis      Solid-Axis")
             .setValue(1)
             .setNumberOfTickMarks(4)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("style").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("style").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addKnob("zoomlevel",1,30,260,80,60) //min, max, posx, posy, diam
             .setLabel("Zoom")
             .setValue(9)
             .setDragDirection(Knob.HORIZONTAL);    
             
          cp5.addSlider("len",1,length_NA,420,25,100,15)
             .setLabel("Length of Helix")
             .setValue(22); 
          cp5.getController("len").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("len").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addSlider("polymer",1,3,420,100,100,15)
             .setLabel("RNA              DNA              LNA")
             .setValue(2)
             .setNumberOfTickMarks(3)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("polymer").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("polymer").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addToggle("showatoms")
             .setLabel("Phospate Atoms ON/OFF")
             .setPosition(620,20)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);

          cp5.addToggle("showaxis")
             .setLabel("Central Axis ON/OFF")
             .setPosition(620,70)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
             
          cp5.addToggle("persp_mode")
             .setLabel("Perspective ON/OFF")
             .setPosition(620,120)
             .setSize(50,15)
             .setValue(false)
             .setMode(ControlP5.SWITCH);             

 smooth();
 }
 
void draw() {
  
     background(200);  //reset the backgound between frame renders
  
     switch(persp_mode) {  //pick perspective or orthographic mode
      case 1:
        perspective();
        break;
      case 0:
        ortho();
        break;
     }

  if (mousePressed==true) {
    if (mousepress_set==1) {
      if(mouseY>180) {
         xvect=mouseX-xdrag+xpos;
         yvect=mouseY-ydrag+ypos;
      }
    }   else {
    mousepress_set=1;
    xdrag=mouseX;
    ydrag=mouseY;
    }
  }
  
  if (xvect<-90) {xvect=-90;}
  if (xvect>180) {xvect=180;}
  if (yvect<-90) {yvect=-90;}
  if (yvect>90) {yvect=90;}
  
  if(mousePressed==false) {
    mousepress_set=0;
    xdrag=0;
    ydrag=0;
    xpos=xvect;
    ypos=yvect;
  }




     switch(polymer) {   //set the polymer type
     case 1: //RNA
       radius = 8.7; twist = 32.73; rise = 2.81; tilt = -7.452; axis = 139.9; helixspace = 22.0;
       break;    
     case 2: //DNA
       radius = 8.2; twist = 34.3; rise = 3.4; tilt = 0.5; axis = 133.0; helixspace = 19.5;
       break;
     case 3: //LNA
       radius = 11.0; twist = 25.7; rise = 3.8; tilt = -3; axis = 110.0; helixspace = 26.0;
       break;
     }
  
  float helixangle=0;      // sets the initial helix angle
  float aphelixangle=axis; //initialize the antiparallel angle to axis

  for (int i=1; i<len+1; i++) {  //fill in the arrays with data points
    helixangle = i*twist ;       //calculates the angle of the bp
    phos_one[i][0] = i*rise - ((len+1)/2)*rise;                      //x
    phos_one[i][1] = radius*(float)Math.cos(helixangle*DEG_TO_RAD);   //y
    phos_one[i][2] = radius*(float)Math.sin(helixangle*DEG_TO_RAD);   //z
    
    aphelixangle = helixangle + axis; //the antiparallel strand is based on the axis angle
    phos_two[i][0] = i*rise + tilt - ((len+1)/2)*rise;               //x
    phos_two[i][1] = radius*(float)Math.cos(aphelixangle*DEG_TO_RAD); //y
    phos_two[i][2] = radius*(float)Math.sin(aphelixangle*DEG_TO_RAD); //z
    
    centerax[i][0] = i*rise + tilt/2 - ((len+1)/2)*rise;             //x
    centerax[i][1] = 0;                                               //y
    centerax[i][2] = 0;                                               //z
  } 
  
   
      beginCamera();
      camera();
      
      noStroke();
      fill(50,50,100,200);
      rect(0,0,width,180); //draw the top box for controls
      cp5.draw();
      
      
      translate(width/2,(3*height)/5,0);
      rotateX(-yvect*DEG_TO_RAD);
      rotateY(xvect*DEG_TO_RAD);
      translate(-width/2,-(3*height)/5,0);
      endCamera();
  
  
  
      pushMatrix();  //
         translate(width/2,(3*height)/5,0);  //first move to the center of the viewing window
         scale(zoomlevel);                     //next set the render scale for RNA
         rotateX(viewangleX*DEG_TO_RAD);   //horizontal axis 
         rotateY(viewangleY*DEG_TO_RAD);      //vertical axis
         rotateZ(-viewangleZ*DEG_TO_RAD);  //plane axis   
         drawhelix();                    //go and draw the helix  
      popMatrix();
      
      switch(showatoms) {     // decide to show atom spheres
         case 1:
           for (int i=1; i<len+1; i++) {
              pushMatrix();
                translate(width/2,(3*height)/5,0);  //translate to the center of the viewing window
                scale(zoomlevel); //set the render scale for RNA
                rotateX(viewangleX*DEG_TO_RAD); //horizontal axis 
                rotateY(viewangleY*DEG_TO_RAD); //vertical axis
                rotateZ(-viewangleZ*DEG_TO_RAD); //plane axis

                translate(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);
                noStroke();
                fill(100,100,200);  //sets sphere color
                sphereDetail(10);    //reduces the sphere resolution, defaul=30
                sphere(1.5);
                translate(phos_two[i][0]-phos_one[i][0], phos_two[i][1]-phos_one[i][1], phos_two[i][2]*inverter-phos_one[i][2]*inverter);
                sphereDetail(10);    //reduces the sphere resolution, defaul=30
                sphere(1.5);
              popMatrix();
           }
           break;
         default: //otherwise don't show atoms
           break;
      }
      
      viewangleX += anglechangeX;  //increment the viewing angle
      viewangleY += anglechangeY;
      viewangleZ += anglechangeZ;
}

void drawhelix()
{      
      noFill();
      beginShape(LINES);
      stroke(0);
      strokeWeight(1);
      for (int i=1; i<len; i++) {
         vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);    //draw main backbone strand
         vertex(phos_one[i+1][0], phos_one[i+1][1], phos_one[i+1][2]*inverter); 
         vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);    //draw antiparallel strand
         vertex(phos_two[i+1][0], phos_two[i+1][1], phos_two[i+1][2]*inverter);
       }
      endShape();
     
      switch(showaxis) {   
        case 1:           // decide if the axis is to be shown
          noFill();
          beginShape();
            for (int i=1; i<len+1; i++) {
               vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter); //draw axis
            }
          endShape();
          break;
        default:
          break;
      }

      switch(style) {
       case 1:  //draw wireframe
         beginShape(LINES);
         for (int i=1; i<len+1; i++) {
            stroke(0);
            strokeWeight(1);
            vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter); //draw base pairs
            vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
          }
         endShape();
         break;
       case 2:  //draw solid style, and base pairs
         for (int i=1; i<len; i++) {
           beginShape(TRIANGLE_FAN);
           fill(10,10,200,50);  //set the solid color and alpha
           noStroke();
           vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter); //draw solid regions
           vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
           vertex(phos_two[i+1][0], phos_two[i+1][1], phos_two[i+1][2]*inverter);
           vertex(phos_one[i+1][0], phos_one[i+1][1], phos_one[i+1][2]*inverter);
           vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);
           endShape(CLOSE);
         }
         beginShape(LINES);
         for (int i=1; i<len+1; i++) {
            stroke(0);
            strokeWeight(1);
            vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter); //draw base pairs 
            vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
          }
         endShape();
           break;
       case 3:  //draw wireframe through axis style
         beginShape(LINES);
              for (int i=1; i<len+1; i++) {
                stroke(2);
                vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter); //draw base pairs through the center axis
                vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
                vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
                vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
              }
         endShape(); 
         break;
       case 4:  //draw solid axis style
         for (int i=1; i<len; i++) {
            beginShape(TRIANGLE_FAN);
            fill(10,10,200,50);
            noStroke();
            vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);
            vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
            vertex(centerax[i+1][0], centerax[i+1][1], centerax[i+1][2]*inverter); 
            vertex(phos_one[i+1][0], phos_one[i+1][1], phos_one[i+1][2]*inverter);   
            vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);
            endShape(CLOSE);
         }
         for (int i=1; i<len; i++) {
            beginShape(TRIANGLE_FAN);
            fill(10,10,200,50);
            noStroke();
            vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
            vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
            vertex(centerax[i+1][0], centerax[i+1][1], centerax[i+1][2]*inverter); 
            vertex(phos_two[i+1][0], phos_two[i+1][1], phos_two[i+1][2]*inverter);   
            vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
            endShape(CLOSE);
         }  
         beginShape(LINES);
           for (int i=1; i<len+1; i++) {
             stroke(2);
             vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter); //draw base pairs through the center axis
             vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
             vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
             vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
           }
        endShape(); 
        break;
       
      }
}

