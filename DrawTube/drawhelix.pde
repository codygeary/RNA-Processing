void drawhelix()  { 
  
  L_thick=linethickness/(zoomset);
  
  int colorvalue = 50;
  int repeatvalue = -35;
  for (int n=0; n<repeats; n++) {  //draw the repeating units recursively
      unit_size = n*(length_NA/2*rise);  //sets the length by which to translate each repeat unit
      smooth();
      noFill();
      beginShape(LINES); //draw main backbone strand
      stroke(0);
      strokeWeight(2*L_thick);
      colorvalue = 50;
      for (int i=1; i<(length_NA*num_helix); i++) {
        if (!strand_break[i]) {
         stroke(colorvalue-80,colorvalue-40,190-colorvalue); 
         vertex(phos[i][0] + unit_size, phos[i][1], phos[i][2]*inverter);    
         vertex(phos[i+1][0] + unit_size, phos[i+1][1], phos[i+1][2]*inverter); 
        } else {
         stroke(colorvalue-80,colorvalue-40,190-colorvalue);        
         vertex(phos[i][0] + unit_size, phos[i][1], phos[i][2]*inverter); 
         vertex(phosphate[i][0] + unit_size, phosphate[i][1], phosphate[i][2]*inverter); 
         colorvalue=colorvalue+200/num_helix;
       }
      }
      endShape();

     
    switch(style) {
     case 3:
      colorvalue = -37;
      repeatvalue += 255/4 + 13;
      repeatvalue = repeatvalue %510;  
      for (int i=1; i<(length_NA*num_helix+1); i++) {
        if (!strand_break[i]) {       
         beginShape(TRIANGLE_FAN);  //draw solid fill shape
         if (stress_view) {
         fill(abs(stress-1)*300,0,260-abs(stress-1)*400);
         } else {  
           if (color_mode) {     
            fill(colorvalue%255,(colorvalue/2 % 255), 255-(colorvalue%255));
           } else {
           fill(repeatvalue%255,(repeatvalue/2 % 255),255-(repeatvalue%255));
           }  
         }
         noStroke();
            vertex(phos[i][0] + unit_size, phos[i][1], phos[i][2]*inverter);
            vertex(centerax[i][0] + unit_size, centerax[i][1], centerax[i][2]*inverter);
            vertex(centerax[i+1][0] + unit_size, centerax[i+1][1], centerax[i+1][2]*inverter); 
            vertex(phos[i+1][0] + unit_size, phos[i+1][1], phos[i+1][2]*inverter);   
            vertex(phos[i][0] + unit_size, phos[i][1], phos[i][2]*inverter);
         endShape(CLOSE);
       } else {
           colorvalue+= 255/(num_helix/3)+13;
           colorvalue = colorvalue%510;
       }
      }
      
      beginShape(LINES);     //draw base pairs through the center axis
        for (int i=0; i<(length_NA*num_helix+1); i++) {
          stroke(1);
          strokeWeight(1.2*L_thick);
          vertex(phos[i][0] + unit_size, phos[i][1], phos[i][2]*inverter); 
          vertex(centerax[i][0] + unit_size, centerax[i][1], centerax[i][2]*inverter);
        }

      endShape();
      break;
    case 2:
      beginShape(LINES);     //draw base pairs through the center axis
        for (int i=1; i<(length_NA*num_helix+1); i++) {
          stroke(0,0,0);
          strokeWeight(0.8*L_thick);
          vertex(phos[i][0] + unit_size, phos[i][1], phos[i][2]*inverter); 
          vertex(centerax[i][0] + unit_size, centerax[i][1], centerax[i][2]*inverter);
        }

      endShape(); 
    break;
    }
    
   if (showaxis) {  
      beginShape(); //render central axis
      strokeWeight(1.2*L_thick);
      stroke(0,0,0);
       noFill();
       for (int i=1; i<(length_NA*num_helix+1); i++) {
          if (!strand_break[i]) {
           vertex(centerax[i][0] + unit_size, centerax[i][1], centerax[i][2]*inverter);
          } else {
           vertex(centerax[i][0] + unit_size, centerax[i][1], centerax[i][2]*inverter); 
           endShape();
           beginShape();
          }
       }
       endShape();
     }
}

}