void checkmouse() {
  
    if (mousePressed && (mouseButton == LEFT)) {
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
  
  cp5.getController("zoomset").setValue(zoomset);
  
   if (mousePressed && (mouseButton == RIGHT)) {
     if (mousepress_set==2) {
          zoomset=abs((mouseY-ydrag)/1000+zoomset) ;   //set the sensitivity of the zooming
    }   else {
    mousepress_set=2;
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

  
}