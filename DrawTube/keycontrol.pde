void keyPressed() { 

  String[] Chains = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", 
              "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
              "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
              "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", 
              "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
              "y", "z" };
              
  int chain_count = 0;
  
  if (key == 'q') { 
    domain_a += -1;
    cp5.getController("domain_a").setValue(domain_a);
  }
  if (key == 'w') { 
    domain_a += 1;
    cp5.getController("domain_a").setValue(domain_a);
  }
  if (key == 'a') { 
    domain_d += -1;
    cp5.getController("domain_d").setValue(domain_d);
  }
  if (key == 's') { 
    domain_d += 1;
    cp5.getController("domain_d").setValue(domain_d);
  }

  if (key == '1') { 
    xpos=0; ypos=0; xdrag=0; ydrag=0; xvect=0; yvect=0;
  }

    if (keyCode == SHIFT) {

      for (int n=0; n<repeats; n++) {  //draw the repeating units recursively
        unit_size = n*(length_NA/2*rise);  //sets the length by which to translate each repeat unit

        for (int i=1; i<(length_NA*num_helix); i++) {
          float posone=phosphate[i][0] + unit_size;
          float postwo=phosphate[i][1];
          float posthree=phosphate[i][2];        
          if (!strand_break[i]) {
            output.println("LINE" + "\t" + Chains[chain_count] + "\t" + i + "\t" + posone + "\t" + postwo + "\t" + posthree);          
          } else {chain_count++;}
        }
        chain_count++;
      }
          output.flush();  // Writes the remaining data to the file
          output.close();  // Finishes the file
          println("output complete!");  
    }

}