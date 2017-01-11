@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::ide::IDE

import salix::App;
import salix::HTML;
import salix::Node;
import salix::Core;
import salix::demo::ide::StateMachine;
import salix::lib::CodeMirror;
import salix::lib::XTerm;
import salix::lib::Mode;
import salix::lib::REPL;
import util::Maybe;
import ParseTree;
import String;
import List;
import IO;


App[IDEModel] ideApp() 
  = app(ideInit, ideView, ideUpdate, 
        |http://localhost:8001|, |project://salix/src|, parser = parseMsg); 

alias IDEModel = tuple[
  str src, 
  Maybe[start[Controller]] lastParse,
  Maybe[str] currentState,
  list[str] output,
  str currentCommand,
  Mode mode, // put it here, so not regenerated at every click..
  REPLModel repl
];
  
Maybe[start[Controller]] maybeParse(str src) {
  try {
    return just(parse(#start[Controller], src));
  }
  catch ParseError(loc err): {
    return nothing();
  }
}  
  
IDEModel ideInit() {
  replModel = mapCmds(Msg::repl, REPLModel() { return initRepl("myXterm", "$ "); });
  Mode stmMode = grammar2mode("statemachine", #Controller);
  IDEModel model = <"", nothing(), nothing(), [], "", stmMode, replModel>;
  
  model.src = doors();
  model.lastParse = maybeParse(model.src);
  if (just(start[Controller] ctl) := model.lastParse) {
    if (salix::demo::ide::StateMachine::State s <- ctl.top.states) {
      model.currentState = just("<s.name>");
    }
  }  
 
  return model;
}

list[str] stmComplete(IDEModel model, str prefix) {
  list[str] cs = [];
  if (just(start[Controller] ctl) := model.lastParse) {
    if (/<word:[a-zA-Z0-9_]+>$/ := prefix) {
      for (salix::demo::ide::StateMachine::State s <- ctl.top.states, startsWith("<s.name>", word)) {
        cs += ["<prefix[0..size(prefix) - size(word)]><s.name>"];
      }
      for (/salix::demo::ide::StateMachine::Event e := ctl, startsWith("<e.name>", word)) {
        cs += ["<prefix[0..size(prefix) - size(word)]><e.name>"];
      }
    }
  }
  return cs + [prefix];
}

Maybe[str] stmHighlight(str x) {
  if (/goto <rest:.*>/ := x) {
    return just("\u001B[1;35mgoto\u001B[0m <rest>");
  }
  if (/event <rest:.*>/ := x) {
    return just("\u001B[1;35mevent\u001B[0m <rest>");
  }
  else {
    return nothing();
  }
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

data Msg
  = stmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed)
  | fireEvent(str name)
  | gotoState(str name)
  | repl(Msg msg)
  | noOp()
  ;

tuple[Msg, str] myEval(str command) {
  if (/event <event:.*>/ := command) {
    return <fireEvent(event), "ok">;
  }
  if (/goto <state:.*>/ := command) {
    return <gotoState(state), "ok">;
  }
  return <noOp(), "nothing">;
}


alias Next = tuple[Maybe[str] token, Maybe[str] state];

Next transition(str currentState, str event, start[Controller] ctl) {
  Next result = <nothing(), nothing()>;
  
  if (salix::demo::ide::StateMachine::State s <- ctl.top.states, "<s.name>" == currentState) { 
    if (Transition t <- s.transitions, "<t.event>" == event) {
      result.state = just("<t.state>");
      if (just(Event e) := lookupEvent(ctl, event)) {
        result.token = just("<e.token>");
      }
    }
  }
  
  return result;
} 

IDEModel ideUpdate(Msg msg, IDEModel model) {

  list[str] myComplete(str prefix) = stmComplete(model, prefix);
  
  void doTransition(str event) {
    if (just(start[Controller] ctl) := model.lastParse) {
      if (just(str current) := model.currentState) {
        Next nxt = transition(current, event, ctl);
        if (just(str nextState) := nxt.state) {
          model.currentState = just(nextState);
        }
        if (just(str token) := nxt.token) {
          model.output += [token];
          do(write(noOp(), model.repl.id, "\b\b\u001B[31m<token>\u001B[0m\r\n<model.repl.prompt>"));
        }
      }
    }
  }
  
  switch (msg) {
  
    case stmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed): { 
      model.src = updateSrc(model.src, fromLine, fromCol, toLine, toCol, text, removed);
      if (just(start[Controller] ctl) := maybeParse(model.src)) {
        model.lastParse = just(ctl);
        if (staleCurrentState(ctl, model)) {
          model.currentState = initialState(ctl);
        }
      }  
    }
    
    // wrapping this in repl() is bad, but mapping prevents stuff produced in the repl
    // to surface back here; it's really hard to communicate from
    // contained components to parents...
    case repl(parent(gotoState(str state))): {
       if (just(start[Controller] ctl) := model.lastParse) {
         if (salix::demo::ide::StateMachine::State s <- ctl.top.states, "<s.name>" == state) {
           model.currentState = just("<s.name>");
         } 
       }
     }
    
    // even worse, this one can be generated by the repl, but
    // also at this level, so two cases are needed. 
    // so, 3 options:
    // - multiple cases; maybe this is the least bad... the cases
    //   identify origins of messages.
    //   this is still bad: in Elm the type system would
    //   prevent it even: kid Msg != parent Msg
    
    // - cheating with side-effects on model in eval (depends on capturing environments)
    // - not do mapping on repl (this means xtermData enters the parent namespace)
    //   and need ugly default to go to repl update...
    
    case repl(parent(fireEvent(str event))): 
      doTransition(event);
      
    case fireEvent(str event): 
      doTransition(event);

    case repl(Msg sub): 
      model.repl = mapCmds(Msg::repl, sub, model.repl, replUpdate(myEval, myComplete, stmHighlight));

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
  if (salix::demo::ide::StateMachine::State s <- ctl.top.states) {
	  return just("<s.name>");
  }
  return nothing();
}
 
Maybe[salix::demo::ide::StateMachine::State] lookupCurrentState(start[Controller] ctl, IDEModel model) {
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
 
bool staleCurrentState(start[Controller] ctl, IDEModel model) 
  = !any(salix::demo::ide::StateMachine::State s <- ctl.top.states, isCurrentState(s, model));
 
bool isCurrentState(salix::demo::ide::StateMachine::State s, IDEModel model)
  = just(str current) := model.currentState && current == "<s.name>";

void ideView(IDEModel model) {
  div(() {
    div(class("row"), () {
      div(class("col-md-12"), () {
	      h3("Simple live state machine IDE demo");
	    });
    });
    
    div(class("row"), () {
      div(class("col-md-6"), () {
        h4("Edit the state machine.");
        codeMirrorWithMode("myCodeMirror", model.mode, onChange(stmChange), height(500), 
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
            h4("Command line");
            repl(Msg::repl, model.repl, model.repl.id, cursorBlink(true), cols(30), rows(10));       
          });
        }
      });
    });
    
  });
}
