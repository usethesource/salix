module salix::util::ToHtml

import lang::html5::DOM;
import salix::Node;


Node bareHtml(Node n) {
  return visit(n) {
  	case element(str t, list[Node] kids, map[str,str] as, _, _) => element(t, kids, as, (), ())
  	case native(_, _, _, _, _, extra = _) => empty() 
  }
}

str toHtml(Node n) = toString(_toHtml(n));

value _toHtml(element(str n, list[Node] kids, map[str, str] attrs, _ , _)) 
  = html5node(n, [ _toHtml(k) | Node k <- kids, !(k is empty), !(k is native) ] 
      + [ html5attr(a, attrs[a]) | str a <- attrs ]);
      
value _toHtml(txt(str s)) = s;


