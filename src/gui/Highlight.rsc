module gui::Highlight

import gui::HTML;
import gui::App;
import ParseTree;
import IO;
import String;
extend lang::std::Layout;


syntax Expr
  = ifThen: "if" Expr "then" Expr "fi"
  | @category="Variable" var: Var
  | @category="StringLiteral" Str 
  ;
  
lexical Str = [\"]![\"]*[\"];
lexical Var = [a-z]+;

alias Cat2Css = map[str, lrel[str, str]]; 

Cat2Css _category2styles = (
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


App highlightApp()
  = app(exampleTerm(), editor, update, |http://localhost:9181|, |project://elmer/src/examples|);

Expr exampleTerm() = parse(#Expr, "if \"x\" // bla \n then \t\t if y then z fi fi");

data Msg
  = changeText(str txt)
  | currentToken(int line, int \start, int end, str string, str tokenType)
  ;

Expr update(currentToken(int line, int \start, int end, str string, str tokenType), Expr e) = e;

Expr update(changeText(str x), Expr e) {
  try {
    return parse(#Expr, x);
  }
  catch ParseError(loc l): {
    // compute string diff, futs the insert elements into e
    // to be able to highlight.
    return e;
  }
}


void codeMirror(value vals...) = build(vals, _codeMirror);
Html _codeMirror(list[Html] _, list[Attr] attrs)
  = native("codeMirror", "\<codeMirror\>", 
      attrsOf(attrs), propsOf(attrs), eventsOf(attrs));



void editor(Tree t) {
  // style(<"overflow", "hidden">, <"height", "0">)
  div(() {
    h2("Editor example");
    codeMirror(onCursorActivity(currentToken));
    div(() {
      textarea(onInput(changeText), "<t>");
    });
    highlight(t);
  });
}


void highlight(Tree t, void(list[value]) container = pre, Cat2Css cats = _category2styles) {
  container([() {
    highlightRec(t, "", cats);
  }]);
}


str highlightRec(Tree t, str current, Cat2Css cats) {
  
  void highlightArgs(list[Tree] args) {
    for (Tree a <- args) {
      current = highlightRec(a, current, cats);
    }
  }
  
  void doText() {
    if (current != "") {
      text(current);
    }
    current = "";
  }
  
  switch (t) {
    case appl(prod(lit(/^<s:[a-zA-Z_0-9]+>$/), _, _), list[Tree] args): {
      doText();
      span(class("MetaKeyword"), style(cats["MetaKeyword"]), s);
    }

    case appl(prod(Symbol d, list[Symbol] ss, set[Attr] as), list[Tree] args): {
      if (\tag("category"(str cat)) <- as) {
        doText();
        span(class(cat), style(cats[cat]), () {
          highlightArgs(args);
          doText();
        });  
      }
      else {
        highlightArgs(args);
      }
    }
    
    case appl(_, list[Tree] args):
      highlightArgs(args);
    
    case char(int c): {
      current += stringChar(c);
    }
    
    case amb(set[Tree] alts): {
      if (Tree a <- alts) {
        current = highlightRec(a, current, cats);
      }
    }
  
  }
  
  return current;
    
} 


