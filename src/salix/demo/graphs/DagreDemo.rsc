module salix::demo::graphs::DagreDemo

import salix::App;
import salix::HTML;
import salix::lib::Dagre;
import IO;
import util::Math;
import Set;
import List;

alias Model = tuple[int clicks, rel[str, str] graph, str line];

App[Model] graphApp()
  = app(init, view, update, |http://localhost:7002|, |project://salix/src|);

Model init() = <0, {<"a", "b">, <"b", "c">, <"a", "c">}, "cardinal">;

data Msg
  = addNode()
  | click()
  | changeEdgeLine(str x)
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
    
    case changeEdgeLine(str x):
      m.line = x;
    
  }
  return m;
}

void view(Model m) {
  div(() {
    
    h2("Dagre graph demo with embedded HTML");
    
    h3("Clicks: <m.clicks>");
    
    button(onClick(addNode()), "Add a node!");
    button(onClick(changeEdgeLine("cardinal")), "Cardinal");
    button(onClick(changeEdgeLine("linear")), "Linear");
    button(onClick(changeEdgeLine("step")), "Step");
    button(onClick(changeEdgeLine("monotone")), "Monotone");
    
    
    dagre("myGraph", rankdir("LR"), width(960), height(600), (N n, E e) {
      for (str x <- m.graph<0> + m.graph<1>) {
        n(x, shape("ellipse"), () { 
          div(() {
	          h3("Here\'s node <x>");
	          p("A paragraph");
	          button(onClick(click()), "Click <x>");
	        });
        });
      }
      for (<str x, str y> <- m.graph) {
        e(x, y, lineInterpolate(m.line));
      }
    });    
    
  });
}