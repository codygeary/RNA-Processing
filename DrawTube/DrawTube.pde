/**
 * Draw Nanotube version 0.232b  (fixed phosphate positioning)
 * by Cody Geary
 * 17 July 2013
 *
 * Generates RNA or DNA helices and calculates multiple half-crossovers and plots it in P3D
 *    new subroutines generate arbitrary nanotubes.  Stress estimation and Clash detection. 
 *    Negative domain size for RNA,  Yellow 3' ends.
 */

//Initialize variables
int length_NA = 60; // Set the length of the single-strand, = 4*helical turn,  initialized for LNA since it sets the array size
int num_helix = 60; // Set the total number of helices in the tube, must be even, imposed by slider, set to max for array initilization
int polymer = 2 ;   // (1) RNA,  (2) DNA, (3) LNA
int style = 2 ;     // (1) backbone (2) base-pairs (3) Solid-axis
boolean showaxis = true  ; // (1) axis, (0) no axis
boolean showatoms = false ; // (1) show spheres, (0) no spheres
boolean persp_mode = false; // (1) perspective, (0) orthographic projection
boolean color_mode = true; // (1) color chains (0) color repeat units
boolean clash_mode = true; //clash mode shows large red spheres where a clash between phosphates is detected, does not detect other clashes.
int domain_a = 10;  // set the domain a,c length   domain b,d = 2*helical turn - domain a
int domain_b = 10; 
int domain_c = 10;
int domain_d = 10;
int curve_dir = 1;   // sets the curvature of the tube, either positive or negative for tubes, or zero for a sheet
int spiral_offset = 0; // 0: the units make cylinders, +n: spirals upwards by n units/turn , -n spirals backwards
int force_geom = 1; // (0) show the natural curve, (1) force into a tube or sheet
int repeats = 3;   //number of repeat units to show
boolean stress_view;

float viewangleX = 90; float viewangleY = 180; float viewangleZ = 90;   
float viewangleXtemp = 0; float viewangleYtemp=0; float viewangleZtemp=0;
float zoomlevel = 9; float zoomset=2;   // zoom level of the display
float anglechangeX = 0; // sets the rotation angle step size, set to 0 for stationary
float anglechangeY = 0; 
float anglechangeZ = 0;
int inverter = -1;      // Flips the right-handed coordinates into left-handed for displaying

// Initialize Arrays for drawing helices 
//
float[][] phos = new float[length_NA*num_helix][3];     // array of coordinatess for the base pairing approximating the sugar  [atom number], [x,y,z] 
float[][] phosphate = new float[length_NA*num_helix][3];    // array of the verticies for calculated phosphate positions
float[][] centerax = new float[length_NA*num_helix][3]; // [atom number], [x,y,z] data for the central axis 
float[] anglelist = new float[length_NA*num_helix];     // remembers the ref angle at each phosphate
boolean[] strand_break = new boolean[length_NA*num_helix]; // stores the TER info for each strand
boolean[] clash = new boolean[length_NA*num_helix]; //stores if a phosphate is clashing with another
  
float radius; float twist; float rise; float tilt; float axis; float helixspace; // variables for helix parameters
int len=length_NA; int strand_dir = 1; float axis_x = 0; float axis_y = 0;// variables for drawing the strands
float P_size;  //phosphate radius
float L_thick; float linethickness; //Lthick scales line thickness

float unit_size = 0; float stress = 1; float tweak = 0; float clash_thresh;

//Initialize global vars for mouse support
float xpos=0; float ypos=0;
float xdrag=0; float ydrag=0;
float xvect=0; float yvect=0;
int mousepress_set=0;

//Initialize checksum
float checksum=0;  float boolchecksum=0;

import controlP5.*;
ControlP5 cp5;  //import GUI controls
Slider2D slider;  // special controls for the 2D slider
Textarea myTextarea;  //initialize text box

PrintWriter output;  //invoke PrintWriter, which lets us output to text, the control for this output is called 'output'


//
//   End of Initialization
//

void setup() {
   size(1200, 760, P3D); //Set the window size, 3D viewer
   smooth();
   
   // Create a new file in the sketch directory
   output = createWriter("positions.txt");    //this creates a new file in the sketch dir called positions.txt
   
   length_NA = 42;
   drawGUI();  //go and draw the GUI
}

void draw() {
     
     checkmouse();  
  
     background(200);  //reset the backgound between frame renders
     zoomlevel = zoomset*zoomset;  //converts the linear zoomset input to exponential effect for the window zoom
     
     if(persp_mode) {  //pick perspective or orthographic mode
        float cameraZ = (height/2) / tan(PI/6);
        perspective(PI/3, float(width)/float(height),cameraZ/10, cameraZ*20);
     } else {   ortho();}


     switch(polymer) {   //set the polymer type
     case 1: //RNA
       radius = 8.7; twist = 32.73; rise = 2.81; tilt = -7.452; axis = 139.9; helixspace = 23.06;
       break;    
     case 2: //DNA
       radius = 9.3; twist = 34.48; rise = 3.4; tilt = 3.75; axis = 170.4; helixspace = 25.1;
       break;
     }
     
     //recalculate the vars length_NA and domain_b now that the polymer has been picked
     length_NA = round(2*(360/twist))*2;

     domain_b = length_NA/2 - domain_a;    
     domain_c = length_NA/2 - domain_d;
    
    boolchecksum=0;
    if (force_geom==1) {boolchecksum += 2;}
    if (stress_view) {boolchecksum += 3;}  
    if (clash_mode) {boolchecksum+= 5;}
     
    if (checksum==repeats+domain_a+domain_d+polymer+curve_dir+tweak+spiral_offset+num_helix+boolchecksum)
     {} else {calculate_helix(); }//go calculate the coordinates of the helices

    //Rotate the camera as controlled by the mouse
    
      beginCamera();
      camera();
       
       //draw all the 2D things here
     noStroke();
     fill(50,50,100,200);
     rect(0,0,width,180); //draw the top box for GUI controls       
      cp5.draw();

      translate(width/2,(height-150)/2+150,-500);
      rotateX(-yvect*DEG_TO_RAD);
      if (curve_dir==0) {rotateZ(xvect*DEG_TO_RAD);} else {rotateY(xvect*DEG_TO_RAD);}
      translate(-width/2,-(height-150)/2-150,500);
      endCamera();
      


      pushMatrix();  //translate the viewing window
         translate(width/2,(3*height)/5,-500);  //first move to the center of the viewing window
         translate((slider.getArrayValue()[0]-50)*2*zoomlevel,(slider.getArrayValue()[1]-50)*2*zoomlevel,0); //allow translation from the 2D controller
         scale(zoomlevel);                     //set the render scale for RNA, controlled by a knob
         rotateX(viewangleX*DEG_TO_RAD);    
         rotateY(viewangleY*DEG_TO_RAD);      //variable tweak rotates the model a bit, so this compensates
         rotateZ(-viewangleZ*DEG_TO_RAD);   
         drawhelix();                     //GO and draw the helix backbone and fill
      popMatrix();
      

      viewangleYtemp = (viewangleY + anglechangeY)%360;        //update barrel rolling
      cp5.getController("viewangleY").setValue(viewangleYtemp);  //update gui slider with the new barrel angle
      
            
         int colorvalue = 50;
         if((showatoms) || (clash_mode)) {     // decide to show atom spheres
          for (int n=0; n<repeats; n++) {
          unit_size = n*(length_NA/2*rise);
          
           for (int i=1; i<(length_NA*num_helix); i++) {  //cycle through all the Ps and translate each!
              if ((stress_view)) {
                fill(abs(stress-1)*300-60,0,260-abs(stress-1)*400-60);
                } else {
                 if (color_mode) {
                   fill(colorvalue-80,colorvalue-40,190-colorvalue);
                   } else {
                   fill(colorvalue-60,colorvalue-20,170-colorvalue); //make the chains brighter for repeat unit mode
                 }
                }
                
                pushMatrix();
                translate(width/2,(3*height)/5,-500);  //CAREFUL, keep all the tranlate and scales the same as above!!
                translate((slider.getArrayValue()[0]-50)*2*zoomlevel,(slider.getArrayValue()[1]-50)*2*zoomlevel,0);
                scale(zoomlevel); 
                rotateX(viewangleX*DEG_TO_RAD);  
                rotateY(viewangleY*DEG_TO_RAD);
                rotateZ(-viewangleZ*DEG_TO_RAD); 
                translate(phosphate[i][0] + unit_size, phosphate[i][1], phosphate[i][2]*inverter);  //remember, inverter makes the coordinates right-handed!
                noStroke();
                sphereDetail(6);    //reduces the sphere resolution, default=30, saves computer power 
                

              if (showatoms){           
                if ((strand_break[i]) || (i<1)) {
                  fill(250,200,0);  //make the 5' end of each strand yellow
                  colorvalue=colorvalue+200/num_helix;  //rotate the color value for the next strand
                  sphere(P_size*1.3);
                } else {
                  sphere(P_size);
                }
              }
              if ((clash[i]) && (clash_mode))  {
                fill(250,0,0,170);
                sphereDetail(8);
                sphere(3.5);
              }     
   
                popMatrix();
           }
           colorvalue=50;
          }
      }
}
