#!usr/bin/env ruby
require 'sketchup.rb'

module Central_reflextion
  def self.central_reflection_Z
    model = Sketchup.active_model
    
    # Zapocinjemo atomicnu proceduru, koju mozemo da ponistimo izjedna.
    model.start_operation("Central reflextion around z-axis(vertical axis)")
    # Hvatamo sve objekte koji su selektovani
    selected = model.selection
    
    # Provera da li je ista selektovano.
    if selected.empty?
      UI.messagebox("Nothing selected")
      return
    end
    
    # Kreiramo grupu na kojoj cemo izvrsiti centralnu refleksiju.
    selected_array = selected.to_a
    group = model.active_entities.add_group(selected_array)
   
    # Kreiramo objekat klase Transformation koji predstavlja centralnu refleksiju.
    point = ORIGIN      # Koordinatni pocetak
    axis  = Geom::Vector3d.new(0,0,1) # z-osa
    angle = 180.degrees # Ovako se ugao konvertuje u radiane, jer funkcija za kreiranje transformacije prima ugao u radianima
    central_reflection_transformation = Geom::Transformation.rotation(point,axis,angle)
    
    # Primenimo kreiranu transformaciju na grupu.
    group.transform!(central_reflection_transformation)
    
    # Zavrsetak atomicne operacije.
    model.commit_operation
    
  end
  # Neophodno za instalaciju plugin-a, petljom onemogucavamo visestruko ucitavanje fajla.
  unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    
    menu.add_item('Central reflection around vertical (z) axis.'){
      self.central_reflection_Z
    }
    file_loaded(__FILE__)
  end
end