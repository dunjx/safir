#!usr/bin/env ruby
require 'sketchup.rb'

class Repeating_objects_around
  
  def self.activate
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
  
  def self.repeat_around
    if self.activate == "ok"
  
      # Kreiramo grupu od selektovanih objekata.
      selection_array = @selection.to_a
      group = @model.active_entities.add_group(selection_array)
  
      # Korisnik unosi n - broj zelejenih kopija objekata u krug(podrazumevana vrednost je 6).
      prompts = ["n"]
      defaults = ["6"]
      input = UI.inputbox(prompts,defaults,"Number of objects: ")
  
      n = input[0].to_i
  
      # Na osnovu unete vrednosti n kreiramo parametre za transformaciju.
      point = ORIGIN  # Koordinatni pocetak
      vector = Geom::Vector3d.new(0,0,1) # Vektor oko kog cemo kopirati objekte.
      angle= (360.degrees)/n  # Ugao izmedju svake uzastopne dve kopije objekta.
  
      # Kopiramo redom objekte u krug.
      for i in 1...n
        # Pravimo kopiju selektovane grupe sa pocetka.
        group_copy = group.copy
        # Kreiramo objekat - transformaciju.
        transformation = Geom::Transformation.rotation(point,vector,angle*i)
        # Primenjujemo je nad kopijom grupe.
        group_copy.transform!(transformation)
      end
  end #Kraj ifa
    # Zavrsetak atomicne operacije.
    @model.commit_operation
  end #kraj metode repeat_around
end  #kraj klase
SKETCHUP_CONSOLE.show

UI.menu("Extensions").add_item("centralna simetrija"){
  Sketchup.active_model.select_tool(Repeating_objects_around.repeat_around)
}
