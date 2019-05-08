require 'sketchup.rb'

module NewPlugins
  module CentrRot

    class RotateInCircle
#Start of a plugin function, the activation and declaration.
      def activate
        view = Sketchup.active_model.active_view
        @state = 0
        @ip1 = Sketchup::InputPoint.new
        @ip2 = Sketchup::InputPoint.new
        @model=Sketchup.active_model
        @selection=@model.selection
        @locked=[]
        #Iteration trough selected object until valid group or instance is found.
        @selection.each do |e|
          next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
          @locked << e if e.locked?
		end
		
		@selection.remove(@locked) if @locked[0]
		#If nothing is selected, message is printed.
    if @selection.empty?
       @selection.add(@locked) if @locked[0]
       
       Sketchup::set_status_text("Nothing is selected!")
       UI.messagebox("Select Something!")
       #Picking of a selection tool.
       Sketchup.send_action("selectSelectionTool:")
       return nil
    else
    return "ok"
    end 
  end

      def deactivate(view)
        view.invalidate
      end

      def resume(view)
        view.invalidate
      end

      def onCancel(reason, view)
        @ip2.clear
        view.invalidate
      end
#On mouse move, function detects that a new point of a line should be picked.
      def onMouseMove(flags, x, y, view)
        if @ip2.valid?
          @ip1.pick(view, x, y, @ip2)
        else
          @ip1.pick(view, x, y)
        end
        view.tooltip = @ip1.tooltip if @ip1.valid?
        view.invalidate
      end
#On button click, if both points are selected and valid, line is drawn and rotation is started.
      def onLButtonDown(flags, x, y, view)
        if  @ip2.valid?
          draw(view)
          rotate_in_circle(view,picked_points)
        else
          @ip2.copy!(@ip1) if @ip1.valid?
        end
        view.invalidate
      end
 #Method draws a line.     
      def draw(view)
        @ip1.draw(view) if @ip1.display?
        points = picked_points
        return unless points.size == 2
        draw_picked_points(view, points)
      end

      def reset_tool
        @ip2.clear
      end
#Selected points are put in a array.      
      def picked_points
        points = []
        points << @ip2.position if @ip2.valid?
        points << @ip1.position if @ip1.valid?
        points
      end
      
      def draw_picked_points(view, points)
        view.drawing_color = 'purple'
        view.set_color_from_line(*points)
        view.line_width = 1
        view.line_stipple = ''
        view.draw(GL_LINES, points)
      end

      def draw_preview(view)
        points = picked_points
        return unless points.size == 2
        draw_picked_points(view, points)
      end      

#Main method for rotation.
      def rotate_in_circle(view, points)
      #Origin point and end point declaration.
        origin, end_p = points
        vector = origin.vector_to(end_p) #Vector is made fron origin poin to end point.
        
        return unless vector.valid?
        if activate == "ok"
          #A group is made out of valid selection.
          selected_array = @selection.to_a
          group = @model.active_entities.add_group(selected_array)
          
          prompts = ["Number of symmetry axis: ","Number of iterations to be drawn: "]
          defaults = ["6",""]
          input = UI.inputbox(prompts,defaults,"New group: ")
    
          n = input[0].to_i
          m = input[1].to_i
          angle = (360.degrees)/n
          
          for i in 1...n
            break if i == m
            #Copy of a selected group.
            group_copy = group.copy
            #Transformation call.
            transformation = Geom::Transformation.rotation(origin,vector,angle*i)
            #Application of tranformation to a group copy.
            group_copy.transform!(transformation)
          end
          @model.commit_operation
        end
      end

    end #class

    unless file_loaded?(__FILE__)
      menu = UI.menu('Plugins')
      menu.add_item('Circular Rotation') {
        Sketchup.active_model.select_tool(RotateInCircle.new)
      }
      file_loaded(__FILE__)
    end

  end
end