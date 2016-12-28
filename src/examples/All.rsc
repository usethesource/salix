module examples::All

import gui::HTML;
import gui::App;
import gui::Decode;
import lib::EditableList;
import lib::Debug;

import examples::Celsius;
import examples::Counter;
import examples::ListDemo;
import examples::Clock;

alias AllModel = tuple[
  real celsius, 
  examples::Counter::Model counter, 
  ListModel[str] listDemo,
  examples::Clock::Model clock
];

data Msg
  = celsius(Msg msg)
  | counter(Msg msg)
  | listDemo(Msg msg)
  | clock(Msg msg)
  ;

App[AllModel] allApp() 
  = app(initAll(), viewAll, editAll, 
        |http://localhost:9198|, |project://elmer/src/examples|,
        subs = examples::All::subs); 

App[DebugModel[AllModel]] debugAllApp() 
  = debug(initAll(), viewAll, editAll, 
        |http://localhost:9198|, |project://elmer/src/examples|); 
  
AllModel initAll() = <
  37.0, 
  examples::Counter::init(), 
  <["hello", "world!"], editStr, initStr>,
  examples::Clock::init() 
>;  
  
list[Sub] subs(AllModel m) 
  = mapping.subs(Msg::clock, m.clock, examples::Clock::subs);
  
void viewAll(AllModel m) {
  div(() {
     mapping.view(Msg::celsius, m.celsius, examples::Celsius::view);
     mapping.view(Msg::counter, m.counter, examples::Counter::view);
     mapping.view(Msg::listDemo, m.listDemo, examples::ListDemo::view);
     mapping.view(Msg::clock, m.clock, examples::Clock::view);
  });
}

AllModel editAll(celsius(Msg msg), AllModel m) = m[celsius=examples::Celsius::update(msg, m.celsius)];
AllModel editAll(counter(Msg msg), AllModel m) = m[counter=examples::Counter::update(msg, m.counter)];
AllModel editAll(listDemo(Msg msg), AllModel m) = m[listDemo=editList(msg, m.listDemo)];
AllModel editAll(clock(Msg msg), AllModel m) = m[clock=examples::Clock::update(msg, m.clock)];
