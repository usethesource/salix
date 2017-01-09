module salix::lib::REPL

import salix::lib::XTerm;
import salix::App;
import salix::Core;
import salix::HTML;

import List;
import IO;
import String;


alias Model = tuple[
  str id,
  str prompt,
  list[str] history,
  int pointer,
  str currentLine,
  Msg(str) eval,
  list[str] completions,
  int cycle,
  list[str](str) complete
];

WithCmd[Model] initRepl(str id, str prompt, Msg(str) eval, list[str](str) complete) 
  = withCmd(<id, prompt, [], 0, "", eval, [], -1, complete>, write(noOp(), id, prompt)); 
  
data Msg
  = xtermData(str s)
  | noOp()
  | dummy(str s)  
  ;
  

WithCmd[Model] update(Msg msg, Model model) {
  Cmd cmd = none();
  
  switch (msg) {
    case xtermData(str s): {
      if (s != "\t") {
        model.cycle = -1;
      }
      if (s == "\r") {
        cmd = write(model.eval(model.currentLine), model.id, "\r\n<model.prompt>");
        model.history += [model.currentLine];
        model.pointer = size(model.history);
        model.currentLine = "";
      }
      else if (s == "\a7f") {
        cmd = write(noOp(), model.id, "\b");
      }
      else if (s == "\a1b[A") { // arrow up
        if (model.pointer > 0) {
          model.pointer -= 1;
          str back = ( "" | it + "\b" | int _ <- [0..size(model.currentLine)] );
          model.currentLine = model.history[model.pointer];
          cmd = write(noOp(), model.id, back + model.currentLine);
        }
      }
      else if (s == "\a1b[B") { // arrow down
        if (model.pointer < size(model.history) - 1) {
	        model.pointer += 1;
          str back = ( "" | it + "\b" | int _ <- [0..size(model.currentLine)] );
          model.currentLine = model.history[model.pointer];
          cmd = write(noOp(), model.id, back + model.currentLine);
        }
      }
      else if (s == "\t") {
        // TODO: put in model
        // it always at least contains the prefix itself.
        //println("Completions after: <model.completions> @ <model.cycle>");
        if (model.cycle == -1) {
          model.completions = model.complete(model.currentLine);
        }
        if (model.cycle < size(model.completions) - 1) {
          model.cycle += 1;
        }
        else {
          model.cycle = 0;
        }
        //println("Completions after: <model.completions> @ <model.cycle>");
        str comp = model.completions[model.cycle];
        str back = ( "\r" | it + " " | int _ <- [0..size(model.currentLine) + size(model.prompt)] );
        cmd = write(noOp(), model.id,  back + "\r<model.prompt>" + comp);
        model.currentLine = comp;
      }
      else if (/[a-zA-Z0-9_]/ := s) {
        model.currentLine += s;
        cmd = write(noOp(), model.id, s);
      }
      else {
        println("Unrecognized: <s>");
      }
    }
    case dummy(str s):
      println("Command: <s>");
  }
  
  return withCmd(model, cmd);
}  


void repl(Msg(Msg) f, Model m, str id, value vals...) {
   mapView(f, m, repl(id, vals));
}

void(Model) repl(str id, value vals...) {
  return void(Model m) {
     xterm(id, [onData(xtermData)] + vals); 
  };
}

list[str] dummyCompleter(str prefix) {
  list[str] xs = ["aap", "nooit", "noot", "mies", "muis"];
  return [ x | x <- xs, startsWith(x, prefix) ] + [prefix];
}

WithCmd[Model] init() = initRepl("x", "$ ", dummy, dummyCompleter);

App[Model] replApp()
  = app(init, sampleView, update, |http://localhost:5001|, |project://salix/src|
       parser = parseMsg);

Msg identity(Msg m) = m;

void sampleView(Model m) {
  div(() {
    h4("Command line");
    repl(identity, m, "x", cursorBlink(true), cols(25), rows(10));
  });       
}

