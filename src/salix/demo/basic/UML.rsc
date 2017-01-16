module salix::demo::basic::UML

import salix::App;
import salix::HTML;
import salix::Core;
import salix::lib::UML;

import IO;

alias Model = tuple[str source];


App[Model] umlApp() = app(init, view, update, |http://localhost:9120|, |project://salix/src|); 
    
Model init() = <"@startuml\nBob -\> Alice : hello\n@enduml\n">;



Model update(Msg msg, Model m) = m;


void view(Model m) {
  div(() {
    h2("PlantUML integration");
    pre(m.source);
    div(uml2svgNode(m.source));
  });
}