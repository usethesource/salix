module examples::statemachine::IDE

import gui::App;
import gui::HTML;
import gui::Node;
import examples::statemachine::StateMachine;
import lib::codemirror::CodeMirror;
import lib::Mode;
import util::Maybe;
import ParseTree;
import String;
import List;
import IO;


App[Model] ideApp() 
  = app(init(), view, update, |http://localhost:8001|, |project://elmer/src|); 

alias Model = tuple[
  str src, 
  Maybe[start[Controller]] lastParse,
  Maybe[str] currentState,
  list[str] output
];
  
Maybe[start[Controller]] maybeParse(str src) {
  try {
    return just(parse(#start[Controller], src));
  }
  catch ParseError(loc err): {
    return nothing();
  }
}  
  
Model init() {
  registerCodeMirror();
  Model model = <"", nothing(), nothing(), []>;
  
  model.src = doors();
  model.lastParse = maybeParse(model.src);
  if (just(start[Controller] ctl) := model.lastParse) {
    if (examples::statemachine::StateMachine::State s <- ctl.top.states) {
      model.currentState = just("<s.name>");
    }
  }  
  return model;
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
  | fireEvent(str name)
  ;

Model update(Msg msg, Model model) {
  
  switch (msg) {
  
    case myChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed): { 
      model.src = updateSrc(model.src, fromLine, fromCol, toLine, toCol, text, removed);
      if (just(start[Controller] ctl) := maybeParse(model.src)) {
        model.lastParse = just(ctl);
        if (staleCurrentState(ctl, model)) {
          model.currentState = initialState(ctl);
        }
      }  
    }
    
    case fireEvent(str event): {
      if (just(start[Controller] ctl) := model.lastParse) {
        if (just(examples::statemachine::StateMachine::State s) := lookupCurrentState(ctl, model)) { 
          if (Transition t <- s.transitions, "<t.event>" == event) {
            model.currentState = just("<t.state>");
            if (just(Event e) := lookupEvent(ctl, event)) {
              model.output += ["<e.token>"];
            }
          }
        }
      } 
    }
  }
  
  return model;
}

list[str] mySplit(str sep, str s) {
  if (/^<before:.*?><sep>/m := s) {
    return [before] + mySplit(sep, s[size(before) + size(sep)..]);
  }
  return [s];
}

str updateSrc(str src, int fromLine, int fromCol, int toLine, int toCol, str text, str removed) {
  list[str] lines = mySplit("\n", src);
  int from = ( 0 | it + size(l) + 1 | str l <- lines[..fromLine] ) + fromCol;
  int to = from + size(removed);
  str newSrc = src[..from] + text + src[to..];
  return newSrc;  
}

Maybe[str] initialState(start[Controller] ctl) {
  if (examples::statemachine::StateMachine::State s <- ctl.top.states) {
	  return just("<s.name>");
  }
  return nothing();
}
 
Maybe[examples::statemachine::StateMachine::State] lookupCurrentState(start[Controller] ctl, Model model) {
  if (examples::statemachine::StateMachine::State s <- ctl.top.states, isCurrentState(s, model)) {
    return just(s);
  }
  return nothing();
}
 
Maybe[Event] lookupEvent(start[Controller] ctl, str event) {
  if (/Event e := ctl, event == "<e.name>") {
    return just(e);
  }
  return nothing();
} 
 
bool staleCurrentState(start[Controller] ctl, Model model) 
  = !any(examples::statemachine::StateMachine::State s <- ctl.top.states, isCurrentState(s, model));
 
bool isCurrentState(examples::statemachine::StateMachine::State s, Model model)
  = just(str current) := model.currentState && current == "<s.name>";

void view(Model model) {
  div(() {
    div(class("row"), () {
      div(class("col-md-12"), () {
	      h3("Simple live state machine IDE demo");
	    });
    });
    
    div(class("row"), () {
      div(class("col-md-6"), () {
        h4("Edit the state machine.");
        codeMirrorWithMode(stmMode(), onChange(myChange), height(500), 
            mode("statemachine"), indentWithTabs(false), lineNumbers(true), \value(model.src));
      });
        
      div(class("col-md-6"), () {
        if (just(start[Controller] ctl) := model.lastParse) {
          div(() {
            h4("Current state of state machine");
            ul(() {
              for (examples::statemachine::StateMachine::State s <- ctl.top.states) {
                li(() {
                  span(isCurrentState(s, model) ? style(<"font-weight", "bold">) : null(), "<s.name>: ");
                  for (Transition t <- s.transitions) {
                    button(onClick(fireEvent("<t.event>")), "<t.event> =\> <t.state>");
                  }
                });   
              }
            });
            h4("Output");
            ul(() {
              for (str token <- model.output) {
                li(token);
              }
            });   
          });
        }
      });
    });    
  });
}
