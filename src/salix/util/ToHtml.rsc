module salix::util::ToHtml

import salix::Node;
import List;


Node bareHtml(Node n) {
  return visit(n) {
  	case element(str t, list[Node] kids, map[str,str] as, _, _) => element(t, kids, as, (), ())
  	case native(_, _, _, _, _, extra = _) => element("div", [], (), (), ()) 
  }
}

str toHtml(element(str n, list[Node] kids, map[str, str] attrs, _ , _)) 
  = "\<<n> <attrs2str(attrs)>\><kids2html(kids)>\</<n>\>";

str toHtml(txt(str s)) = s;
  
str kids2html(list[Node] kids)
  = ( "" | it + toHtml(k) | Node k <- kids );

str attrs2str(map[str, str] attrs)
  = intercalate(" ", [ "<a>=\"<attrs[a]>\"" | str a <- attrs ]);  
  
      


