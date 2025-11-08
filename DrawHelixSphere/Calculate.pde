void calculatehelix()
{
  sphere_rad=wrapinvert*10*diameter/2;
  
  if (ellipse<1){
     wraps = pow(ellipse, 0.5) * (sphere_rad * PI) / (helixspace+fine_tune);
  } else {
     wraps = pow(ellipse, 1.0) * (sphere_rad * PI) / (helixspace+fine_tune);    
  }
  
  float helixangle=0;      // sets the initial helix angle
  float aphelixangle=axis; //initialize the antiparallel angle to axis
  float aptorusangle;  float sugarangle=0;  float apsugarangle=0;  float centerangle;  torusangle=0;
  com_x=0; com_y=0; com_z=0; latitude=trim_angle;
  
  len=7500;
  
  for (int i=1; i<len+1; i++) {  //fill in the arrays with data points
          
    float stepsize=0; // make the unit step 0
                      // now calculate the distance between the current point on the sphere the next step, iterate the step size till we are larger than the rise
    float xlength=0; float ylength=0; float zlength=0;
    
    float interval=.2;
    int counter=0;
    wrapcount[0]=0;
    
    for (float j=0; j<15; j+=interval) {
     xlength = (sphere_rad*sin(latitude*DEG_TO_RAD)*cos(2*wraps*wrapinvert*latitude*DEG_TO_RAD)-sphere_rad*sin((latitude+j)*DEG_TO_RAD)*cos(2*wraps*wrapinvert*(latitude+j)*DEG_TO_RAD));
     ylength = (sphere_rad*sin(latitude*DEG_TO_RAD)*sin(2*wraps*wrapinvert*latitude*DEG_TO_RAD)-sphere_rad*sin((latitude+j)*DEG_TO_RAD)*sin(2*wraps*wrapinvert*(latitude+j)*DEG_TO_RAD));
     zlength = ellipse*(sphere_rad*cos(latitude*DEG_TO_RAD)-sphere_rad*cos((latitude+j)*DEG_TO_RAD));
     float distance=sqrt(xlength*xlength+ylength*ylength+zlength*zlength);
     
     if (distance>rise) {
        j=j-interval;
       interval=interval/2;
     }
     
     counter++;
     if (counter>70) {stepsize=j; j=500;}
    }

    latitude+=stepsize;
    
    if (latitude>(180-trim_angle)) {len=i;}
    
    torus_rad=sphere_rad*sin(latitude*DEG_TO_RAD);
    
    anglestep=stepsize*2*wraps;
    helixangle = (i*twist)+phase*360 ;       //calculates the angle of the main strand phophate
    torusangle =2*wraps*latitude;

    
    phos_one[i][0] = sin(torusangle*DEG_TO_RAD)*(radius*cos(helixangle*DEG_TO_RAD)+torus_rad);          //x
    phos_one[i][1] = cos(torusangle*DEG_TO_RAD)*(radius*cos(helixangle*DEG_TO_RAD)+torus_rad);   //y
    phos_one[i][2] = sin(helixangle*DEG_TO_RAD)*radius + ellipse*sphere_rad*cos(latitude*DEG_TO_RAD);   //z
    phos_one[i][3] = -(latitude-90)*wrapinvert;
    phos_one[i][4] = ((torusangle-2*wraps*trim_angle)*wrapinvert) % 360;
    phos_one[i][5] = ceil((torusangle-2*wraps*trim_angle)*wrapinvert/360);  //-2*wraps*trim_angle subtracts out the initial torusangle and makes the longitude set to 0

    if (floor(phos_one[i][5])>floor(phos_one[i-1][5])) {wrapcount[floor(phos_one[i][5])]=i;}

    aphelixangle = helixangle + axis + twist; //the antiparallel strand is based on the axis angle, 1 extra twist unit is added
    aptorusangle = (2*wraps*latitude+anglestep+(360*tilt)/(2*PI*torus_rad));
    
    phos_two[i][0] = sin(aptorusangle*DEG_TO_RAD)*(radius*cos(aphelixangle*DEG_TO_RAD)+torus_rad);          //x
    phos_two[i][1] = cos(aptorusangle*DEG_TO_RAD)*(radius*cos(aphelixangle*DEG_TO_RAD)+torus_rad);   //y
    phos_two[i][2] = sin(aphelixangle*DEG_TO_RAD)*radius + ellipse*sphere_rad*cos(latitude*DEG_TO_RAD);   //z

    //now increment 1/2 anglestep to put in the sugars

    centerangle = (2*wraps*latitude+anglestep/2+(360*tilt)/(2*2*PI*torus_rad));
    
    centerax[i][0] = sin(centerangle*DEG_TO_RAD)*(torus_rad);             //x
    centerax[i][1] = cos(centerangle*DEG_TO_RAD)*(torus_rad);                                               //y
    centerax[i][2] = 0 + ellipse*sphere_rad*cos(latitude*DEG_TO_RAD);                                               //z

    //now draw the sugars, also add sugaroffset factor to anglestep from the phosphates

    sugarangle = (i*twist+twist*sugartwistoffset)+phase*360 ;       //calculates the angle of the bp
    torusangle = (2*wraps*latitude+anglestep*sugaroffset);
    
    sugar_one[i][0] = sin(torusangle*DEG_TO_RAD)*(sugarradius*cos(sugarangle*DEG_TO_RAD)+torus_rad);          //x
    sugar_one[i][1] = cos(torusangle*DEG_TO_RAD)*(sugarradius*cos(sugarangle*DEG_TO_RAD)+torus_rad);   //y
    sugar_one[i][2] = sin(sugarangle*DEG_TO_RAD)*sugarradius + ellipse*sphere_rad*cos(latitude*DEG_TO_RAD);   //z
    
    apsugarangle = helixangle + axis + twist*(1-sugartwistoffset); //the antiparallel strand is based on the axis angle, 1 extra twist unit is added
    aptorusangle = (2*wraps*latitude+anglestep*(1-sugaroffset)+(360*tilt)/(2*PI*torus_rad));
    
    sugar_two[i][0] = sin(aptorusangle*DEG_TO_RAD)*(sugarradius*cos(apsugarangle*DEG_TO_RAD)+torus_rad);          //x
    sugar_two[i][1] = cos(aptorusangle*DEG_TO_RAD)*(sugarradius*cos(apsugarangle*DEG_TO_RAD)+torus_rad);   //y
    sugar_two[i][2] = sin(apsugarangle*DEG_TO_RAD)*sugarradius + ellipse*sphere_rad*cos(latitude*DEG_TO_RAD);   //z
    
    //now add to center-of-mass counters, only for the phosphates
    com_x += (phos_one[i][0] + phos_two[i][0] + centerax[i][0]);
    com_y += (phos_one[i][1] + phos_two[i][1] + centerax[i][1]);
    com_z += (phos_one[i][2] + phos_two[i][2] + centerax[i][2]);    
  } 
   //now divide the counters by the length to get the center of mass
   com_x = com_x/(len*3); com_y = com_y/(len*3); com_z = com_z/(len*3);
  
   for (int i=1; i<len+1; i++) {  // go back through the data array and offset things by the center of mass just calculated
   phos_one[i][0] += -com_x; phos_one[i][1] += -com_y; phos_one[i][2] += -com_z;
   phos_two[i][0] += -com_x; phos_two[i][1] += -com_y; phos_two[i][2] += -com_z;
   centerax[i][0] += -com_x; centerax[i][1] += -com_y; centerax[i][2] += -com_z;
   sugar_one[i][0] += -com_x; sugar_one[i][1] += -com_y; sugar_one[i][2] += -com_z;   
   sugar_two[i][0] += -com_x; sugar_two[i][1] += -com_y; sugar_two[i][2] += -com_z;
   }

      if (clash_mode) {  //if clash mode is on, then go through the phosphates and detect the clashes
        
        float trigger = 1;
        for (int i=0; i<(len+1); i++){   //reset the clash table to zero
          clash[i] = false;
          clashpos[i][0]=0; clashpos[i][1]=0; clashpos[i][2]=0;
        }
        
        for (int i=0; i<(len-15); i++) { //i is residue 1
           for (int j=(i+15); j<(len+1); j++) {  //j is residue 2
              float dist=sqrt(pow(phos_one[i][0]-phos_one[j][0],2)+pow(phos_one[i][1]-phos_one[j][1],2)+pow(phos_one[i][2]-phos_one[j][2],2));  //distance between i and j
              if (dist/clash_thresh<1) {   //checks if the distance is within the threshhold
              
                 if (clash[i] && clashpos[i][2]>=dist) {  //if it's already a clash marked and it's longer than the new distance then update it
                   clash[floor(clashpos[i][1])]=false;    //scrub out the old interaction
                   clashpos[floor(clashpos[i][1])][0]=0;  //scrub out the old partner metadata
                   clashpos[floor(clashpos[i][1])][1]=0;
                   clashpos[floor(clashpos[i][1])][2]=0;                  
                   clash[i] = true;
                   clash[j] = true;
                   clashpos[i][0]=i;
                   clashpos[i][1]=j;
                   clashpos[i][2]=dist; 
                  }  
                if (!clash[i]) {  //if it's a new clash then mark it
                 clash[i] = true;  //mark the clash
                 clash[j] = true;  //mark the clash partner
                 clashpos[i][0]=i; 
                 clashpos[i][1]=j;
                 clashpos[i][2]=dist;               
                }
               }//endif dist/clash

           if (j>(i+sphere_rad*wrapinvert*2.5*PI/rise)) {j=len+2;} //only look ahead a max of two of the largest diameter wraps, to save time
         }//end loop j
        }//end loop i
      
      //now scrub the clash tables to find the most optimal if two adjacent have a clash
 
      for (int i=0; i<length_NA; i++) {
         if (clash[i] && clash[i+1] && clashpos[i][2]<clashpos[i+1][2] && clashpos[i+1][2]!=0 && clashpos[i][2]!=0) {
          clash[i+1]=false;
          clash[floor(clashpos[i+1][1])]=false;  //mark the partner of (i+1) false
          clash[floor(clashpos[i][1])]=true;     //mark the partner of i true, incase they are the same partner!
          clashpos[i+1][0]=0;
          clashpos[i+1][1]=0;          
          clashpos[i+1][2]=0;
        }
        if (clash[i] && clash[i+1] && clashpos[i][2]>clashpos[i+1][2] && clashpos[i+1][2]!=0 && clashpos[i][2]!=0) {
          clash[i]=false;
          clash[floor(clashpos[i][1])]=false;   //mark the partner of i as false
          clash[floor(clashpos[i+1][1])]=true;  //mark the partner of (i+1) as true, just incase it was the same partner
          clashpos[i][0]=0;
          clashpos[i][1]=0;          
          clashpos[i][2]=0;
        } 
      }
      } //end clash mode

   //now reset the check variables so that the data is only redrawn when the variables are changed again//   diameter_check=diameter*wrapinvert; phase_check=phase; clash_threshcheck=clash_thresh; len_check=len; pol_check=polymer; clashmodecheck=clashmodeon;
   checksum=diameter*wrapinvert+phase+clash_thresh+len+polymer+clashmodeon+ellipse+trim_angle+fine_tune;
   
   //update the wrapwidth table now that the calculations are complete
   wrapcount[floor(phos_one[len][5])+1]=len;
   for (int i=1; i<floor(phos_one[len][5]+2); i++) {
     wraplength[i]=wrapcount[i]-wrapcount[i-1];
   }
   
}
