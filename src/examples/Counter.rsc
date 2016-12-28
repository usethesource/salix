module examples::Counter

import gui::HTML;
import gui::App;
import gui::Decode;
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

Model update(inc(), Model m) = m[count = m.count + m.delta];
Model update(dec(), Model m) = m[count = m.count - m.delta];
Model update(delta(str s), Model m) = m[delta = toInt(s)];


// changing Model to value here and at debug gives:
//  Expected App[DebugModel[value]], but got App[DebugModel[value]]
App[DebugModel[Model]] debugCounterApp(loc http, loc static)
  =  debug(init(), view, update, http, static);

App[DebugModel[Model]] debugCounterApp() 
  = debugCounterApp(|http://localhost:9197|, |project://elmer/src/examples|); 

App[Model] counterApp() 
  = app(init(), view, update, 
        |http://localhost:9197|, |project://elmer/src/examples|); 

void view(Model m) {
  div(() {
    
    h2("My first counter app in Rascal");
    
    button(onClick(dec()), "-");
    
    div("<m.count>");
    
    button(onClick(inc()), "+");
    
    input(\value("<m.delta>"),\type("text"), onInput(delta));

  });
}

