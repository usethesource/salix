module examples::statemachine::IDE

import gui::App;
import gui::HTML;
import examples::statemachine::StateMachine;
import lib::codemirror::CodeMirror;
import lib::Mode;
import util::Maybe;
import ParseTree;
import String;
import List;


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
  
    case myChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed): { 
      model.src = updateSrc(model.src, fromLine, fromCol, toLine, toCol, text, removed);
      if (just(start[Controller] ctl) := maybeParse(model.src)) {
        model.lastParse = just(ctl);
      }  
    }
  }
  
  return model;
}

str updateSrc(str src, int fromLine, int fromCol, int toLine, int toCol, str text, str removed) {
  list[str] lines = split("\n", src);
  int from = ( 0 | it + size(l) + 1 | str l <- lines[..fromLine] ) + fromCol;
  int to = from + size(removed);
  str newSrc = src[..from] + text + src[to..];
  return newSrc;  
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
