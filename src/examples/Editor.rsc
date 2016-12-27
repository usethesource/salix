module examples::Editor

import gui::HTML;
import gui::App;
import ParseTree;
import IO;
import String;
import List;
import gui::Highlight;
import lang::javascript::saner::Syntax;

//
App[Source] editorApp()
  = app(exampleTerm(), editor, update, |http://localhost:9181|, |project://elmer/src/examples|);

Source exampleTerm() = parse(#Source, 
  "function helloWorld() {
  '  console.log(\'Hello world!\');
  '}");

data Msg
  = changeText(str txt)
  | currentToken(int line, int \start, int end, str string, str tokenType)
  | doChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed)
  ;

Source update(currentToken(int line, int \start, int end, str string, str tokenType), Source s) = s;

Source update(changeText(str x), Source s) {
  try {
    return parse(#Source, x);
  }
  catch ParseError(loc l): {
    // compute string diff, futz the insert elements into e
    // to be able to highlight.
    return s;
  }
}

Source update(doChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed),
   Source s) {
  str src = "<s>";
  list[str] lines = src == "\n" ? ["", ""] : split("\n", src);
  list[str] inserted = text == "\n" ? ["", ""] : split("\n", text);
  
  println("INSERTED: <inserted>");
  
  list[str] newLines = [];
   
  newLines += lines[0..fromLine];
  
  if (size(inserted) == 1) {
    newLines += [lines[fromLine][..fromCol] + inserted[0] + lines[toLine][toCol..]];
  }
  else {
    newLines += [lines[fromLine][..fromCol] + inserted[0]]
              + inserted[1..-1]
              + [inserted[-1] + lines[toLine][toCol..]];
  }
  
  newLines += lines[toLine+1..];
    
    
  
  //list[str] pre = lines[0..fromLine];
  //list[str] post = lines[toLine+1..];
  //str preOld = lines[fromLine][0..fromCol];
  //str postOld = lines[toLine][toCol..];
  //str preNew = inserted[0];
  //str postNew = size(inserted) > 1 ? inserted[-1] : "";
  //list[str] newLines = inserted[1..-1];
  //str newSrc = size(newLines) > 0 
  //  ? intercalate("\n", pre + [preOld + preNew] + newLines + [postNew + postOld] + post)
  //  : intercalate("\n", pre + [preOld + preNew + postNew + postOld] + post);
  
  newSrc = intercalate("\n", newLines);
  println("NEW: <newSrc>"); 
  return update(changeText(newSrc), s);  
}


void codeMirror(value vals...) = build(vals, _codeMirror);
Html _codeMirror(list[Html] _, list[Attr] attrs)
  = native("codeMirror", "\<codeMirror\>", 
      attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

/*
TODO:

void codeMirror(CodeMirrorConfig config) = build([], 
   Html(list[Html] hs, list[Attr] as) {
      return native("codeMirror", "\<codeMirror\>", 
         attrsOf(attrs), propsOf(attrs), eventsOf(attrs), config);
   });

*/

void editor(Source t) {
  div(() {
    h2("Editor example");
    codeMirror(\value("<t>"), onChange(doChange), onCursorActivity(currentToken));
    div(() {
      textarea(onInput(changeText), "<t>");
    });
    highlight(t);
  });
}
