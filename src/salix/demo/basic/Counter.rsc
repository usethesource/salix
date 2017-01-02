module salix::demo::basic::Counter

import salix::HTML;
import salix::App;
import salix::lib::Debug;

import String;
import IO;

alias Model = tuple[int count];

Model init() = <0>;

data Msg
  = inc()
  | dec()
  ;


Model update(Msg msg, Model m) {
  switch (msg) {
    case inc(): m.count += 1;
    case dec(): m.count -= 1;
  }
  return m;
}

void view(Model m) {
  div(() {
    
    h2("My first counter app in Rascal");
    
    button(onClick(inc()), "▲");
    
    div("<m.count>");
    
    button(onClick(dec()), "▼");

  });
}

