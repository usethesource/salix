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

WithCmd[REPLModel] initRepl(str id, str prompt) 
  = withCmd(<id, prompt, [], 0, "", [], -1>, write(noOp(), id, prompt)); 
  
data Msg
  = xtermData(str s)
  | noOp()
  ;
  
  
WithCmd[REPLModel] replaceLine(REPLModel model, str newLine, Maybe[str](str) hl) 
  = withCmd(model[currentLine=newLine], writeLine(model, newLine, hl));

Cmd writeLine(REPLModel model, str newLine, Maybe[str](str) hl) {
  str zap = ( "\r" | it + " " | int _ <- [0..size(model.currentLine) + size(model.prompt)] );
  if (just(str highlighted) := hl(newLine)) {
    newLine = highlighted;
  }
  return write(noOp(), model.id, "<zap>\r<model.prompt><newLine>");
}

WithCmd[REPLModel](Msg, REPLModel) replUpdate(tuple[Msg, str](str) eval, list[str](str) complete, Maybe[str](str) highlight) 
  = WithCmd[REPLModel](Msg msg, REPLModel rm) {
      return replUpdate(eval, complete, highlight, msg, rm);
    };

WithCmd[REPLModel] replUpdate(tuple[Msg, str](str) eval, list[str](str) complete, Maybe[str](str) highlight, Msg msg, REPLModel model) {
  Cmd cmd = none();
  
  switch (msg) {
    case xtermData(str s): {
      if (s != "\t") {
        model.cycle = -1;
      }
      if (s == "\r") {
        <evalMsg, result> = eval(model.currentLine);
        cmd = write(evalMsg, model.id, "\r\n<result>\r\n<model.prompt>");
        model.history += [model.currentLine];
        model.pointer = size(model.history);
        model.currentLine = "";
      }
      else if (s == "\a7f") { 
        if (model.currentLine != "" ) {
          model.currentLine = model.currentLine[0..-1];
          cmd = write(noOp(), model.id, "\b \b");
        }
      }
      else if (s == "\a1b[A") { // arrow up
        if (model.pointer > 0) {
          model.pointer -= 1;
          <model, cmd> = replaceLine(model, model.history[model.pointer], highlight); 
        }
      }
      else if (s == "\a1b[B") { // arrow down
        if (model.pointer < size(model.history) - 1) {
	        model.pointer += 1;
	        <model, cmd> = replaceLine(model, model.history[model.pointer], highlight);
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
        <model, cmd> = replaceLine(model, model.completions[model.cycle], highlight);
      }
      else {
        model.currentLine += s;
        if (just(str x) := highlight(model.currentLine)) {
          cmd = writeLine(model, x, highlight);
        }
        else {
          cmd = write(noOp(), model.id, s);
        }
      }
    }
  }
  
  return withCmd(model, cmd);
}  


void repl(Msg(Msg) f, REPLModel m, str id, value vals...) {
   mapView(f, m, repl(id, vals));
}

void(REPLModel) repl(str id, value vals...) {
  return void(REPLModel m) {
     xterm(id, [onData(xtermData)] + vals); 
  };
}

list[str] dummyCompleter(str prefix) {
  list[str] xs = ["aap", "nooit", "noot", "mies", "muis"];
  return [ x | x <- xs, startsWith(x, prefix) ] + [prefix];
}


Maybe[str] dummyHighlighter(str x) {
  try {
    bool terminated = false;
    if (!endsWith(x, ";")) {
      x += ";"; // try to terminate to get earlier highlighting...
      terminated = true;
    }
    Tree t = parseCommand(x, |file:///dummy|);
    str h = ansiHighlight(t);
    if (terminated) {
      h = h[0..-1]; 
    }
    return just(h);
  }
  catch value _: {
    return nothing();
  }
} 
 

WithCmd[REPLModel] init() = initRepl("x", "$ ", dummyCompleter, dummyHighlighter);

App[REPLModel] replApp()
  = app(init, sampleView, update, |http://localhost:5001|, |project://salix/src|
       parser = parseMsg);

Msg identity(Msg m) = m;

void sampleView(REPLModel m) {
  div(() {
    h4("Command line");
    repl(identity, m, "x", cursorBlink(true), cols(80), rows(10));
  });       
}

map[str, str] cat2ansi() = (
  "Type": "",
  "Identifier": "",
  "Variable": "",
  "Constant": "\u001B[0;36m", //cyan
  "Comment":  "\u001B[0;37m", // gray
  "Todo": "",
  "MetaAmbiguity": "\u001B[1;31m", // bold red
  "MetaVariable": "",
  "MetaKeyword": "\u001B[1;35m", // bold purple
  "StringLiteral": "\u001B[0;36m" // cyan
);


str ansiHighlight(Tree t, map[str,str] cats = cat2ansi(), int tabsize = 2) = highlightRec(t, cats, tabsize);

str highlightRec(Tree t,  map[str,str] cats, int tabsize) {

  str reset = "\u001B[0m";
  
  str highlightArgs(list[Tree] args) 
    = ("" | it + highlightRec(a, cats, tabsize) | Tree a <- args );
  
  switch (t) {
    
    case appl(prod(lit(/^<s:[a-zA-Z_0-9]+>$/), _, _), list[Tree] args): {
      return "<cats["MetaKeyword"]><s><reset>";
    }

    case appl(prod(Symbol d, list[Symbol] ss, set[Attr] as), list[Tree] args): {
      if (\tag("category"(str cat)) <- as) {
        // categories can't be nested, so just yield the tree.
        return "<cats[cat]><t><reset>";
      }
      return highlightArgs(args);
    }
    
    case appl(_, list[Tree] args):
      return highlightArgs(args);
    
    case char(int c): { 
      str s = stringChar(c);
      return  s == "\t" ? ("" | it + " " | _ <- [0..tabSize]) : s;
    }
    
    case amb(set[Tree] alts): {
      if (Tree a <- alts) {
        return highlightRec(a, cats);
      }
    }

  }
  
  return "";
    
} 
