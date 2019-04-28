#!usr/bin/env ruby
require 'sketchup.rb'

class Test2
  def activate
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
    end
  end
    
end
  
SKETCHUP_CONSOLE.show

UI.menu("Plugins").add_item("Test2"){
  Sketchup.active_model.select_tool(Test2.new())
}