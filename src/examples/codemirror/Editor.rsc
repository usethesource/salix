module examples::codemirror::Editor

import gui::HTML;
import gui::App;
import lib::Highlight;

import ParseTree;
import IO;
import String;
import List;
import lang::javascript::saner::Syntax;



data Hnd
  = codeMirrorChange(Handle handle)
  ;

data Result
  = codeMirrorChange(Handle handle, int fromLine, int fromCol,
     int toLine, int toCol, str text, str removed);

Hnd codeMirrorChange(Msg(int, int, int, int, str, str) ch2msg) 
  = codeMirrorChange(encode(ch2msg));

Result toResult("codeMirrorChange", map[str, str] p)
  = codeMirrorChange(toHandle(p), toInt(p["fromLine"]), toInt(p["fromCol"]), 
           toInt(p["toLine"]), toInt(p["toCol"]),
           p["text"], p["removed"]);

Msg toMsg(codeMirrorChange(Handle h, int a, int b, int c, int d, str s1, str s1), &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int, int, int, int, str, str))(a, b, c, d, s1, s2);



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
    return appl(prod(sort("Source"), [], {}), [ char(c) | int c <- chars(x)]);
  }
}

Source update(doChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed), Source s) {
  str src = "<s>";
  list[str] lines = split("\n", src);
  int from = ( 0 | it + size(l) + 1 | str l <- lines[..fromLine] ) + fromCol;
  int to = from + size(removed);
  str newSrc = src[..from] + text + src[to..];
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
    codeMirror(\value("<t>"), onChange(doChange)/*, onCursorActivity(currentToken)*/);
    h2("Generic highlighting");
    highlight(t);
  });
}
