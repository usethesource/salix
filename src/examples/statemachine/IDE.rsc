module examples::statemachine::IDE

import gui::App;
import gui::HTML;
import examples::statemachine::StateMachine;
import lib::codemirror::CodeMirror;
import lib::Mode;
import util::Maybe;


App[Model] ideApp() 
  = app(init(), view, update, |http://localhost:8001|, |project://elmer/src|); 

alias Model
  = tuple[str src, Maybe[start[Controller]] lastParse];
  
Model init() {
  registerCodeMirror();
  return <doors(), nothing()>;
}

str doors() = 
    "events
    '  open OPEN
    '  close CLOSE
    'end
    '
    'state closed
    '  open =\> opened
    'end
    '
    'state opened
    '  close =\> closed
    'end";

Mode stmMode() = grammar2mode("statemachine", #Controller);

data Msg
  = myChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed);

Model update(Msg msg, Model model) {
  
  switch (msg) {
  
    case myChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed): 
      ;
  }
  
  return model;
}

void view(Model model) {
  div(() {
    h3("State machines");
    codeMirrorWithMode(stmMode(), style(("height": "auto")), onChange(myChange), 
        mode("statemachine"), lineNumbers(true), \value(model.src));
        
  });
}
