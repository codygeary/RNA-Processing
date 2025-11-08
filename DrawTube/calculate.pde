void calculate_helix (){
  
  length_NA = round(2*(360/twist))*2;
  
  float ref_x = 0;
  float ref_y = 0;     //reset the reference positions
  float ref_z = 0;
  float ref_angle = 0;
  float helixangle=0;  //reset the initial helix angle of the first position
  int pos=0;           //reset the array address
  
  strand_dir = 1;
  int pattern_inverter = 1;
  float number_helix = num_helix;  //ugh, have to convert the integer num_helix into a float in order to divide it into 360!
  float tube_angle = (360/number_helix)*curve_dir;

  for (int i=0; i<num_helix; i++){         //process each strand in the design
    for (int k=0; k<2; k++) {              //each strand has two parts
     for (int j=0; j<(domain_a + domain_b); j++) { // domain_c and d must be equal to a+b, but we could have a longer NA eventually
        pos++ ;                           
        helixangle = ref_angle;
        phos[pos][0] = strand_dir*tilt/2 + ref_x;           
        phos[pos][1] = radius*(float)Math.cos(helixangle*DEG_TO_RAD) + ref_y;   //y
        phos[pos][2] = radius*(float)Math.sin(helixangle*DEG_TO_RAD) + ref_z;   //z
        centerax[pos][0] = ref_x;
        centerax[pos][1] = ref_y;
        centerax[pos][2] = ref_z;
        anglelist[pos] = ref_angle;  // remember the angle of each position since there are many strands
        strand_break[pos] = false;   // mark that the strand is continuous here
        ref_x += strand_dir*rise;
        ref_angle += strand_dir*twist;   // calculate the next ref angle
     }
     if ((k<1)) {  // only do this in the middle of the strand, but not at the end
       if ((force_geom<1)) {
        ref_x += strand_dir*tilt-strand_dir*rise;  // flip across the crossover
        ref_y += tweak*helixspace*(float)Math.cos((helixangle)*DEG_TO_RAD);
        ref_z += tweak*helixspace*(float)Math.sin((helixangle)*DEG_TO_RAD);
        ref_angle = helixangle+180;
        strand_dir = (-1)*(strand_dir);            // reverse the strand direction
        
        //calculate stress factor
        stress = sqrt( pow(strand_dir*tilt/2 + ref_x - phos[pos][0],2) + pow(radius*(float)Math.cos(ref_angle*DEG_TO_RAD) + ref_y - phos[pos][1],2) + pow(radius*(float)Math.sin(ref_angle*DEG_TO_RAD) + ref_z - phos[pos][2],2));
        stress = stress/sqrt( pow(phos[pos-1][0]-phos[pos][0],2)+pow(phos[pos-1][1]-phos[pos][1],2)+pow(phos[pos-1][2]-phos[pos][2],2)); 
       } else {
        ref_x += -strand_dir*rise - 0.5*(domain_d - domain_a)*rise + (spiral_offset*(length_NA/2)*rise)/num_helix;  //if forced, make the junction offset the rises
        ref_y += tweak*helixspace*(float)Math.cos((helixangle-axis/2+90 - 0.25*(domain_d - domain_a)*twist - tube_angle/2)*DEG_TO_RAD);
        ref_z += tweak*helixspace*(float)Math.sin((helixangle-axis/2+90 - 0.25*(domain_d - domain_a)*twist - tube_angle/2)*DEG_TO_RAD);
        ref_angle = helixangle-axis -0.5*(domain_d - domain_a)*twist - tube_angle;
        strand_dir = (-1)*(strand_dir);            // reverse the strand direction
        
        //calculate stress factor
        stress = sqrt( pow(strand_dir*tilt/2 + ref_x - phos[pos][0],2) + pow(radius*(float)Math.cos(ref_angle*DEG_TO_RAD) + ref_y - phos[pos][1],2) + pow(radius*(float)Math.sin(ref_angle*DEG_TO_RAD) + ref_z - phos[pos][2],2));
        stress = stress/sqrt( pow(phos[pos-1][0]-phos[pos][0],2)+pow(phos[pos-1][1]-phos[pos][1],2)+pow(phos[pos-1][2]-phos[pos][2],2)); 
       }
     }         
    }
     
     switch(pattern_inverter) {    //figure out if on an even or odd unit so we don't just make a big spiral
          case 1:               //backtrack by domain_b length and flip about the axis
               ref_x = centerax[pos-domain_d][0];
               ref_y = centerax[pos-domain_d][1];
               ref_z = centerax[pos-domain_d][2];
               ref_angle = anglelist[pos-domain_d] - strand_dir*axis;  //flip about the axis angle
               strand_break[pos] = true;  //mark the end of the strand 
               strand_dir = (-1)*(strand_dir);  //change the strand direction
               break;
          case -1:                //advance by domain_b and flip about the axis
               ref_x += strand_dir*rise*(domain_a-1);        // shift the ref_x up the helix
               ref_angle += strand_dir*twist*(domain_a-1) - strand_dir*axis;   // calculate the next ref angle
               strand_break[pos] = true;  //mark the end of the strand 
               strand_dir = (-1)*(strand_dir);
               break;              
     } //end switch case 1
     
     pattern_inverter = (-1)*(pattern_inverter); //reverse the pattern inverter    
  }   
 
 //Send the Stress Factor and other information to the text window
    myTextarea.setText("Stress Factor: "+round((stress-1)*1000)/10+"%                      "
                      +"Domain I: "+domain_d+"  Domain II: "+domain_c+" "
                      +"Domain IV: "+domain_a+"  Domain III: "+domain_b);



    //Now calculate the center of mass
    int counterx = 0;  //initialze counter for center of mass
    int countery = 0;
    int counterz = 0;
     for (int i=1; i<(length_NA*num_helix); i++) { 
      if (!strand_break[i]) { //ignore atom positions at the strand break for this calculation
       counterx += phos[i][0];
       countery += phos[i][1];
       counterz += phos[i][2];
     }
     }
     
     //Calculate the positions of the phosphate atoms in phosphate[][] based on the midpoints of lines between all phos[][]
     
      for (int i=1; i<(length_NA*num_helix); i++) {
        if (!strand_break[i]) {
        phosphate[i][0] = (phos[i][0]+phos[i+1][0])/2;
        phosphate[i][1] = (phos[i][1]+phos[i+1][1])/2;
        phosphate[i][2] = (phos[i][2]+phos[i+1][2])/2;
        } else {
        phosphate[i][0] = (phos[i][0]+phos[i-1][0])/2+(phos[i][0]-phos[i-1][0]);
        phosphate[i][1] = (phos[i][1]+phos[i-1][1])/2+(phos[i][1]-phos[i-1][1]);
        phosphate[i][2] = (phos[i][2]+phos[i-1][2])/2+(phos[i][2]-phos[i-1][2]);          
        }
      }
          
     
     //Figure out the average position
     float value=(repeats-1)*(length_NA*rise/4);
     counterx = counterx/(length_NA*num_helix);  
     countery = countery/(length_NA*num_helix);
     counterz = counterz/(length_NA*num_helix);
     //Adjust the position of each phosphate by the center
     for (int i=0; i<(length_NA*num_helix*2+num_helix*4+1); i++) {
       phos[i][0] = phos[i][0] - counterx - value;
       centerax[i][0] = centerax[i][0] - counterx - value;
       phos[i][1] = phos[i][1] - countery;
       centerax[i][1] = centerax[i][1] - countery;
       phos[i][2] = phos[i][2] - counterz;
       centerax[i][2] = centerax[i][2] - counterz;
       phosphate[i][0] = phosphate[i][0] - counterx - value;
       phosphate[i][1] = phosphate[i][1] - countery;
       phosphate[i][2] = phosphate[i][2] - counterz;
     }  
   
         if (clash_mode) {  //if clash mode is on, then go through the phosphates and detect the clashes
        
        clash_thresh = sqrt(pow(phosphate[2][0]-phosphate[1][0],2)+pow(phosphate[2][1]-phosphate[1][1],2)+pow(phosphate[2][2]-phosphate[1][2],2));
        float trigger = 1;
        for (int i=1; i<(length_NA*num_helix); i++){
          clash[i] = false;
        }
        for (int i=1; i<(length_NA*num_helix-1); i++) {
           for (int j=(i+1); j<(length_NA*num_helix); j++) {
              trigger = sqrt(pow(phosphate[i][0]-phosphate[j][0],2)+pow(phosphate[i][1]-phosphate[j][1],2)+pow(phosphate[i][2]-phosphate[j][2],2))/clash_thresh;
              if ((trigger<.6)) {   //sets the sensitivity of the clash detection  (compares two consecutive phosphates to the spacing of all others)
                clash[i] = true;
                clash[j] = true;
              }
           }
        }        
      }   

   
   
   
   
   boolchecksum=0;
   if (force_geom==1) {boolchecksum += 2;}
   if (stress_view) {boolchecksum += 3;}  
   if (clash_mode) {boolchecksum+= 5;}
   
   checksum=repeats+domain_a+domain_d+polymer+curve_dir+tweak+spiral_offset+num_helix+boolchecksum;
   
     
}