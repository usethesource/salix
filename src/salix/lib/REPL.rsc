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
  list[str] history,
  int pointer,
  str currentLine,
  Msg(str) eval,
  str(str) complete
];

WithCmd[Model] initRepl(str id, Msg(str) eval, str(str) complete) 
  = withCmd(<id, [], 0, "", eval, complete>, write(noOp(), id, "$ ")); 
  
data Msg
  = xtermData(str s)
  | noOp()
  | dummy(str s)  
  ;
  

WithCmd[Model] update(Msg msg, Model model) {
  Cmd cmd = none();
  
  switch (msg) {
    case xtermData(str s): {
      if (s == "\r") {
        cmd = write(model.eval(model.currentLine), model.id, "\r\n$ ");
        model.history += [model.currentLine];
        model.pointer = size(model.history);
        model.currentLine = "";
      }
      else if (s == "\a7f") {
        cmd = write(noOp(), id, "\b");
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
        str completion = model.complete(model.currentLine);
        cmd = write(noOp(), model.id, completion[size(model.currentLine)..]);
        model.currentLine = completion;
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

str dummyCompleter(str prefix) {
  list[str] xs = ["aap", "noot", "mies"];
  for (str x <- xs) {
    if (startsWith(x, prefix)) {
      return x;
    }
  }
  return prefix;
}

WithCmd[Model] init() = initRepl("x", dummy, dummyCompleter);

App[Model] replApp()
  = app(init, sampleView, update, |http://localhost:5001|, |project://salix/src|
       parser = parseMsg);

void sampleView(Model m) {
  div(() {
    h4("Command line");
    repl("x", cursorBlink(true), cols(25), rows(10))(m);
  });       
}

