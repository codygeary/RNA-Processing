/**
 * Draw Helix on a Sphere Surface
 * by Cody Geary
 * 22 January 2014
 *
 * Generates an RNA or DNA helix of specified length and plots it in P3D
 *
 *  Keyboard controls (up/down : phase,  left/right : #wraps)
 *  SHIFT: Output Coordinate File
 */

// ***Settings***=
int length_NA = 7500; //set the max length, to calculate
int polymer = 1 ;   // (1) RNA,  (2) DNA
int style = 2 ;     // (1) wireframe, (2) solid, (3) wire with bps through axis, (4) solid axis
int showaxis = 1  ; // (1) axis, (0) no axis
int showatoms = 0 ; // (1) show spheres, (0) no spheres
int persp_mode = 0; // (1) perspective, (0) orthographic projection
int inverter = -1; //this flips the right-handed coordinates into left-handed for displaying
boolean clash_mode=false; boolean show_clash=true;  boolean map=true; boolean crosspat=false;
float diameter=30.0; //diameter of the sphere
float sphere_rad = 70; //initial radius of the spheres, this is the variable we can change
float wraps=10; float torus_rad = 90;   float latitude=0.1;
float phase = 0;  // sets the rotational phase of the first bp, goes from 0 to 1 which spans 1 bp of twist
float clash_thresh=0.6;
float checksum=0;  //checksum used to detect when key variables are changed
float ellipse=1.5; //this number deformes the sphere
float trim= 10;
float fine_tune = 0; //fine tune spacing

int clashmodeon=1; float wrapinvert=1;
float zoomlevel = 9; float torusangle=0; float anglestep=1; float sugaroffset=0; float sugartwistoffset=0; float sugarradius=1;
float radius; float twist; float rise; float tilt; float axis; float helixspace; int len;//initialize vars
float xpos=0; float ypos=0;
float xdrag=0; float ydrag=0; float xvect=0; float yvect=0;
float com_x=0; float com_y=0; float com_z=0;
int mousepress_set=0;

// Initialize Arrays for drawing helices
float[][] sugar_one = new float[length_NA+1][3];
float[][] sugar_two = new float[length_NA+1][3];
float[][] phos_one = new float[length_NA+1][6]; // arrays of coordinatess for main-strand phosphates  [atom number], [x,y,z,latitude,longitude, ring#]
boolean[] clash = new boolean[length_NA+1];     // array of clashes used to detect crossover positions
float[][] clashpos = new float[length_NA+1][3]; // array of crossover connectivity data [pos1][pos2][dist]
float[][] phos_two = new float[length_NA+1][3]; // arrays of coordinatess for anti-parallel strand phosphates  [atom number], [x,y,z]
float[][] centerax = new float[length_NA+1][3]; // [atom number], [x,y,z] data for the central axis 
float[] wrapcount = new float[100]; //list of the nt# that a new wrap starts on, limited to 50Wraps for now!
float[] wraplength = new float[100]; //list of the width of each wrap

import controlP5.*;
ControlP5 cp5;  //invoke GUI controls

PrintWriter output;  //invoke PrintWriter, which lets us output to text, the control for this output is called 'output'
PImage world;  // create an name to load the world map onto with PImage

void setup() {
   size(1200, 750, P3D); //set the window size, 3D viewer
   //frame.setResizable(true);
   
   // Create a new file in the sketch directory
   output = createWriter("positions.txt");    //this creates a new file in the sketch dir called positions.txt
   output.println("Datafile of phosphate contact positions and distance in Angstroms");
   
  // The image file must be in the data folder of the current sketch to load successfully
  world = loadImage("world.jpg");  // Load the image into the program  
  calculatehelix();
  
  gui(); //go and setup the graphical interface elements
  
 smooth();
 } //end setup
 
void draw() {
     background(255);  //reset the backgound between frame renders
     noStroke();
     fill(100,100,100,200);
     rect(0,0,550,185); //draw the top box for controls

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
  
  if (xvect<-270) {xvect=-270;}  //keep the viewing angle between -270 and 270 for simplicity
  if (xvect>270) {xvect=270;}
  if (yvect<-270) {yvect=-270;}
  if (yvect>270) {yvect=270;}
  
  if(mousePressed==false) {
    mousepress_set=0;
    xdrag=0;
    ydrag=0;
    xpos=xvect;
    ypos=yvect;
  }

     switch(polymer) {   //set the polymer type
     case 1: //RNA
       radius = 8.7; twist = 32.73; rise = 2.81; tilt = -7.452; axis = 139.9; helixspace = 22.0; sugaroffset=-.2; sugartwistoffset=.9; sugarradius=radius;
       break;    
     case 2: //DNA
       radius = 8.2; twist = 34.3; rise = 3.4; tilt = 0.5; axis = 133.0; helixspace = 20.0; sugaroffset=.6; sugartwistoffset=.5; sugarradius=radius*.75;
       break;
     case 3: //LNA
       radius = 11.0; twist = 25.7; rise = 3.8; tilt = -3; axis = 110.0; helixspace = 26.0; sugaroffset=.5; sugartwistoffset=.5; sugarradius=radius*.8;
       break;
     }
     
  //   helixspace=helixspace*sqrt(ellipse);
   if (clash_mode) {clashmodeon=1;} else {clashmodeon=0;}
   
   if (diameter*wrapinvert+trim+phase+clash_thresh+len+polymer+clashmodeon+ellipse+fine_tune-checksum!=0) {
     calculatehelix();  //go calculate the helix, but only if variables have changed the checksum!
   }

  if (!crosspat) {
      pushMatrix();  //
         translate(width/2,(height-150)/2+150,-500);  //first move to the center of the viewing window
         scale(zoomlevel*zoomlevel);                     //next set the render scale for RNA
         
         rotateX(-yvect*DEG_TO_RAD);
         rotateY(xvect*DEG_TO_RAD);

         drawhelix();                    //go and draw the helix  

      popMatrix();
  } else { drawcrosspat();}  //if crosspat is active then draw the crossovers instead of the 3D
  
      if (map) {drawmap();} else {drawarcs();} // decide to draw the map or the arch diagrams
      
   if (!crosspat) {   //only show the spheres if not in the crossover pattern mode
      switch(showatoms) {     // decide to show atom spheres
         case 1:
           for (int i=1; i<len+1; i++) {
              pushMatrix();
                translate(width/2,(height-150)/2+150,-500);  //translate to the center of the viewing window
                scale(zoomlevel*zoomlevel); //set the render scale for RNA
                rotateX(-yvect*DEG_TO_RAD);
                rotateY(xvect*DEG_TO_RAD);
                translate(phos_one[i][0], phos_one[i][1], phos_one[i][2]*inverter);
                noStroke();
                fill(0,60,180);  //sets sphere color
                sphereDetail(6);    //reduces the sphere resolution, defaul=30
                sphere(1.5);
                
               if ((clash[i]) && (show_clash))  {  //display the clashes only for the phos-one strand
                fill(250,0,0,170);
                sphereDetail(8);
                sphere(3.5);
               }
                
                fill(0,60,180);  //sets sphere color                 
                translate(phos_two[i][0]-phos_one[i][0], phos_two[i][1]-phos_one[i][1], phos_two[i][2]*inverter-phos_one[i][2]*inverter);
                sphereDetail(6);    //reduces the sphere resolution, defaul=30
                sphere(1.5);           
              popMatrix();
           }
           break;
         default: //otherwise don't show atoms
           break;
      }  
   } //end if   
} //end draw

void keyPressed() { 
  if (key == CODED) {
    if (keyCode == LEFT) {diameter+=-.01; cp5.getController("diameter").setValue(diameter);}
    if (keyCode == RIGHT) {diameter+=.01;cp5.getController("diameter").setValue(diameter);}
    if (keyCode == DOWN) {phase+=-.01;cp5.getController("phase").setValue(phase);}
    if (keyCode == UP) {phase+=.01;cp5.getController("phase").setValue(phase);}    
    if (keyCode == SHIFT) {
          output.println("Polymer type (1=RNA, 2=DNA): " + polymer);
          output.println("Polymer length = " + len + " base pairs");
          output.println("Phase = " + phase);
          output.println("Diameter = " + diameter + " nm");
          output.println("Egg-Shape Ratio = " + ellipse);
          
       for (int i=1; i<floor(phos_one[len][5])+1; i++) {
             output.println("ROW " + (i) + " " + wraplength[i+1]);
       }
       
       for (int i=0; i<len+1; i++) {
          int posone=floor(clashpos[i][0]); int postwo=floor(clashpos[i][1]); float posthree=clashpos[i][2];
          int pos_in_row1=floor(floor(clashpos[i][0])-wrapcount[floor(phos_one[i][5])]+1);
          int pos_in_row2=floor(floor(clashpos[i][1])-wrapcount[floor(phos_one[floor(clashpos[i][1])][5])]+1);
        //  if (clashpos[i][0]!=0) { output.println(posone + ", " + postwo + ", " + posthree + ", " + phos_one[i][3] + "°, " + phos_one[i][4] +  "°, ring# " + phos_one[i][5]);}
          if (clashpos[i][0]!=0) { output.println(posone + ", " + postwo + ", " + posthree + ", Row " + floor(phos_one[i][5]) + " (" + pos_in_row1 + "), Row " + floor(phos_one[floor(clashpos[i][1])][5]) + " (" + pos_in_row2 + ")");}
       }
       
       /* output.println("BEGIN PDB coordinate output");   //PDB output currently muted
          output.println("Main Phosphate strand");
       for (int i=1; i<len+1; i++) {
          float posone=phos_one[i][0]; float postwo=phos_one[i][1]; float posthree=phos_one[i][2];
          output.println(i + ", " + posone + ", " + postwo + ", " + posthree);
       }
          output.println(" ");
          output.println("Antiparallel Phosphate strand (backwards direction)");
       for (int i=1; i<len+1; i++) {
          float posone=phos_two[i][0]; float postwo=phos_two[i][1]; float posthree=phos_two[i][2];
          output.println(i + ", " + posone + ", " + postwo + ", " + posthree);
       }
          output.println(" ");
          output.println("Center axis strand");
       for (int i=1; i<len+1; i++) {
          float posone=centerax[i][0]; float postwo=centerax[i][1]; float posthree=centerax[i][2];
          output.println(i + ", " + posone + ", " + postwo + ", " + posthree);
       } */
              
          output.flush();  // Writes the remaining data to the file
          output.close();  // Finishes the file
          println("output complete!");  
    }
  }
}

void drawhelix()
{        
      noFill();
      beginShape(LINES);
      stroke(0);
      strokeWeight(0.3);
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
           fill(0,90,220);  //set the solid color and alpha
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
           fill(5,95,240);  //set the solid color and alpha
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
            strokeWeight(.2);
            vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter); //draw base pairs 
            vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
          }
         endShape();
           break;
       case 3:  //draw wireframe through axis style
         beginShape(LINES);
              for (int i=1; i<len+1; i++) {
                stroke(1);
                strokeWeight(.2);
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
            fill(0,90,220,200);
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
            fill(0,90,220,200);
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
             strokeWeight(.2);
             vertex(sugar_one[i][0], sugar_one[i][1], sugar_one[i][2]*inverter); //draw base pairs through the center axis
             vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
             vertex(centerax[i][0], centerax[i][1], centerax[i][2]*inverter);
             vertex(sugar_two[i][0], sugar_two[i][1], sugar_two[i][2]*inverter);
           }
        endShape(); 
        break;       
      }
}

void drawarcs(){

float start=600;  //designates the start pixel of the line
  
noFill();

beginShape(LINES);  //draw the baseline for the helix
stroke(1); strokeWeight(1.5);
vertex(start,180,0); vertex(width-20,180,0);
endShape(); 

float bpstep=(width-start-20)/len;  //calculate how to divide up the line

float maxheight=0;
for (int i=0; i<len+1; i++) {
    if (clashpos[i][0]!=0) {
       if ((clashpos[i][1]-clashpos[i][0])>maxheight) {maxheight=clashpos[i][1]-clashpos[i][0];}
    }
}

for (int i=0; i<len+1; i++) {
    float posone=floor(clashpos[i][0]); float postwo=floor(clashpos[i][1]); float posthree=1-clashpos[i][2]/7;
    if (clashpos[i][0]!=0) {
      strokeWeight(posthree+.7); //line is thicker when the bond length is shorter
      stroke(200-255*posthree,0,600*posthree);  //color red for long bonds, blue for short bonds
      //arc is (xcenter, ycenter, width, height, start angle, end angle) 
      arc(start+(posone*bpstep)+(postwo-posone)*.5*bpstep,180.0, abs(postwo-posone)*bpstep, (abs(postwo-posone)/maxheight)*(180-20)*2, PI, 2*PI);
    }
}

}//end drawarcs

void drawmap() {
  float start=600.0;  //designates the start pixel of the line
  
  // Displays the image (x,y,width,height)
  image(world, start, 5.0, width-start-100, 180.0);  //display the "equirectangular" projection of the world
  fill(255,255,255,100);
  noStroke();
  rect(start,5.0, width-start-100,180.0); //draw the top box for controls

for (int i=0; i<len+1; i++) {
    if (clashpos[i][0]!=0) {      
      ellipseMode(CENTER);  // Set ellipseMode to CENTER
      fill(200-255*(1-clashpos[i][2]/7),0,600*(1-clashpos[i][2]/7));  //color red for long bonds, blue for short bonds
      ellipse(start+(phos_one[i][4]/360)*(width-start-100),((phos_one[i][3]+90)/180)*180.0+5.0, 5.0, 5.0);  // Draw gray ellipse using CENTER mode
    }
} 
}//end drawmap

void drawcrosspat() {
  
    pushMatrix();
    translate(width/2,height/2,0);
    scale(zoomlevel*zoomlevel/2);
    translate(2*(xvect)-width/2,2*(yvect)-height/2+180,0);
    
    wraps=ceil(ellipse*(sphere_rad*PI)/helixspace*wrapinvert );   //calculate the number of wraps in a sphere of sphere_rad
    
    float lineheight=(height-180)/(wraps+1);  //based on the #wraps calculate how tall to make each line
    float maxbplength=ceil(sphere_rad*2*PI/rise*wrapinvert);
    float bpwidth=(width-100)/maxbplength;
    
    noFill();

     stroke(0); strokeWeight(.5);

    beginShape(LINES);  //draw the baseline for the helix
    for (int i=1; i<len; i++) {   //draws the scaffold strand

      if( wrapcount[floor(phos_one[i][5])]-wrapcount[floor(phos_one[i+1][5])]<0 ) {strokeWeight(0);} else {strokeWeight(1);}  //makes a thinner line for the wraps
        vertex((i-wrapcount[floor(phos_one[i][5])])*bpwidth+50,floor(phos_one[i][5])*lineheight,-1);
        vertex(((i+1)-wrapcount[floor(phos_one[i+1][5])])*bpwidth+50,floor(phos_one[i+1][5])*lineheight,-1);
        
        strokeWeight(.3);
        vertex((i-wrapcount[floor(phos_one[i][5])])*bpwidth+50,floor(phos_one[i][5])*lineheight-1,-1);
        vertex((i-wrapcount[floor(phos_one[i][5])])*bpwidth+50,floor(phos_one[i][5])*lineheight+1,-1);
            
    }
    endShape();
    
    stroke(255,0,0);
    strokeWeight(.5);
        
    for (int i=1; i<len-1; i++) {  //draws the contacts in thicker red
      if (clashpos[i][0]!=0) {
       stroke(200-255*(1-clashpos[i][2]/7),0,600*(1-clashpos[i][2]/7));  //color red for long bonds, blue for short bonds
       //if( wrapcount[floor(phos_one[i][5])]-wrapcount[floor(phos_one[i+1][5])]<0 ) {strokeWeight(.5);} else {strokeWeight(1);}
        
        beginShape();

        vertex((i-wrapcount[floor(phos_one[i][5])])*bpwidth+50,floor(phos_one[i][5])*lineheight,-1);    //draw first segment
        vertex(((i+1)-wrapcount[floor(phos_one[i+1][5])])*bpwidth+50,floor(phos_one[i][5])*lineheight,-1);   //draw the angled connector
        int contact_two=floor( clashpos[i][1] + 1);
        int wrapcount_two=floor(wrapcount[ floor( phos_one[contact_two][5] ) ]);
        vertex( (contact_two-wrapcount_two)*bpwidth+50,floor(phos_one[contact_two][5])*lineheight,-1);    //draw the end segment
        vertex( (contact_two-wrapcount_two+1)*bpwidth+50,floor(phos_one[contact_two][5])*lineheight,-1);

        endShape();
      }
    }
  
    for (int i=1; i<len; i+=10) {   //draws the 10nt divisions
        strokeWeight(.5);
        stroke(0,0,0);
        beginShape(LINES);  //draw the baseline for the helix
        vertex((i-wrapcount[floor(phos_one[i][5])])*bpwidth+50,floor(phos_one[i][5])*lineheight+3,-1);
        vertex((i-wrapcount[floor(phos_one[i][5])])*bpwidth+50,floor(phos_one[i][5])*lineheight-3,-1);
        endShape();
        
        fill(0, 0, 0);
        textSize(5);  //make the numeral text small
        text(i-1, (i-wrapcount[floor(phos_one[i][5])])*bpwidth+50+2,floor(phos_one[i][5])*lineheight-4,-.5);    
    }

    popMatrix();
}
