module salix::demo::basic::All

import salix::HTML;
import salix::App;
import salix::Core; 
import salix::lib::Debug;
import IO;

import salix::demo::basic::Celsius;
import salix::demo::basic::Counter;
import salix::demo::basic::CodeMirror;
import salix::demo::basic::Clock;
import salix::demo::basic::Random;


alias AllModel = tuple[
  salix::demo::basic::Celsius::Model celsius, 
  salix::demo::basic::Counter::Model counter, 
  salix::demo::basic::Random::TwiceModel random,
  salix::demo::basic::CodeMirror::Model codeMirror,
  salix::demo::basic::Clock::Model clock
];

data Msg
  = celsius(Msg msg)
  | counter(Msg msg)
  | random(Msg msg)
  | codeMirror(Msg msg)
  | clock(Msg msg)
  ;

App[AllModel] allApp() 
  = app(initAll(), viewAll, editAll, |http://localhost:9213|, |project://salix/src|, subs = allSubs); 

App[AllModel] debugAllApp() 
  = debug(initAll(), myDebugView, editAll, |http://localhost:9213|, |project://salix/src|, subs = allSubs); 
  
WithCmd[AllModel] initAll() = noCmd(<
  salix::demo::basic::Celsius::init(), 
  salix::demo::basic::Counter::init(), 
  salix::demo::basic::Random::twiceInit().model,
  salix::demo::basic::CodeMirror::init(),
  salix::demo::basic::Clock::init() 
>);  
  
list[Sub] allSubs(AllModel m) 
  = mapSubs(Msg::clock, m.clock, salix::demo::basic::Clock::subs);

void myDebugView(DebugModel[AllModel] m) {
  debugView(m, viewAll);
}
  
void viewAll(AllModel m) {
  div(() {
     mapView(Msg::celsius, m.celsius, salix::demo::basic::Celsius::view);
     mapView(Msg::counter, m.counter, salix::demo::basic::Counter::view);
     mapView(Msg::random, m.random, salix::demo::basic::Random::twiceView);
     mapView(Msg::codeMirror, m.codeMirror, salix::demo::basic::CodeMirror::view);
     mapView(Msg::clock, m.clock, salix::demo::basic::Clock::view);
  });
}

WithCmd[AllModel] editAll(Msg msg, AllModel m) {
  Cmd cmd = none();
  switch (msg) {
    case celsius(Msg msg):
      m.celsius = salix::demo::basic::Celsius::update(msg, m.celsius);
      
    case counter(Msg msg):
      m.counter = salix::demo::basic::Counter::update(msg, m.counter);
    
    case random(Msg msg): 
      <m.random, cmd> = mapCmd(Msg::random, msg, m.random, twiceUpdate);
    
    case codeMirror(Msg msg):
      m.codeMirror = salix::demo::basic::CodeMirror::update(msg, m.codeMirror);
      
    case clock(Msg msg):
      m.clock = salix::demo::basic::Clock::update(msg, m.clock);
  }
  
  return withCmd(m, cmd);
}
