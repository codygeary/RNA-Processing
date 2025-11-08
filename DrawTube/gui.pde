void drawGUI() {  //this part renders the GUI
  
    cp5 = new ControlP5(this);
       cp5.setAutoDraw(false);  //this is so that we can specify when to draw the GUI, ie before the camera is rotated.
             
          cp5.addSlider("anglechangeY",0,1.5,30,20,15,50)
             .setLabel("Barrel Spin")
             .setValue(0)
             .setNumberOfTickMarks(9);
          cp5.getController("anglechangeY").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);

             
          cp5.addSlider("viewangleY",0,360,80,40,120,15)
             .setLabel("Barrel View Angle")
             .setValue(180)
            .showTickMarks(false);
          cp5.getController("viewangleY").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
            
   
          cp5.addSlider("style",1,3,460,25,100,15)
             .setLabel("Trace        Wire         Solid")
             .setValue(3)
             .setNumberOfTickMarks(3)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("style").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("style").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);

          cp5.addKnob("zoomset",.8,7,360,50,70) //("variable",min, max, posx, posy, diam)
             .setLabel("Zoom")
             .setValue(2)
             .setDragDirection(Knob.HORIZONTAL);   
             
          cp5.addSlider("polymer",1,2,460,70,100,15)
             .setLabel("RNA                        DNA")
             .setValue(2)
             .setNumberOfTickMarks(2)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("polymer").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("polymer").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
           
          cp5.addToggle("showatoms")
             .setLabel("Phospate Atoms ON/OFF")
             .setPosition(650,20)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
          cp5.getController("showatoms").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
             
          cp5.addKnob("P_size",0.3,2,590,25,22) //("variable",min, max, posx, posy, diam)
             .setLabel("Atom Size")
             .setValue(1)
             .setDragDirection(Knob.HORIZONTAL);
          cp5.getController("P_size").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(5);  

          cp5.addKnob("linethickness",0.1,1,590,70,22) //("variable",min, max, posx, posy, diam)
             .setLabel("Line Thickness")
             .setValue(0.4)
             .setDragDirection(Knob.HORIZONTAL);
          cp5.getController("linethickness").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(5);  

          cp5.addToggle("showaxis")
             .setLabel("Central Axis ON/OFF")
             .setPosition(650,60)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
          cp5.getController("showaxis").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
             
          cp5.addToggle("persp_mode")
             .setLabel("Perspective ON/OFF")
             .setPosition(650,100)
             .setSize(50,15)
             .setValue(false)
             .setMode(ControlP5.SWITCH);
          cp5.getController("persp_mode").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          
          cp5.addToggle("color_mode")
             .setLabel("Color Chain/Repeat")
             .setPosition(650,140)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
          cp5.getController("color_mode").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);

          cp5.addToggle("force_geom")
             .setLabel("Force Geometry ON/OFF")
             .setPosition(780,20)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
          cp5.getController("force_geom").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
            
          cp5.addSlider("curve_dir",-1,1,760,60,100,15)
             .setLabel("Set Curvature")
             .setValue(1)
             .setNumberOfTickMarks(3)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("curve_dir").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("curve_dir").getValueLabel().align(ControlP5.CENTER, ControlP5.LEFT_OUTSIDE).setPaddingX(3);
            
          cp5.addSlider("spiral_offset",-4,4,760,100,100,15)
             .setLabel("Set Spiraling")
             .setValue(0)
             .setNumberOfTickMarks(7)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("spiral_offset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          cp5.getController("spiral_offset").getValueLabel().align(ControlP5.CENTER, ControlP5.LEFT_OUTSIDE).setPaddingX(3);

          cp5.addSlider("repeats",1,9,760,140,100,15)
             .setLabel("Number of Repeats")
             .setValue(1)
             .setNumberOfTickMarks(9)
             .showTickMarks(false)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("repeats").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);         
      
 slider = cp5.addSlider2D("Translate")  //This is the 2D pad for moving the molecule around
             .setPosition(240,30)
             .setSize(100,100)
             .setArrayValue(new float[] {50,50});
             
           cp5.addSlider("num_helix",3,30,900,40,15,100)
             .setLabel("# Helices")
             .setValue(12)
             .setNumberOfTickMarks(15)
             .showTickMarks(false); 
          cp5.getController("num_helix").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);  
                    
          cp5.addSlider("domain_d",0,22,960,60,100,15)
             .setLabel("Domain I   Length")
             .setValue(10)
             .setNumberOfTickMarks(23)
             .showTickMarks(false);
          cp5.getController("domain_d").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
 
           cp5.addSlider("domain_a",-20,22,960,100,100,15)
             .setLabel("Domain IV   Length")
             .setValue(11)
             .setNumberOfTickMarks(44)
             .showTickMarks(false);
          cp5.getController("domain_a").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);

          
          cp5.addSlider("tweak",0.8,1.2,960,140,100,15)
             .setLabel("Scale Helix Spacing")
             .setValue(1)
             .setSliderMode(Slider.FLEXIBLE);
          cp5.getController("tweak").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          
          cp5.addToggle("stress_view")
             .setLabel("Stress View ON/OFF")
             .setPosition(980,20)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
          cp5.getController("stress_view").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);

          cp5.addToggle("clash_mode")
             .setLabel("Clash ON/OFF")
             .setPosition(1100,20)
             .setSize(50,15)
             .setValue(true)
             .setMode(ControlP5.SWITCH);
          cp5.getController("clash_mode").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(5);
          
  myTextarea = cp5.addTextarea("txt")
                  .setPosition(0,180)
                  .setSize(190,70)
                  .setFont(createFont("arial",12))
                  .setLineHeight(14)
                  .setColor(color(50));
                     
}