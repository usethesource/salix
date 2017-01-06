module salix::demo::ide::IDE

import salix::App;
import salix::HTML;
import salix::Node;
import salix::Core;
import salix::demo::ide::StateMachine;
import salix::lib::CodeMirror;
import salix::lib::XTerm;
import salix::lib::Mode;
import util::Maybe;
import ParseTree;
import String;
import List;
import IO;


App[Model] ideApp() 
  = app(init, view, update, |http://localhost:8001|, |project://salix/src|); 

alias Model = tuple[
  str src, 
  Maybe[start[Controller]] lastParse,
  Maybe[str] currentState,
  list[str] output,
  str currentCommand
];
  
Maybe[start[Controller]] maybeParse(str src) {
  try {
    return just(parse(#start[Controller], src));
  }
  catch ParseError(loc err): {
    return nothing();
  }
}  
  
WithCmd[Model] init() {
  registerCodeMirror();
  registerXTerm();
  Model model = <"", nothing(), nothing(), [], "">;
  
  model.src = doors();
  model.lastParse = maybeParse(model.src);
  if (just(start[Controller] ctl) := model.lastParse) {
    if (salix::demo::ide::StateMachine::State s <- ctl.top.states) {
      model.currentState = just("<s.name>");
    }
  }  
  return withCmd(model, write(noOp(), "myXterm", "\r\n$ "));
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
  | noOp()
  | xtermData(str txt)
  ;

WithCmd[Model] update(Msg msg, Model model) {
  Cmd cmd = none();
  
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
        if (just(salix::demo::ide::StateMachine::State s) := lookupCurrentState(ctl, model)) { 
          if (Transition t <- s.transitions, "<t.event>" == event) {
            model.currentState = just("<t.state>");
            if (just(Event e) := lookupEvent(ctl, event)) {
              model.output += ["<e.token>"];
            }
          }
        }
      } 
    }
    
    case xtermData(str s): {
      if (s == "\r") {
        cmd = write(fireEvent(model.currentCommand), "myXterm", "\r\n$ ");
        model.currentCommand = "";
      }
      else {
        model.currentCommand += s;
        cmd = write(noOp(), "myXterm", s);
      }
    }
  }
  
  return withCmd(model, cmd);
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
  if (salix::demo::ide::StateMachine::State s <- ctl.top.states) {
	  return just("<s.name>");
  }
  return nothing();
}
 
Maybe[salix::demo::ide::StateMachine::State] lookupCurrentState(start[Controller] ctl, Model model) {
  if (salix::demo::ide::StateMachine::State s <- ctl.top.states, isCurrentState(s, model)) {
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
  = !any(salix::demo::ide::StateMachine::State s <- ctl.top.states, isCurrentState(s, model));
 
bool isCurrentState(salix::demo::ide::StateMachine::State s, Model model)
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
        codeMirrorWithMode("myCodeMirror", stmMode(), onChange(myChange), height(300), 
            mode("statemachine"), indentWithTabs(false), lineNumbers(true), \value(model.src));
      });
        
      div(class("col-md-6"), () {
        if (just(start[Controller] ctl) := model.lastParse) {
          div(() {
            h4("Current state of state machine");
            ul(() {
              for (salix::demo::ide::StateMachine::State s <- ctl.top.states) {
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
    
    div(class("row"), () {
      div(class("col-md-9"), () {
        xterm("myXterm", cursorBlink(true), onData(xtermData), cols(50), rows(10));      
      });
    });    
  });
}
