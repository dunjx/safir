#!usr/bin/env ruby
require 'sketchup.rb'

module Repeating_objects_around
  def self.repeat_around
    model = Sketchup.active_model
    # Zapocinjemo atomicnu proceduru, koju mozemo da ponistimo izjedna.
    model.start_operation("Repeat selected objects around z-axis",true)
    # Hvatamo sve objekte koji su selektovani.
    selected = model.selection
    
    # Provera da li je ista selektovano.
    if selected.empty?
      UI.messagebox("Nothing selected")
      return
    end
    # Kreiramo grupu od selektovanih objekata.
    selected_array = selected.to_a
    group = model.active_entities.add_group(selected_array)
    
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
    # Zavrsetak atomicne operacije.
    model.commit_operation
  end
  # Neophodno za instalaciju plugin-a, petljom onemogucavamo visestruko ucitavanje fajla.
    unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    
    menu.add_item('Repeating around vertical z-axis'){
      self.repeat_around
    }
    file_loaded(__FILE__)
    end
end
