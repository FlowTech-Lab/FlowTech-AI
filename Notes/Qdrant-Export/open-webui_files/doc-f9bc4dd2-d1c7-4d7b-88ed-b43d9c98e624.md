---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.846059'
id: f9bc4dd2-d1c7-4d7b-88ed-b43d9c98e624
title: doc-f9bc4dd2-d1c7-4d7b-88ed-b43d9c98e624
---

### ✍️ Snippets essentiels
```rb
# app.rb — point d'entrée
require_relative "lib/router"
Router.new.perform
```
```rb
# lib/router.rb — menu boucle + dispatch
require_relative "controller"
class Router
  def initialize; @controller = Controller.new; end
  def perform
    puts "Bienvenue"
    loop do
      puts "1. Créer  2. Lister  3. Supprimer  4. Quitter"
      case STDIN.gets.to_i
      when 1 then @controller.create_entity
      when 2 then @controller.index_entities
      when 3 then @controller.destroy_entity
      when 4 then break
      else puts "Choix invalide"
      end
    end
  end
end
```
```rb
# lib/controller.rb — orchestration
require_relative "view"
require_relative "entity"
class Controller
  def initialize; @view = View.new; end

  def create_entity
    params = @view.form_entity # {author:, content:}
    entity = Entity.new(params[:author], params[:content])
    entity.save
    @view.notice("Créé")
  end