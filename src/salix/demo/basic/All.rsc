module salix::demo::basic::All

import salix::HTML;
import salix::App;
import salix::Core; 
import salix::lib::EditableList;
import salix::lib::Debug;
import IO;

import salix::demo::basic::Celsius;
import salix::demo::basic::Counter;
import salix::demo::basic::ListDemo;
import salix::demo::basic::CodeMirror;
import salix::demo::basic::Clock;
import salix::demo::basic::Random;


alias AllModel = tuple[
  real celsius, 
  salix::demo::basic::Counter::Model counter, 
  ListModel[str] listDemo,
  salix::demo::basic::Random::TwiceModel random,
  salix::demo::basic::CodeMirror::Model codeMirror,
  salix::demo::basic::Clock::Model clock
];

data Msg
  = celsius(Msg msg)
  | counter(Msg msg)
  | listDemo(Msg msg)
  | random(Msg msg)
  | codeMirror(Msg msg)
  | clock(Msg msg)
  ;

App[AllModel] allApp() 
  = app(initAll(), viewAll, editAll, |http://localhost:9213|, |project://salix/src|, subs = allSubs); 

App[AllModel] debugAllApp() 
  = debug(initAll(), myDebugView, editAll, |http://localhost:9213|, |project://salix/src|, subs = allSubs); 
  
WithCmds[AllModel] initAll() = noCmds(<
  37.0, 
  salix::demo::basic::Counter::init(), 
  <["hello", "world!"], editStr, initStr>,
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
     //mapView(Msg::listDemo, m.listDemo, salix::demo::basic::ListDemo::view);
     mapView(Msg::random, m.random, salix::demo::basic::Random::twiceView);
     //mapView(Msg::codeMirror, m.codeMirror, salix::demo::basic::CodeMirror::view);
     mapView(Msg::clock, m.clock, salix::demo::basic::Clock::view);
  });
}

WithCmds[AllModel] editAll(Msg msg, AllModel m) {
  list[Cmd] cmds = [];
  switch (msg) {
    case celsius(Msg msg):
      m.celsius = salix::demo::basic::Celsius::update(msg, m.celsius);
      
    case counter(Msg msg):
      m.counter = salix::demo::basic::Counter::update(msg, m.counter);
    
    case listDemo(Msg msg):
      m.listDemo = editList(msg, m.listDemo);
      
    case random(Msg msg): 
      <m.random, cmds> = mapCmds(Msg::random, msg, m.random, twiceUpdate);
    
    case codeMirror(Msg msg):
      m.codeMirror = salix::demo::basic::CodeMirror::update(msg, m.codeMirror);
      
    case clock(Msg msg):
      m.clock = salix::demo::basic::Clock::update(msg, m.clock);
  }
  
  return withCmds(m, cmds);
}
