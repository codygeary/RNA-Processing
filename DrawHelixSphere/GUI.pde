void gui() {
   cp5 = new ControlP5(this);
   
           cp5.addSlider("style",1,4,20,15,130,15)
             .setLabel("Wire       Solid         Axis      Solid-Axis")
             .setValue(4)
             .setNumberOfTickMarks(4)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("style").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("style").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
           
          cp5.addSlider("zoomlevel",.1,5,20,60,130,15)
             .setLabel("Zoom")
             .setValue(2); 
          cp5.getController("zoomlevel").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("zoomlevel").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
          
          cp5.addSlider("clash_thresh",5,12,20,100,130,15)
             .setLabel("Crossover Threshold (A)")
             .setValue(10); 
          cp5.getController("clash_thresh").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("clash_thresh").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);


          cp5.addSlider("fine_tune",-10,10,100,150,90,15)
             .setLabel("Spacing Fine-Tune")
             .setValue(0); 
          cp5.getController("fine_tune").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("fine_tune").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);


          cp5.addSlider("trim_angle",10,89,220,20,150,15)
             .setLabel("Trim Angle")
             .setValue(10); 
          cp5.getController("trim_angle").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("trim_angle").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);


          cp5.addSlider("diameter",5,45,220,60,150,15)
             .setLabel("Sphere Diameter (nm)")
             .setValue(18); 
          cp5.getController("diameter").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("diameter").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addSlider("ellipse",.5,4,220,110,150,15)
             .setLabel("Egg-ness")
             .setValue(1); 
          cp5.getController("ellipse").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("ellipse").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);


          cp5.addSlider("phase",0,1,220,150,150,15)
             .setLabel("Phase")
             .setValue(0); 
          cp5.getController("phase").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          cp5.getController("phase").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addSlider("polymer",1,2,20,150,60,15)
             .setLabel("RNA              DNA")
             .setValue(1)
             .setNumberOfTickMarks(2)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("polymer").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("polymer").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

  /*        cp5.addSlider("wrapinvert",-1,1,100,150,60,15)
             .setLabel("Coil Direction")
             .setValue(1)
             .setNumberOfTickMarks(2)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("wrapinvert").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("wrapinvert").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  */

          cp5.addToggle("showatoms")
             .setLabel("Phospates ON/OFF")
             .setPosition(420,10)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);

          cp5.addToggle("showaxis")
             .setLabel("Central Axis ON/OFF")
             .setPosition(420,45)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
             
          cp5.addToggle("persp_mode")
             .setLabel("Perspective ON/OFF")
             .setPosition(420,80)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);  
  
            cp5.addToggle("clash_mode")
             .setLabel("Crossovers CALC")
             .setPosition(420,115)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);  
   
            cp5.addToggle("show_clash")
             .setLabel("Crossovers ON/OFF")
             .setPosition(420,150)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);    
     
            cp5.addToggle("map")
             .setLabel("Map / Arcs")
             .setPosition(width-70,10)
             .setSize(50,15)
             .setColorLabel(color(0))
             .setValue(true)
             .setMode(ControlP5.SWITCH);   
    
            cp5.addToggle("crosspat")
             .setLabel("Crossover Map")
             .setPosition(width-70,40)
             .setSize(50,15)
             .setColorLabel(color(0))
             .setValue(false)
             .setMode(ControlP5.SWITCH);            
} //end gui setup
