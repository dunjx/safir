require 'sketchup.rb'

module Examples
  module Rotiraj

    class RotUKrug

      def activate
        view = Sketchup.active_model.active_view
        @state = 0
        @ip1 = Sketchup::InputPoint.new
        @ip2 = Sketchup::InputPoint.new
        @model=Sketchup.active_model
        @selection=@model.selection
        @locked=[]
        #Prolazi kroz selection dok ne dodje do grupe ili instance.
        @selection.each do |e|
          next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
          @locked << e if e.locked?
		end
		
		@selection.remove(@locked) if @locked[0]
		#Ako nista nije selektovano, ispisuje se poruka.
    if @selection.empty?
       @selection.add(@locked) if @locked[0]
       
       Sketchup::set_status_text("Nothing is selected!")
       UI.messagebox("Select Something!")
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
        reset_tool
        view.invalidate
      end

      def onMouseMove(flags, x, y, view)
        if @ip2.valid?
          @ip1.pick(view, x, y, @ip2)
        else
          @ip1.pick(view, x, y)
        end
        view.tooltip = @ip1.tooltip if @ip1.valid?
        view.invalidate
      end

      def onLButtonDown(flags, x, y, view)
        if  @ip2.valid?
          rotate_in_circle(view,picked_points)
        else
          @ip2.copy!(@ip1) if @ip1.valid?
        end
        view.invalidate
      end
      
      def draw(view)
        draw_preview(view)
        @ip1.draw(view) if @ip1.display?
      end

      def reset_tool
        @ip2.clear
      end
      
      def picked_points
        points = []
        points << @ip2.position if @ip2.valid?
        points << @ip1.position if @ip1.valid?
        points
      end

      def draw_preview(view)
        points = picked_points
        return unless points.size == 2
        draw_picked_points(view, points)
        rotate_in_circle(view, points)
      end

      def draw_picked_points(view, points)
        view.drawing_color = 'purple'
        view.set_color_from_line(*points)
        view.line_width = 1
        view.line_stipple = ''
        view.draw(GL_LINES, points)
      end

      def rotate_in_circle(view, points)
        origin, end_p = points
        vector = origin.vector_to(end_p)
        
        #draw(view)
        return unless vector.valid?
        if activate == "ok"
          selected_array = @selection.to_a
          group = @model.active_entities.add_group(selected_array)
          
          prompts = ["n","m"]
          defaults = ["6",""]
          input = UI.inputbox(prompts,defaults,"Number of objects: ")
    
          n = input[0].to_i
          m = input[1].to_i
          angle = (360.degrees)/n
          
          for i in 1...n
            break if i == m
            # Pravimo kopiju selektovane grupe sa pocetka.
            group_copy = group.copy
            # Kreiramo objekat - transformaciju.
            transformation = Geom::Transformation.rotation(origin,vector,angle*i)
            # Primenjujemo je nad kopijom grupe.
            group_copy.transform!(transformation)
          end
          @model.commit_operation
        end
      end
      
      def create_rotate
        origin, end_p = picked_points
        group = @model.active_entities.add_group
        vector = origin.vector_to(end_p)
        return unless vector.valid?
        
        if activate == "ok"
          selected_array = @selection.to_a
          group = model.active_entities.add_group(selected_array)
          
          prompts = ["n","m"]
          defaults = ["6",""]
          input = UI.inputbox(prompts,defaults,"Number of objects: ")
    
          n = input[0].to_i
          m = input[1].to_i
          angle = (360.degrees)/n
          
          for i in 1...n
            break if i == m
            # Pravimo kopiju selektovane grupe sa pocetka.
            group_copy = group.copy
            # Kreiramo objekat - transformaciju.
            transformation = Geom::Transformation.rotation(origin,vector,angle*i)
            # Primenjujemo je nad kopijom grupe.
            group_copy.transform!(transformation)
          end
          @model.commit_operation
        end
      end

    end # class

    unless file_loaded?(__FILE__)
      menu = UI.menu('Plugins')
      menu.add_item('Rotiraj Test') {
        Sketchup.active_model.select_tool(RotUKrug.new)
      }
      file_loaded(__FILE__)
    end

  end
end
