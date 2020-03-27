module salix::demo::ide::Richtext

import salix::Core;
import salix::Node;
import salix::HTML;
import salix::App;

import salix::demo::ide::StateMachine;

import ParseTree;
import String;

alias Model
  = tuple[
     str src,
     int line,
     int col,
     list[str] events
   ];

SalixApp[Model] richTextApp(str id = "rtf") = makeApp(id, init, view, update);

App[Model] richTextWebApp() 
  = webApp(
      richTextApp(),
      |project://salix/src/salix/demo/ide/richtext.html|, 
      |project://salix/src|
    ); 

   
Model init()
  = <doors(), 0, 1, []>;   
   
data Msg
 = keyPress(int code)
 | triggerEvent(str event)
 ;

Model update(Msg msg, Model m) {
  switch (msg) {

    case triggerEvent(str e): 
      m.events += [e];

    case keyPress(int k): {
      switch (k) {
        case 38: // up
          if (m.line > 0) {
            m.line -= 1;
          }
        
        case 40: // down
          m.line += 1; // todo check on length
        
        case 39: // left
          m.col += 1;
          
        case 37: // right
          if (m.col > 1) {
            m.col -= 1;
          }
      }
      
      //if (96 <= k, key <= 105) {
      //  ? key-48 : key
      //}
    }
  }
  return m;
}
 
void view(Model m) {
  div(() {
    h3("Rich text");
    div(class("col-md-6"), () {
      richText(parse(#start[Controller], m.src), m.line, m.col);
    });
    div(class("col-md-6"), () {
      ul(() {
        for (str e <- m.events) {
          li(() {
            text(e);
          });
        }
      });
    });    
  });
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

void richText(Tree t, int l, int c, void(list[value]) container = pre, map[str,lrel[str,str]] cats = cat2styles, int tabSize = 2) {
  line = 0;
  col = 1;
  div(tabindex(1), onKeyDown(keyPress), () {
    str pending = richTextRec(t, l, c, "", cats, tabSize);
    if (pending != "") {
      text(pending);
    }
  });
}

// TODO: make not global
  int line = 0;
  int col = 1;

private str richTextRec(Tree t, int cl, int cc, str current, map[str, lrel[str, str]] cats, int tabSize) {
  
  void richtTextArgs(list[Tree] args) {
    for (Tree a <- args) {
      current = richTextRec(a, cl, cc, current, cats, tabSize);
    }
  }
  
  void commitPending() {
    if (current != "") {
      text(current);
    }
    current = "";
  }
  
  if (t is transition) {
    button(onClick(triggerEvent("<t.event>")), "<t>");
    //int lines = ( 0 | it + 1 | /\n/ := "<t>" );
    // TODO: may contain newlines (we now assume it's on one line)
    col += size("<t>");
  }
  else {
    switch (t) {
      case appl(prod(lit(/^<s:[a-zA-Z_0-9]+>$/), _, _), list[Tree] args): {
        commitPending();
        if (line == cl, cc < col + size(s)) {
          int pos = cc - col;
          str before = s[0..pos];
          str after = s[pos..];
          span(class("MetaKeyword"), style(cats["MetaKeyword"]), before);
          div(class("cursor"), "|");
          span(class("MetaKeyword"), style(cats["MetaKeyword"]), after);
        }
        else {
          span(class("MetaKeyword"), style(cats["MetaKeyword"]), s);
        }
        col += size(s);
      }
  
      case appl(prod(Symbol d, list[Symbol] ss, set[Attr] as), list[Tree] args): {
        if (\tag("category"(str cat)) <- as) {
          commitPending();
          span(class(cat), style(cats[cat]), () {
            richtTextArgs(args);
            commitPending();
          });  
        }
        else {
          richtTextArgs(args);
        }
      }
      
      case appl(_, list[Tree] args):
        richtTextArgs(args);
      
      case char(int c): {
        if (line == cl, col == cc) {
          commitPending();
          div(class("cursor"), "|");
        }
        str s = stringChar(c);
        if (c == 10) {
          commitPending();
          br();
          line += 1;
          col = 1;
        }
        else if (c == 32) {
          commitPending();
          span(style(("width": "10px", "display": "inline-block")));
          col += 1;
        }
        else {
          current += s;
          col += 1;
        }
      }
      
      case amb(set[Tree] alts): {
        if (Tree a <- alts) {
          current = richTextRec(a, cl, cc, current, cats);
        }
      }
    }
  
  }
  
  return current;
    
} 
 
public map[str, lrel[str, str]] cat2styles = (
  "Type": [<"color", "#748B00">],
  "Identifier": [<"color", "#485A62">],
  "Variable": [<"color", "#268BD2">],
  "Constant": [<"color", "#CB4B16">],
  "Comment": [<"font-style", "italic">, <"color", "#8a8a8a">],
  "Todo": [<"font-weight", "bold">, <"color", "#af0000">],
  "MetaAmbiguity": [<"color", "#af0000">, <"font-weight", "bold">, <"font-style", "italic">],
  "MetaVariable": [<"color", "#0087ff">],
  "MetaKeyword": [<"color", "#859900">],
  "StringLiteral": [<"color", "#2AA198">]
);
   
   
