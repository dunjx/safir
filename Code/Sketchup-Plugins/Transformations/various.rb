#!usr/bin/env ruby
require 'sketchup.rb'

module Various_plugin
    # Class variables
    @@all_color_names  = Sketchup::Color.names # Names of colors recognized by Sketchup.
    @@now = Time.now                           # Time instance for the present momenet.
    @@random_generator = Random.new(@@now.sec) # Present moment as a seed for random generator.
    
    def self.check_error(msg)
        UI.messagebox(msg + "\nTerminated.")
        abort
    end
    
    
    def self.choose_color   # Method for user's color choise.
    # -- INPUT FOR CHOOSING COLOR
        prompts_color = ["Name","red","green","blue"] # User can choose color by typing name, or red, green and blue component,
                                                      # or by typing 'RANDOM' to let random generator choose color.
              defaults_color = ["Random","","",""]
              input_color = UI.inputbox(prompts_color,defaults_color,"Choose color: ")
              if @@all_color_names.include?(input_color[0]) or @@all_color_names.include?(input_color[0].capitalize)
                  choosed_color = Sketchup::Color.new(input_color[0])
                  puts input_color[0]
              elsif input_color[0].upcase == "RANDOM"
                  random_index = @@random_generator.rand(0..@@all_color_names.length)
                  choosed_color = Sketchup::Color.new(@@all_color_names[random_index])
                  SKETCHUP_CONSOLE.show
                  puts("Name of chosen color is " + @@all_color_names[random_index])
              elsif input_color[1] != "" and input_color[2] != "" and input_color[3] != ""
                  red = input_color[1].to_f
                  green = input_color[2].to_f
                  blue = input_color[3].to_f
                  if red == 0.0 and green == 0.0 and blue == 0.0
                      UI.messagebox("Black color chose or incorrect inputs")
                  end
                  if red < 0.0 and green < 0.0 and blue < 0.0
                      self.check_error("Negative colors entered!")
                  end
                  choosed_color = Sketchup::Color.new(red,green,blue)
              else
                  UI.messagebox("Haven't entered any correct color")
                  return nil
              end
              return choosed_color
    end
    
    def self.make_gradient_step(color1,color2,n)  # Method for making gradient from color1 to color2, coloring n objects.
        # Taking red, green and blue components of both colors.
        red1 = color1.red
        blue1 = color1.blue
        green1 = color1.green
        red2 = color2.red
        blue2 = color2.blue
        green2 = color2.green
        
        # Array of 3 elements is returned, each for every component of color.
        step = Array.new(3)
        step[0] = (red2 - red1)/n
        step[1] = (green2 - green1)/n
        step[2] = (blue2 - blue1)/n
        return step
    end
    
    def self.various
      # Reference to a currently active model.
      model = Sketchup.active_model
      
      # Beginning of an atomic procedure.
      model.start_operation("Repeating objects around axis on more levels",true)
      
      # First input, user chooses settings they want.
      # -- INITIAL INPUT
      prompts_welcome = ["Up-scaling","Missing parts","Color"]
      defaults_welcome = ["n","n","n"]
      input_welcome = UI.inputbox(prompts_welcome, defaults_welcome,"Welcome to Various plugin. Check the settings you want.[y/n]")
      
      # Input for basic settings of plugin (always shown).
      # -- BASIC INPUT
      prompts = ["Position of the first unit (x) :","Position of the first unit (y) :","Height of the first level:","Size of the unit:",
                 "Number of units in the level","rotation [y/n]","Number of levels:",
                 "Distance between levels","Around X/Y axes (instead Z)"]
      defaults = ["20","20","10","20","6","y","1","0.01","n","n"]
      input = UI.inputbox(prompts,defaults,"Basic plugin settings")
      
            
      # Retreiving basic parameters for plugin.
      rX = input[0].to_f   # Position of the first unit-part in the first level. (X - coordinate, and below Y - coordinate)
      rY = input[1].to_f
      h  = input[2].to_f   # The height of the first level.
      a  = input[3].to_f   # Size of an edge of unit-part.
      n  = input[4].to_i   # Number of unit-parts in level.
      if_rotation = input[5] # If user doesn't want rotation, just translation around axis instead. (for non-rotated looking)
      l  = input[6].to_i   # Number of levels.
      raiseUp = input[7].to_f  # Distance between successive levels.

      if l <= 0.0 or n <= 0 or a <= 0.0
          self.check_error("One of inputs (number of levels, number of units in level, size of unit) is zero or less then zero or entered incorrect!")
      end
 
      # If user chose option for scaling, input for scaling settings are shown.
      sX = 0     # Parameters for scaling (if user doesn't choose scaling option, they won't be used).
      sY = 0
      sZ = 0
      if input_welcome[0].upcase == "Y" or input_welcome[0].upcase == "YES"
      # -- SCALING INPUT
          prompts_scaling = ["X (width): ","Y (length): ","Z (height): "]
          defaults_scaling = ["1","1","1"]
          input_scaling =  UI.inputbox(prompts_scaling,defaults_scaling,"Scaling settings")
          sX = input_scaling[0].to_f   # This cast function doesn't throw exceptions. If user enters incorrect input, return value will of this
          sY = input_scaling[1].to_f   # function will be 0.0, so this won't cause any effect to model. We will send warning message to user if
          sZ = input_scaling[2].to_f   # this function don't cause anything.
          if sX == 0.0 and sY == 0.0 and sZ == 0.0
              UI.messagebox("All values zeros or incorrect inputs!")
          elsif a + sX * (l-1) <= 0.0 or a + sY * (l-1) <= 0.0 or a + sZ * (l-1) <= 0.0
              self.check_error("One or more scaling parameters is negative and too small.") 
          end
      end
      
      # If user chooses option for missing some parts, input for those settings are shown.
      option_missing = ""     # Helping parameters for missing parts.
      m = 1
      if input_welcome[1].upcase == "Y" or input_welcome[1].upcase == "YES"
      # -- MISSING PARTS INPUT
          prompts_missing = ["Missing option","m"]
          defaults_missing = ["Half-by-Half",""]
          input_missing = UI.inputbox(prompts_missing,defaults_missing,"Missing parts settings")
          if input_missing[0].upcase == "HH" or input_missing[0].upcase == "HALF-BY-HALF" #  Option for showing one half for even levels, and showing other half for odd levels.
              option_missing = "h"
          elsif input_missing[0].upcase == "M"  or input_missing[0].upcase == "M-TH SPIRAL" # Option for showing m-th part for each level.
              option_missing = "m"
              m = input_missing[1].to_i
              if m <= 0
                  self.check_error("No m enterred or incorrect value enterred")
              end
          elsif input_missing[0].upcase == "RS" or input_missing[0].upcase == "RANDOM" or input_missing[0].upcase == "RANDOM SPIRAL" # Option for showing random segments for each level.
              option_missing = "r"
          else
              UI.messagebox("Haven't entered any correct missing-parts option")
              option_missing = ""
          end
      end
      
      group = model.active_entities.add_group()  # Definition of global group for whole object.
      
      # If user wants to make object around other axes(X or Y), they can then note this.
      if input[8].upcase == "X"
          changeAxis = Geom::Transformation.axes(ORIGIN,Y_AXIS,Z_AXIS,X_AXIS)
          group.transform!(changeAxis)
      elsif input[8].upcase == "Y"
          changeAxis = Geom::Transformation.axes(ORIGIN,Z_AXIS,X_AXIS,Y_AXIS)
          group.transform!(changeAxis)
      end
      
      # Entities included in (global) group.
      entities = group.entities
       
      # Points included in polygon that make the surface. By push-pulling this surface unit-objects will be made.
      # Unit-objects are made at the origin and then they are moved to appropriate places by isometric transformations.
      points = [
            Geom::Point3d.new(-0.5*a,-0.5*a,h+a),
            Geom::Point3d.new(0.5*a,-0.5*a,h+a),
            Geom::Point3d.new(0.5*a,0.5*a,h+a),
            Geom::Point3d.new(-0.5*a,0.5*a,h+a)
    ]
    
      # If user wants to color their object group, color settings are available.
      choosed_color = nil   # Parameters for coloring.
      color_option = ""
      color_step   = nil
      if input_welcome[2].upcase == "Y" or input_welcome[2].upcase == "YES"
      # -- COLORING INPUT
          prompts_color = ["Choose"]
          defaults_color = ["One color"]
          input_color = UI.inputbox(prompts_color,defaults_color,"How do you want to color your object?")
          if input_color[0].upcase == "ONE" or input_color[0].upcase == "ONE COLOR"  # Whole object is the same color.
              color_option = "o"
              choosed_color = self.choose_color
          elsif input_color[0].upcase == "ADC" or input_color[0].upcase == "ALL DIFFERENT COLORS" # Each unit is a different color, chosen by the random generator.
              color_option = "d"
          
          elsif input_color[0].upcase == "G" or input_color[0].upcase == "GRADIENT" # Coloring object as a gradient between two colors.
              color_option = "g"
              
              # -- INPUT for gradient.
              prompts_gradient_number  = ["1/2 ?"]
              defaults_gradient_number = ["1"]
              input_gradient_number    = UI.inputbox(prompts_gradient_number,defaults_gradient_number,"Choose: 1 - white and another color, 2 - two colors")
              
              # User can choose colors for the gradient, or one color, and this will be gradually lighted to white(default option).
              choosed_color_2 = nil
              if input_gradient_number[0] == "2"
                  choosed_color = self.choose_color
                  choosed_color_2 = self.choose_color
              else
                  choosed_color = self.choose_color
                  choosed_color_2 = Sketchup::Color.new("White")
              end
              color_step = self.make_gradient_step(choosed_color,choosed_color_2,l) # Retrieve appropriately step for gradient, depending on chosen colors and number of levels.
          else
              UI.messagebox("Haven't entered any correct color option")
              color_option = ""
          end
      end

      angle= (360.degrees)/n  # Unit-angle between successive unit-objects in level.
      k = 0  # Helping variable for drawing m-th spiral. (if user chose this)
      for j in 0...l
         color_gradient = nil # Variable for storing color-object. (needed for gradient)
         
         pX = rX * (j+1)  # X and Y coordinate of the first object in level.
         pY = rY * (j+1)
         
         vector = Geom::Vector3d.new(pX,pY,0) # Transformation for translation unit-object away from rotating-axis. (and vector needed for this translation)
         translationT = Geom::Transformation.translation(vector)
         
         vectorUp = Geom::Vector3d.new(0,0,j*(a+raiseUp)) # Transformation for translation unit-object higher.(appropriately for level)
         translationUp = Geom::Transformation.translation(vectorUp)
         
         scalingT = Geom::Transformation.scaling(1+sX*j,1+sY*j,1+sZ*j) # Transformation for scaling objects(if user chooses this). All unit-objects in same level will be scaled the same.
         i_begin = 0  # Variables for range for drawing level (they are different if there is option for m-th spiral or random-spiral)
         i_end   = n
         if option_missing == "m"     # Regulating bounds for drawing each level. (m-th spiral)
             i_begin = k*((n/m).ceil)
             k = (k+1)%m
             i_end   = k*((n/m).ceil)
        elsif option_missing == "r"   # Regulating bounds for drawing each level. (random-spiral)
            i_begin = @@random_generator.rand(0...n)
            i_end   = @@random_generator.rand(0...n)
            if i_end < i_begin  # This way level can be seen from end to beginning, for diverse look in object.
                i_begin -= n
            end
         end
         
         if color_option == "g"  # Regulating current color of level if we use gradient.
            red = choosed_color.red + j*color_step[0]
            green = choosed_color.green + j*color_step[1]
            blue = choosed_color.blue + j*color_step[2]
            color_gradient = Sketchup::Color.new(red,green,blue)
         end
         
         for i in i_begin...i_end  # Drawing unit-objects in level.
            if option_missing == "h" and i >= n/2 # For 'Half-by-half' option, changing sign of angle for easier way to change side of drawing for next level.
                    angle *= (-1)
                    break
            end
            
            curr_vector_x = pX  # Current vector of unit-object and its intensity, if there is no rotation.
            curr_vector_y = pY
            curr_vector_intensity = Math.sqrt(pX**2 + pY**2)
            
            group_in = entities.add_group() # Group for each unit-object and its entities.
            entities_in = group_in.entities
            
            face = entities_in.add_face(points) # By using pushpull transformation of this face (based on points above in code) unit-object is made.
            
            # Regulating coloring unit-objects (depends of chosen option)
            if color_option == "d"
                color_index = @@random_generator.rand(0...@@all_color_names.length)
                choosed_color = Sketchup::Color.new(@@all_color_names[color_index])
                face.material = choosed_color
            end
            if color_option == "g"
                face.material = color_gradient
            elsif choosed_color != nil
                face.material = choosed_color
            end
            # Finally, making unit-object and executing necessary geometric transformation.
            face.pushpull(a)
            group_in.transform!(scalingT)
            group_in.transform!(translationUp)
            
            # If user doesn't want rotation.
            if if_rotation.upcase == 'N' or if_rotation.upcase == 'NO'
               group_in.transform!(translationT)
               add_vector_translation = Geom::Vector3d.new(curr_vector_intensity*Math.cos(i*angle) - curr_vector_x,
                                                           curr_vector_intensity*Math.sin(i*angle) - curr_vector_y) # Appropriate translation instead of rotation.
               translaion_instead = Geom::Transformation.translation(add_vector_translation)
               group_in.transform!(translaion_instead)
            else
               rotationTL = Geom::Transformation.rotation(ORIGIN,Z_AXIS,i*0.7*angle) # Plus, some extra rotation in place, for better visual presentation.
               group_in.transform!(rotationTL)
               group_in.transform!(translationT)
               rotationT = Geom::Transformation.rotation(ORIGIN,Z_AXIS,i*angle)  # Appropriate rotation.
               group_in.transform!(rotationT)
            end
            
         end
      end
      
      # End of an atomic procedure.
    model.commit_operation
    end

    # Necessary for installation plugin.
    unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    menu.add_item('Various'){
      self.various
    }
    file_loaded(__FILE__)
    end
end