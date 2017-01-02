module examples::statemachine::IDE

import gui::App;
import gui::HTML;
import examples::statemachine::StateMachine;
import lib::codemirror::CodeMirror;
import lib::Mode;
import util::Maybe;
import ParseTree;


App[Model] ideApp() 
  = app(init(), view, update, |http://localhost:8001|, |project://elmer/src|); 

alias Model = tuple[
  str src, 
  Maybe[start[Controller]] lastParse
];
  
Maybe[start[Controller]] maybeParse(str src) {
  try {
    return just(parse(#start[Controller], src));
  }
  catch ParseError(_): {
    return nothing();
  }
}  
  
Model init() {
  registerCodeMirror();
  return <doors(), maybeParse(doors())>;
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
  = myChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed)
  | fireEvent(str name, str token)
  ;

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
    
    if (just(start[Controller] ctl) := model.lastParse) {
      div(() {
        for (/Event e := ctl) {
          button(onClick(fireEvent("<e.name>", "<e.token>")), "<e.name>");
        }   
      });
    }
        
  });
}
