#!usr/bin/env ruby
require 'sketchup.rb'

module Various_plugin
    @@all_color_names  = Sketchup::Color.names
    @@now = Time.now
    @@random_generator = Random.new(@@now.sec)
    def self.choose_color
        prompts_one_color = ["Name","red","green","blue"]
              defaults_one_color = ["Random","","",""]
              input_one_color = UI.inputbox(prompts_one_color,defaults_one_color,"Choose color of your object:")
              if @@all_color_names.include?(input_one_color[0]) or @@all_color_names.include?(input_one_color[0].capitalize)
                  choosed_color = Sketchup::Color.new(input_one_color[0])
                  puts input_one_color[0]
              elsif input_one_color[0].upcase == "RANDOM"
                  random_index = @@random_generator.rand(0..@@all_color_names.length)
                  choosed_color = Sketchup::Color.new(@@all_color_names[random_index])
                  SKETCHUP_CONSOLE.show
                  puts("Name of got color is " + @@all_color_names[random_index])
              elsif input_one_color[1] != "" and input_one_color[2] != "" and input_one_color[3] != ""
                  red = input_one_color[1].to_f
                  green = input_one_color[2].to_f
                  blue = input_one_color[3].to_f
                  choosed_color = Sketchup::Color.new(red,green,blue)
              end
              return choosed_color
    end
 
    def self.various
      model = Sketchup.active_model
      
      # Zapocinjemo atomicnu proceduru, koju mozemo da ponistimo izjedna.
      model.start_operation("Repeat selected objects around z-axis",true)
      
      prompts_welcome = ["Up-scaling","Missing parts","Color"]
      defaults_welcome = ["n","n","n"]
      input_welcome = UI.inputbox(prompts_welcome, defaults_welcome,"Welcome to Various plugin. Check which settings do you want.[y/n]")
      
      
      #----------------------------------------------------------------------
      # TODO:        -- Basic settings"
      prompts = ["rX","rY","h","a","n","rotation [y/n]","l","raise","X/Y"]
      defaults = ["20","20","10","20","6","y","1","0.01","n","n"]
      input = UI.inputbox(prompts,defaults,"Basic plugin settings")
      #---------------------------------------------------------------------
      
      
      #         -- Scaling settings
      sX = 0
      sY = 0
      sZ = 0
      if input_welcome[0].upcase == "Y" or input_welcome[0].upcase == "YES"
          prompts_scaling = ["X (wide): ","Y (length): ","Z (high): "]
          defaults_scaling = ["1","1","1"]
          input_scaling =  UI.inputbox(prompts_scaling,defaults_scaling,"Scaling settings")
          sX = input_scaling[0].to_f
          sY = input_scaling[1].to_f
          sZ = input_scaling[2].to_f
      end
      
      #          -- Missing settings
      option_missing = ""
      m = 1
      if input_welcome[1].upcase == "Y" or input_welcome[1].upcase == "YES"
          prompts_missing = ["Missing option","m"]
          defaults_missing = ["Half-by-Half",""]
          input_missing = UI.inputbox(prompts_missing,defaults_missing,"Missing parts settings")
          if input_missing[0].upcase == "HH" or input_missing[0].upcase == "HALF-BY-HALF"
              option_missing = "h"
          elsif input_missing[0].upcase == "M"  or input_missing[0].upcase == "M-TH SPIRAL"
              option_missing = "m"
              m = input_missing[1].to_i
          elsif input_missing[0].upcase == "RS" or input_missing[0].upcase == "RANDOM" or input_missing[0].upcase == "RANDOM SPIRAL"
              option_missing = "r"
          else option_missing = ""
          end
      end
      
      #           -- Bazicna podesavanja parametara TODO: Prevedi sve komentare
      rX = input[0].to_f
      rY = input[1].to_f
      h  = input[2].to_f
      a  = input[3].to_f
      n  = input[4].to_i
      l  = input[6].to_i

      raiseUp = input[7].to_f
      group = model.active_entities.add_group()
      if input[8].upcase == "X"
          changeAxis = Geom::Transformation.axes(ORIGIN,Y_AXIS,Z_AXIS,X_AXIS)
          group.transform!(changeAxis)
      elsif input[8].upcase == "Y"
          changeAxis = Geom::Transformation.axes(ORIGIN,Z_AXIS,X_AXIS,Y_AXIS)
          group.transform!(changeAxis)
      end
      entities = group.entities
      
      
      points = [
            Geom::Point3d.new(-0.5*a,-0.5*a,h+a),
            Geom::Point3d.new(0.5*a,-0.5*a,h+a),
            Geom::Point3d.new(0.5*a,0.5*a,h+a),
            Geom::Point3d.new(-0.5*a,0.5*a,h+a)
    ]
    
    
      #    -- Color settings
      choosed_color = nil
      color_option = ""
      if input_welcome[2].upcase == "Y" or input_welcome[2].upcase == "YES"
          prompts_color = ["Choose"]
          defaults_color = ["One color"]
          input_color = UI.inputbox(prompts_color,defaults_color,"How do you want to color your object?")
          if input_color[0].upcase == "ONE" or input_color[0].upcase == "ONE COLOR"
              color_option = "o"
              choosed_color = self.choose_color
          end
          if input_color[0].upcase == "ADC" or input_color[0].upcase == "ALL DIFFERENT COLORS"
              color_option = "d"
          end
      end

      angle= (360.degrees)/n  # Ugao izmedju svake uzastopne dve kopije objekta.
      k = 0
      for j in 0...l
         pX = rX * (j+1)
         pY = rY * (j+1)
         vector = Geom::Vector3d.new(pX,pY,0)
         translationT = Geom::Transformation.translation(vector)
         vectorUp = Geom::Vector3d.new(0,0,j*(a+raiseUp))
         translationUp = Geom::Transformation.translation(vectorUp)
         scalingT = Geom::Transformation.scaling(1+sX*j,1+sY*j,1+sZ*j)
         i_begin = 0
         i_end   = n
         if option_missing == "m"
             i_begin = k*((n/m).ceil)
             k = (k+1)%m
             i_end   = k*((n/m).ceil)
        elsif option_missing == "r"
            i_begin = @@random_generator.rand(0...n)
            i_end   = @@random_generator.rand(0...n)
            if i_end < i_begin
                i_begin -= n
            end
         end
         for i in i_begin...i_end
            if option_missing == "h" and i >= n/2
                    angle *= (-1)
                    break
            end
            group_in = entities.add_group()
            entities_in = group_in.entities
            face = entities_in.add_face(points)
            if color_option == "d"
                color_index = @@random_generator.rand(0...@@all_color_names.length)
                choosed_color = Sketchup::Color.new(@@all_color_names[color_index])
                face.material = choosed_color
            end
            if choosed_color != nil
                face.material = choosed_color
            end
            face.pushpull(a)
            group_in.transform!(scalingT)
            group_in.transform!(translationUp)
            
            rotationTL = Geom::Transformation.rotation(ORIGIN,Z_AXIS,i*0.7*angle)
            group_in.transform!(rotationTL)
            group_in.transform!(translationT)
            rotationT = Geom::Transformation.rotation(ORIGIN,Z_AXIS,i*angle)
            group_in.transform!(rotationT)
         end
     end
      
      #----------------------------------------------------------------------
      # Zavrsetak atomicne operacije.
    model.commit_operation
end

    # Neophodno za instalaciju plugin-a, petljom onemogucavamo visestruko ucitavanje fajla.
    unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    
    menu.add_item('Various'){
      self.various
    }
    file_loaded(__FILE__)
    end
end