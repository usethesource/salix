module salix::demo::graphs::DagreDemo

import salix::App;
import salix::HTML;
import salix::lib::Dagre;
import IO;

alias Model = tuple[int clicks, rel[str, str] graph];

App[Model] graphApp()
  = app(init, view, update, |http://localhost:7002|, |project://salix/src|);

Model init() = <0, {<"a", "b">, <"b", "c">, <"a", "c">}>;

data Msg
  = noOp()
  | click()
  ;


Model update(Msg msg, Model m)  = m[clicks = m.clicks + 1];

void view(Model m) {
  div(() {
    
    h2("Dagre graph demo with embedded HTML");
    
    h3("Clicks: <m.clicks>");
    
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