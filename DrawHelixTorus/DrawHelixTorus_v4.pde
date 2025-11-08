/**
 * Draw Helix on a Toroid Surface
 * by Cody Geary
 * 8 January 2014
 *
 * Generates an RNA or DNA helix of specified length and plots it in P3D
 */

// ***Settings***=
int length_NA = 150; //set the max length, to calculate
float polymer = 0 ;   // (0) RNA,  (1) DNA
int style = 2 ;     // (1) wireframe, (2) solid, (3) wire with bps through axis, (4) solid axis
int showaxis = 1  ; // (1) axis, (0) no axis
int showatoms = 0 ; // (1) show spheres, (0) no spheres
int persp_mode = 0; // (1) perspective, (0) orthographic projection
int inverter = -1; //this flips the right-handed coordinates into left-handed for displaying
int show_tor = 0;

float torus_rad = 70; // initial radius of the torus, set large to approximate a cylinder
float phase = 0;  // sets the rotational phase of the first bp, goes from 0 to 1 which spans 1 bp of twist

float viewangleX = 0;   // horizontal axis
float viewangleY = 0;   // vertical axis
float viewangleZ = 0;   // in-plane axis
float zoomlevel = 9;
float anglechangeX = 1;  // sets the rotation angle step size, set to 0 for stationary
float anglechangeY = 0; 
float anglechangeZ = 0;
float curve =1;
float torusangle=0;
float anglestep=1;
float sugaroffset=0;
float sugartwistoffset=0; float sugarradius=1;

// Initialize Arrays for drawing helices
float[][] sugar_one = new float[length_NA+1][3];
float[][] sugar_two = new float[length_NA+1][3];
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
   size(1000, 700, P3D); //set the window size, 3D viewer

   cp5 = new ControlP5(this);
   
           cp5.addSlider("style",1,4,250,25,130,15)
             .setLabel("Wire       Solid         Axis      Solid-Axis")
             .setValue(1)
             .setNumberOfTickMarks (4)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("style").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("style").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addKnob("zoomlevel",1,30,260,80,60) //min, max, posx, posy, diam
             .setLabel("Zoom")
             .setValue(9)
             .setDragDirection(Knob.HORIZONTAL);    
             
          cp5.addSlider("len",1,length_NA,420,20,150,15)
             .setLabel("Length of Helix")
             .setValue(22); 
          cp5.getController("len").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("len").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addSlider("curve",0,90,420,60,150,15)
             .setLabel("Curvature per Turn")
             .setValue(0); 
          cp5.getController("curve").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("curve").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addSlider("phase",0,1,420,100,150,15)
             .setLabel("Phase")
             .setValue(0); 
          cp5.getController("phase").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("phase").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);


          cp5.addSlider("polymer",0,1,420,140,150,15)
             .setLabel("A-form RNA                     B-form DNA")
             .setValue(0)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("polymer").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("polymer").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addToggle("showatoms")
             .setLabel("Phospates ON/OFF")
             .setPosition(620,15)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);

          cp5.addToggle("showaxis")
             .setLabel("Central Axis ON/OFF")
             .setPosition(620,60)
             .setSize(50,15)
             .setValue(false)
             .setMode(ControlP5.SWITCH);
             
          cp5.addToggle("persp_mode")
             .setLabel("Perspective ON/OFF")
             .setPosition(620,100)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);             

          cp5.addToggle("show_tor")
             .setLabel("Show Torus ON/OFF")
             .setPosition(620,140)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);             


 smooth();
 }
 
void draw() {
     
     background(200);  //reset the backgound between frame renders
     noStroke();
     fill(50,50,100,200);
     rect(0,0,width,180); //draw the top box for controls
  
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


       float RNA_radius = 8.7;
       float RNA_twist = 32.73; 
       float RNA_rise = 2.81; 
       float RNA_tilt = -7.452; 
       float RNA_axis = 139.9; 
       float RNA_helixspace = 22.0; 
       float RNA_sugaroffset=-.2; 
       float RNA_sugartwistoffset=.9; 
       float RNA_sugarradius=RNA_radius;

       float DNA_radius = 8.2;
       float DNA_twist = 34.3;
       float DNA_rise = 3.4;
       float DNA_tilt = 0.5;
       float DNA_axis = 133.0;
       float DNA_helixspace = 19.5;
       float DNA_sugaroffset=.6;
       float DNA_sugartwistoffset=.5;
       float DNA_sugarradius=DNA_radius*.75;

       radius=(1-polymer)*(RNA_radius)+polymer*(DNA_radius);
       twist=(1-polymer)*(RNA_twist)+polymer*(DNA_twist);
       rise=(1-polymer)*(RNA_rise)+polymer*(DNA_rise);
       tilt=(1-polymer)*(RNA_tilt)+polymer*(DNA_tilt);
       axis=(1-polymer)*(RNA_axis)+polymer*(DNA_axis);
       helixspace=(1-polymer)*(RNA_helixspace)+polymer*(DNA_helixspace);
       sugaroffset=(1-polymer)*(RNA_sugaroffset)+polymer*(DNA_sugaroffset);
       sugartwistoffset=(1-polymer)*(RNA_sugartwistoffset)+polymer*(DNA_sugartwistoffset);
       sugarradius=(1-polymer)*(RNA_sugarradius)+polymer*(DNA_sugarradius);

     
    //convert angular curvature per turn to a radius for the torus
    torus_rad = (360*360*rise)/(twist*2*PI*(curve+.001));
 
  
  float helixangle=0;      // sets the initial helix angle
  float aphelixangle=axis; //initialize the antiparallel angle to axis
  anglestep=(rise/(2*3.141592*torus_rad))*360; //calculate the angular step size for parameter v
  torusangle=0;
  float aptorusangle;
  float sugarangle=0;
  float apsugarangle=0;
  float centerangle;
  com_x=0; com_y=0; com_z=0;
  
  for (int i=1; i<len+1; i++) {  //fill in the arrays with data points
    helixangle = (i*twist)+phase*360 ;       //calculates the angle of the main strand phophate
    torusangle = (i*anglestep);
    
    phos_one[i][0] = sin(torusangle*DEG_TO_RAD)*(radius*cos(helixangle*DEG_TO_RAD)+torus_rad);          //x
    phos_one[i][1] = cos(torusangle*DEG_TO_RAD)*(radius*cos(helixangle*DEG_TO_RAD)+torus_rad);   //y
    phos_one[i][2] = sin(helixangle*DEG_TO_RAD)*radius;   //z
    
    aphelixangle = helixangle + axis + twist; //the antiparallel strand is based on the axis angle, 1 extra twist unit is added
    aptorusangle = (i*anglestep+anglestep+(360*tilt)/(2*3.141592*torus_rad));
    
    phos_two[i][0] = sin(aptorusangle*DEG_TO_RAD)*(radius*cos(aphelixangle*DEG_TO_RAD)+torus_rad);          //x
    phos_two[i][1] = cos(aptorusangle*DEG_TO_RAD)*(radius*cos(aphelixangle*DEG_TO_RAD)+torus_rad);   //y
    phos_two[i][2] = sin(aphelixangle*DEG_TO_RAD)*radius;   //z

    //now increment 1/2 anglestep to put in the sugars

    centerangle = (i*anglestep+anglestep/2+(360*tilt)/(2*2*3.141592*torus_rad));
    
    centerax[i][0] = sin(centerangle*DEG_TO_RAD)*(torus_rad);             //x
    centerax[i][1] = cos(centerangle*DEG_TO_RAD)*(torus_rad);                                               //y
    centerax[i][2] = 0;                                               //z

    //now draw the sugars, also add sugaroffset factor to anglestep from the phosphates

    sugarangle = (i*twist+twist*sugartwistoffset)+phase*360 ;       //calculates the angle of the bp
    torusangle = (i*anglestep+anglestep*sugaroffset);
    
    sugar_one[i][0] = sin(torusangle*DEG_TO_RAD)*(sugarradius*cos(sugarangle*DEG_TO_RAD)+torus_rad);          //x
    sugar_one[i][1] = cos(torusangle*DEG_TO_RAD)*(sugarradius*cos(sugarangle*DEG_TO_RAD)+torus_rad);   //y
    sugar_one[i][2] = sin(sugarangle*DEG_TO_RAD)*sugarradius;   //z
    
    apsugarangle = helixangle + axis + twist*(1-sugartwistoffset); //the antiparallel strand is based on the axis angle, 1 extra twist unit is added
    aptorusangle = (i*anglestep+anglestep*(1-sugaroffset)+(360*tilt)/(2*3.141592*torus_rad));
    
    sugar_two[i][0] = sin(aptorusangle*DEG_TO_RAD)*(sugarradius*cos(apsugarangle*DEG_TO_RAD)+torus_rad);          //x
    sugar_two[i][1] = cos(aptorusangle*DEG_TO_RAD)*(sugarradius*cos(apsugarangle*DEG_TO_RAD)+torus_rad);   //y
    sugar_two[i][2] = sin(apsugarangle*DEG_TO_RAD)*sugarradius;   //z
    
    //now add to center-of-mass counters, only for the phosphates
    com_x += (phos_one[i][0] + phos_two[i][0] + centerax[i][0]);
    com_y += (phos_one[i][1] + phos_two[i][1] + centerax[i][1]);
    com_z += (phos_one[i][2] + phos_two[i][2] + centerax[i][2]);    
  } 
  
   com_x = com_x/(len*3); //now divide the counters by the length to get the center of mass
   com_y = com_y/(len*3);
   com_z = com_z/(len*3);
  
   for (int i=1; i<len+1; i++) {  // go back through the data array and offset things by the center of mass just calculated
   phos_one[i][0] += -com_x;
   phos_one[i][1] += -com_y;
   phos_one[i][2] += -com_z;
   
   phos_two[i][0] += -com_x;
   phos_two[i][1] += -com_y;
   phos_two[i][2] += -com_z;
   
   centerax[i][0] += -com_x;
   centerax[i][1] += -com_y;
   centerax[i][2] += -com_z;

   sugar_one[i][0] += -com_x;
   sugar_one[i][1] += -com_y;
   sugar_one[i][2] += -com_z;
   
   sugar_two[i][0] += -com_x;
   sugar_two[i][1] += -com_y;
   sugar_two[i][2] += -com_z;
   
   }
   
      pushMatrix();  //
         translate(width/2,(3*height)/5,0);  //first move to the center of the viewing window
         scale(zoomlevel);                     //next set the render scale for RNA
         
         rotateX(-yvect*DEG_TO_RAD);
         rotateY(xvect*DEG_TO_RAD);
         
         drawhelix();                    //go and draw the helix  
      popMatrix();
      
      switch(showatoms) {     // decide to show atom spheres
         case 1:
           for (int i=1; i<len+1; i++) {
              pushMatrix();
                translate(width/2,(3*height)/5,0);  //translate to the center of the viewing window
                scale(zoomlevel); //set the render scale for RNA
                rotateX(-yvect*DEG_TO_RAD);
                rotateY(xvect*DEG_TO_RAD);
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
}

void drawhelix()
{      
      noFill();
      beginShape(LINES);
      stroke(0);
      strokeWeight(0.5);
      for (int i=1; i<len; i++) {
         vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);    //draw main backbone strand
         vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter);
         
         vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter);
         vertex(phos_one[i+1][0], phos_one[i+1][1], phos_one[i+1][2]*inverter); 
         
         vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);    //draw antiparallel strand
         vertex(sugar_two[i+1][0], sugar_two[i+1][1], sugar_two[i+1][2]*inverter);
         
         vertex(sugar_two[i+1][0], sugar_two[i+1][1], sugar_two[i+1][2]*inverter);
         vertex(phos_two[i+1][0], phos_two[i+1][1], phos_two[i+1][2]*inverter);
       }

         vertex(phos_two[1][0], phos_two[1][1], phos_two[1][2]*inverter);    //draw the 3' ends, sloppy implementation!
         vertex(sugar_two[1][0], sugar_two[1][1], sugar_two[1][2]*inverter);
         
         vertex(sugar_one[len][0], sugar_one[len][1], sugar_one[len][2]*inverter);
         vertex(phos_one[len][0], phos_one[len][1], phos_one[len][2]*inverter); 

       
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
    
     switch(show_tor) {
       case 1:
         noFill();
         strokeWeight(.1);
         int subs=ceil(360/anglestep);
         println (torus_rad, subs);
         if (torus_rad<2000) {
         for(int i=0; i<subs+1; i++) {
           torusangle=i*anglestep;
             beginShape();
              for (int j=0; j<21; j++) {   //draw a circle at each subdivision           
                 vertex (sin(torusangle*DEG_TO_RAD)*(radius*cos((360*j/20)*DEG_TO_RAD)+torus_rad)-com_x,cos(torusangle*DEG_TO_RAD)*(radius*cos((360*j/20)*DEG_TO_RAD)+torus_rad)-com_y,-sin((360*j/20)*DEG_TO_RAD)*radius+com_z);   
              }
              endShape();
           }
         }
               
         break;
         default:
         break;
     } 

      switch(style) {
       case 1:  //draw wireframe
         beginShape(LINES);
         for (int i=1; i<len+1; i++) {
            stroke(0);
            strokeWeight(.2);
            vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter); //draw base pairs
            vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
          }
         endShape();
         break;
       case 2:  //draw solid style, and base pairs
         for (int i=1; i<len; i++) {
           beginShape(TRIANGLE_FAN);
           fill(10,10,200,60);  //set the solid color and alpha
           noStroke();
           vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter); //draw solid regions
           vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
           vertex(sugar_two[i+1][0], sugar_two[i+1][1], sugar_two[i+1][2]*inverter);
           vertex(phos_one[i+1][0], phos_one[i+1][1], phos_one[i+1][2]*inverter);
           vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter);
           endShape(CLOSE);
         }
         
         for (int i=1; i<len+1; i++) {           
           beginShape(TRIANGLE);
           fill(10,10,200,50);  //set the solid color and alpha
           noStroke();
           vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
           vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);
           vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter);

           vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter);
           vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
           vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
           endShape(CLOSE);              
         }
         beginShape(LINES);
         for (int i=1; i<len+1; i++) {
            stroke(0);
            strokeWeight(.4);
            vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter); //draw base pairs 
            vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
          }
         endShape();
           break;
       case 3:  //draw wireframe through axis style
         beginShape(LINES);
              for (int i=1; i<len+1; i++) {
                stroke(0);
                strokeWeight(.3);
                vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter); //draw base pairs through the center axis
                vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
                vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
                vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
              }
         endShape(); 
         break;
       case 4:  //draw solid axis style
         for (int i=1; i<len; i++) {
            beginShape(TRIANGLE_STRIP);
            fill(10,10,200,50);
            noStroke();
            vertex(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);
            vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
            vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter);
            vertex(centerax[i+1][0], centerax[i+1][1], centerax[i+1][2]*inverter); 
            vertex(phos_one[i+1][0], phos_one[i+1][1], phos_one[i+1][2]*inverter);   
            endShape(CLOSE);
         }
         for (int i=2; i<len+1; i++) {
            beginShape(TRIANGLE_STRIP);
            fill(10,10,200,50);
            noStroke();
            vertex(phos_two[i][0], phos_two[i][1], phos_two[i][2]*inverter);
            vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
            vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
            vertex(centerax[i-1][0], centerax[i-1][1], centerax[i-1][2]*inverter); 
            vertex(phos_two[i-1][0], phos_two[i-1][1], phos_two[i-1][2]*inverter);   
            endShape(CLOSE);
     }      
         beginShape(LINES);
           for (int i=1; i<len+1; i++) {
             stroke(1);
             strokeWeight(.3);
             vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter); //draw base pairs through the center axis
             vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
             vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
             vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
           }
        endShape(); 
        break;
       
      }
}

