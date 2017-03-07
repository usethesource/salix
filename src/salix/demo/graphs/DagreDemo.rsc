module salix::demo::graphs::DagreDemo

import salix::App;
import salix::HTML;
import salix::lib::Dagre;
import IO;
import util::Math;
import Set;
import List;

alias Model = tuple[int clicks, rel[str, str] graph];

App[Model] graphApp()
  = app(init, view, update, |http://localhost:7002|, |project://salix/src|);

Model init() = <0, {<"a", "b">, <"b", "c">, <"a", "c">}>;

data Msg
  = addNode()
  | click()
  ;


Model update(Msg msg, Model m) {
  switch (msg) {
    case click():
      m.clicks += 1;
  
    case addNode(): {
      str n1 = "abcdefghijklmnopqrstuvwxyz"[arbInt(26)];
      list[str] nodes = toList(m.graph<0> + m.graph<1>);
      str n2 = nodes[arbInt(size(nodes))];
      m.graph += {<n1, n2>}; 
    }
  }
  return m;
}

void view(Model m) {
  div(() {
    
    h2("Dagre graph demo with embedded HTML");
    
    h3("Clicks: <m.clicks>");
    
    button(onClick(addNode()), "Add a node!");
    
    dagre("myGraph", (N n, E e) {
      for (str x <- m.graph<0> + m.graph<1>) {
        println("x = <x>");
        n(x, fill("#fff"), shape("ellipse"), () { // todo: allow lists of things, not just a single elt
          div(() {
            println("XXX = <x>");
	          h3("Here\'s node <x>");
	          p("A paragraph");
	          button(onClick(click()), "Click <x>");
	        });
        });
      }
      for (<str x, str y> <- m.graph) {
        e(x, y, lineInterpolate("cardinal"));
      }
    });    
    
  });
}