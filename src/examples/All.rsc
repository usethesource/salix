module examples::All

import gui::HTML;
import gui::App;
import lib::List;
import lib::Debug;
import examples::Celsius;
import examples::Counter;
import examples::ListDemo;

alias AllModel = tuple[real celsius, Model counter, ListModel[str] listDemo];

data Msg
  = celsius(Msg msg)
  | counter(Msg msg)
  | listDemo(Msg msg)
  ;

App[AllModel] allApp() 
  = app(initAll(), viewAll, editAll, 
        |http://localhost:9199|, |project://elmer/src/examples|); 

App[DebugModel[AllModel]] debugAllApp() 
  = debug(initAll(), viewAll, editAll, 
        |http://localhost:9199|, |project://elmer/src/examples|); 
  
AllModel initAll()
  = <37.0, examples::Counter::init(), <["hello", "world!"], editStr, initStr>>;  
  
void viewAll(AllModel m) {
  div(() {
     mapped(Msg::celsius, m.celsius, examples::Celsius::view);
     mapped(Msg::counter, m.counter, examples::Counter::view);
     mapped(Msg::listDemo, m.listDemo, examples::ListDemo::view);
  });
}

AllModel editAll(celsius(Msg msg), AllModel m) = m[celsius=examples::Celsius::update(msg, m.celsius)];
AllModel editAll(counter(Msg msg), AllModel m) = m[counter=examples::Counter::update(msg, m.counter)];
AllModel editAll(listDemo(Msg msg), AllModel m) = m[listDemo=editList(msg, m.listDemo)];
