module salix::lib::REPL

import salix::lib::XTerm;
import salix::App;
import salix::Core;
import salix::HTML;

import util::Maybe;
import util::Reflective;
import ParseTree;
import List;
import IO;
import String;


alias REPLModel = tuple[
  str id,
  str prompt,
  list[str] history,
  int pointer,
  str currentLine,
  list[str] completions,
  int cycle
];

REPLModel initRepl(str id, str prompt) {
  do(write(noOp(), id, prompt));
  return <id, prompt, [], 0, "", [], -1>;
} 
  
data Msg
  = xtermData(str s)
  | noOp()
  ;
  
  
REPLModel replaceLine(REPLModel model, str newLine, Maybe[str](str) hl) {
  do(writeLine(model, newLine, hl));
  return model[currentLine=newLine];
} 

Cmd writeLine(REPLModel model, str newLine, Maybe[str](str) hl) {
  str zap = ( "\r" | it + " " | int _ <- [0..size(model.currentLine) + size(model.prompt)] );
  if (just(str highlighted) := hl(newLine)) {
    newLine = highlighted;
  }
  return write(noOp(), model.id, "<zap>\r<model.prompt><newLine>");
}

REPLModel(Msg, REPLModel) replUpdate(tuple[Msg, str](str) eval, list[str](str) complete, Maybe[str](str) highlight) 
  = REPLModel(Msg msg, REPLModel rm) {
      return replUpdate(eval, complete, highlight, msg, rm);
    };

REPLModel replUpdate(tuple[Msg, str](str) eval, list[str](str) complete, Maybe[str](str) highlight, Msg msg, REPLModel model) {
  
  switch (msg) {
    case xtermData(str s): {
      if (s != "\t") {
        model.cycle = -1;
      }
      if (s == "\r") {
        <evalMsg, result> = eval(model.currentLine);
        do(write(evalMsg, model.id, "\r\n<result>\r\n<model.prompt>"));
        model.history += [model.currentLine];
        model.pointer = size(model.history);
        model.currentLine = "";
      }
      else if (s == "\a7f") { 
        if (model.currentLine != "" ) {
          model.currentLine = model.currentLine[0..-1];
          do(write(noOp(), model.id, "\b \b"));
        }
      }
      else if (s == "\a1b[A") { // arrow up
        if (model.pointer > 0) {
          model.pointer -= 1;
          model = replaceLine(model, model.history[model.pointer], highlight); 
        }
      }
      else if (s == "\a1b[B") { // arrow down
        if (model.pointer < size(model.history) - 1) {
	        model.pointer += 1;
	        model = replaceLine(model, model.history[model.pointer], highlight);
        }
      }
      else if (s == "\t") {
        if (model.cycle == -1) {
          model.completions = complete(model.currentLine);
        }
        if (model.cycle < size(model.completions) - 1) {
          model.cycle += 1;
        }
        else {
          model.cycle = 0;
        }
        str comp = model.completions[model.cycle];
        model = replaceLine(model, model.completions[model.cycle], highlight);
      }
      else {
        model.currentLine += s;
        if (just(str x) := highlight(model.currentLine)) {
          do(writeLine(model, x, highlight));
        }
        else {
          do(write(noOp(), model.id, s));
        }
      }
    }
  }
  
  return model;
}  


void repl(Msg(Msg) f, REPLModel m, str id, value vals...) {
   mapView(f, m, repl(id, vals));
}

void(REPLModel) repl(str id, value vals...) {
  return void(REPLModel m) {
     xterm(id, [onData(xtermData)] + vals); 
  };
}

