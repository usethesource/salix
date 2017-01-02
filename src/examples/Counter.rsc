module examples::Counter

import gui::HTML;
import gui::App;
import lib::Debug;

import String;
import IO;

alias Model = tuple[int count, int delta];

Model init() = <0, 1>;

data Msg
  = inc()
  | dec()
  | delta(str input)
  ;


Model update(Msg msg, Model m) {
  switch (msg) {
    case inc(): m.count = m.count + m.delta;
    case dec(): m.count = m.count - m.delta;
    case delta(str s): m.delta = toInt(s);
  }
  return m;
}

void view(Model m) {
  div(() {
    
    h2("My first counter app in Rascal");
    
    button(onClick(inc()), "▲");
    
    div("<m.count>");
    
    button(onClick(dec()), "▼");
    
    input(\value("<m.delta>"),\type("text"), onInput(delta));

  });
}

