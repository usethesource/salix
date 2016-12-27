module examples::Counter

import gui::HTML;
import gui::App;
import lib::Debug;

import String;

alias Model = tuple[int count, int delta];

data Msg
  = inc()
  | dec()
  | delta(str input)
  ;


App[DebugModel[Model]] debugCounterApp(loc http, loc static)
  =  debug(init(), examples::Counter::view, examples::Counter::update, http, static);

App[DebugModel[Model]] debugCounterApp() 
  = debugCounterApp(|http://localhost:9197|, |project://elmer/src/examples|); 

App[Model] counterApp() 
  = app(init(), view, update, 
        |http://localhost:9197|, |project://elmer/src/examples|); 


Model init() = <0, 1>;

void view(Model m) {
  div(() {
    
    h2("My first counter app in Rascal");
    
    button(onClick(dec()), "-");
    
    div("<m.count>");
    
    button(onClick(inc()), "+");
    
    input(\value("<m.delta>"),\type("text"), onInput(delta));

  });
}

Model update(inc(), <int n, int m>) = <n + m, m>;
Model update(dec(), <int n, int m>) = <n - m, m>;
Model update(delta(str s), <int n, int m>) = <n, toInt(s)>;


