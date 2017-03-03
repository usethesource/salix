module salix::demo::graphs::DagreDemo

import salix::App;
import salix::HTML;
import salix::lib::Dagre;

alias Model = rel[str, str];

App[Model] graphApp()
  = app(init, view, update, |http://localhost:7002|, |project://salix/src|);

Model init() = {<"a", "b">, <"b", "c">, <"a", "c">};

data Msg
  = noOp()
  ;


Model update(Msg msg, Model m)  = m;

void view(Model m) {
  div(() {
    
    h2("Dagre graph demo with embedded HTML");
    
    dagre("myGraph", (N n, E e) {
      for (str x <- m<0> + m<1>) {
        n(x, () { // todo: allow lists of things, not just a single elt
          div(() {
	          h3("Here\'s some HTML and a button");
	          p("A paragraph");
	          button("Click <x>");
	        });
        });
      }
      for (<str x, str y> <- m) {
        e(x, y);
      }
    });    
    
  });
}