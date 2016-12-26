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
  ;
  
lexical Var
  = [a-z]+
  ;


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

void highlight(Tree t, Cat2Css cats = _category2styles) {
  span(id("<t@\loc>"), () {
    highlightRec(t, "", cats);
  });
}


str highlightRec(Tree t, str current, Cat2Css cats) {
  //prod(Symbol def, list[Symbol] symbols, set[Attr] attributes
  
  
  void highlightArgs(list[Tree] args) {
    for (Tree a <- args) {
      current = highlightRec(a, current, cats);
    }
  }
  
  
  void doText() {
    println("CURRENT: `<current>`");
    if (current != "") {
      text(current);
    }
    current = "";
  }
  
  println("highlighting: `<t>`");
  
  switch (t) {
    case appl(prod(lit(/^<s:[a-zA-Z_0-9]+>$/), _, _), list[Tree] args): {
      println("Lit: <s>");
      println("Current at lit: `<current>`");
      doText();
      span(class("MetaKeyword"), style(cats["MetaKeyword"]), s);
    }

    //case appl(prod(layouts(_), _, _), list[Tree] args): {
    //  println("Layout: `<t>`");
    //  current += "<t>";
    //}
    
  
    case appl(prod(Symbol d, list[Symbol] ss, set[Attr] as), list[Tree] args): {
      if (\tag("category"(str cat)) <- as) {
        println("  Cat: <cat>");
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
      println("CURRENT at char: `<current>`");
    }
  
    default: {
      println("MISSED: ");
      rprintln(t); 
    }
      
  }
  
  return current;
    
} 


