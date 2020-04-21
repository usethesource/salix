module salix::demo::basic::UML

import salix::App;
import salix::HTML;
import salix::Core;
import salix::lib::UML;

alias Model = tuple[str source];

SalixApp[Model] umlApp(str id = "root") = makeApp(id, init, view, update);

App[Model] umlWebApp() 
  = webApp(
      umlApp(),
      |project://salix/src/salix/demo/basic/index.html|, 
      |project://salix/src|
    );
    
Model init() = <"@startuml\nBob -\> Alice : hello\n@enduml\n">;

public str uml = "@startuml
'Class01 \<|-- Class02
'Class03 *-- Class04
'Class05 o-- Class06
'Class07 .. Class08
'Class09 -- Class10
'@enduml";

Model update(Msg _, Model m) = m;

void view(Model m) {
  div(() {
    h2("PlantUML integration");
    pre(m.source);
    div(uml2svgNode(m.source));
    div(uml2svgNode(uml));
  });
}