module salix::lib::Highlight

import salix::HTML;
import ParseTree;
import IO;
import String;

private map[str, lrel[str, str]] cat2styles = (
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




void highlightToHtml(Tree t, void(list[value]) container = pre, map[str,lrel[str,str]] cats = cat2styles, int tabSize = 2) {
  container([() {
    str pending = highlightRec(t, "", cats, tabSize);
    if (pending != "") {
      text(pending);
    }
  }]);
}

private str highlightRec(Tree t, str current, Cat2Css cats, int tabSize) {
  
  void highlightArgs(list[Tree] args) {
    for (Tree a <- args) {
      current = highlightRec(a, current, cats, tabSize);
    }
  }
  
  void commitPending() {
    if (current != "") {
      text(current);
    }
    current = "";
  }
  
  switch (t) {
    case appl(prod(lit(/^<s:[a-zA-Z_0-9]+>$/), _, _), list[Tree] args): {
      commitPending();
      span(class("MetaKeyword"), style(cats["MetaKeyword"]), s);
    }

    case appl(prod(Symbol d, list[Symbol] ss, set[Attr] as), list[Tree] args): {
      if (\tag("category"(str cat)) <- as) {
        commitPending();
        span(class(cat), style(cats[cat]), () {
          highlightArgs(args);
          commitPending();
        });  
      }
      else {
        highlightArgs(args);
      }
    }
    
    case appl(_, list[Tree] args):
      highlightArgs(args);
    
    case char(int c): {
      str s = stringChar(c);
      current += s == "\t" ? ("" | it + " " | _ <- [0..tabSize]) : s;
    }
    
    case amb(set[Tree] alts): {
      if (Tree a <- alts) {
        current = highlightRec(a, current, cats);
      }
    }
  
  }
  
  return current;
    
} 

private map[str, str] cat2ansi = (
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


str highlightToAnsi(Tree t, map[str,str] cats = cat2ansi, int tabsize = 2) { 

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



