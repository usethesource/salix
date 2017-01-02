module demo::basic::All

import salix::HTML;
import salix::App;
import salix::Core; 
import salix::lib::EditableList;
import salix::lib::Debug;
import IO;

import demo::basic::Celsius;
import demo::basic::Counter;
import demo::basic::ListDemo;
import demo::basic::CodeMirror;
import demo::basic::Clock;
import demo::basic::Random;


alias AllModel = tuple[
  real celsius, 
  demo::basic::Counter::Model counter, 
  ListModel[str] listDemo,
  demo::basic::Random::TwiceModel random,
  demo::basic::CodeMirror::Model codeMirror,
  demo::basic::Clock::Model clock
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
  = app(initAll(), viewAll, editAll, |http://localhost:9203|, |project://salix/src|, subs = allSubs); 

App[AllModel] debugAllApp() 
  = debug(initAll(), viewAll, editAll, |http://localhost:9204|, |project://salix/src|, subs = allSubs); 
  
WithCmds[AllModel] initAll() = noCmds(<
  37.0, 
  demo::basic::Counter::init(), 
  <["hello", "world!"], editStr, initStr>,
  demo::basic::Random::twiceInit().model,
  demo::basic::CodeMirror::init(),
  demo::basic::Clock::init() 
>);  
  
list[Sub] allSubs(AllModel m) 
  = mapping.subs(Msg::clock, m.clock, demo::basic::Clock::subs);
  
void viewAll(AllModel m) {
  div(() {
     mapping.view(Msg::celsius, m.celsius, demo::basic::Celsius::view);
     mapping.view(Msg::counter, m.counter, demo::basic::Counter::view);
     mapping.view(Msg::listDemo, m.listDemo, demo::basic::ListDemo::view);
     mapping.view(Msg::random, m.random, demo::basic::Random::twiceView);
     mapping.view(Msg::codeMirror, m.codeMirror, demo::basic::CodeMirror::view);
     mapping.view(Msg::clock, m.clock, demo::basic::Clock::view);
  });
}

WithCmds[AllModel] editAll(Msg msg, AllModel m) {
  list[Cmd] cmds = [];
  switch (msg) {
    case celsius(Msg msg):
      m.celsius = demo::basic::Celsius::update(msg, m.celsius);
      
    case counter(Msg msg):
      m.counter = demo::basic::Counter::update(msg, m.counter);
    
    case listDemo(Msg msg):
      m.listDemo = editList(msg, m.listDemo);
      
    case random(Msg msg): 
      <m.random, cmds> = mapping.cmds(Msg::random, msg, m.random, twiceUpdate);
    
    case codeMirror(Msg msg):
      m.codeMirror = demo::basic::CodeMirror::update(msg, m.codeMirror);
      
    case clock(Msg msg):
      m.clock = demo::basic::Clock::update(msg, m.clock);
  }
  
  return withCmds(m, cmds);
}
