module examples::All

import gui::HTML;
import gui::App;
import gui::Comms; // for Sub type
import lib::EditableList;
import lib::Debug;
import IO;

import examples::Celsius;
import examples::Counter;
import examples::ListDemo;
import examples::CodeMirror;
import examples::Clock;
import examples::Random;


alias AllModel = tuple[
  real celsius, 
  examples::Counter::Model counter, 
  ListModel[str] listDemo,
  examples::Random::TwiceModel random,
  examples::CodeMirror::Model codeMirror,
  examples::Clock::Model clock
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
  = app(initAll(), viewAll, editAll, 
        |http://localhost:9203|, |project://elmer/src|,
        subs = allSubs); 

App[DebugModel[AllModel]] debugAllApp() 
  = debug(initAll(), viewAll, editAll, 
        |http://localhost:9203|, |project://elmer/src|,
        subs = allSubs); 
  
WithCmds[AllModel] initAll() = noCmds(<
  37.0, 
  examples::Counter::init(), 
  <["hello", "world!"], editStr, initStr>,
  examples::Random::twiceInit().model,
  examples::CodeMirror::init(),
  examples::Clock::init() 
>);  
  
list[Sub] allSubs(AllModel m) 
  = mapping.subs(Msg::clock, m.clock, examples::Clock::subs);
  
void viewAll(AllModel m) {
  div(() {
     mapping.view(Msg::celsius, m.celsius, examples::Celsius::view);
     mapping.view(Msg::counter, m.counter, examples::Counter::view);
     mapping.view(Msg::listDemo, m.listDemo, examples::ListDemo::view);
     mapping.view(Msg::random, m.random, examples::Random::twiceView);
     mapping.view(Msg::codeMirror, m.codeMirror, examples::CodeMirror::view);
     mapping.view(Msg::clock, m.clock, examples::Clock::view);
  });
}

WithCmds[AllModel] editAll(Msg msg, AllModel m) {
  list[Cmd] cmds = [];
  switch (msg) {
    case celsius(Msg msg):
      m.celsius = examples::Celsius::update(msg, m.celsius);
      
    case counter(Msg msg):
      m.counter = examples::Counter::update(msg, m.counter);
    
    case listDemo(Msg msg):
      m.listDemo = editList(msg, m.listDemo);
      
    case random(Msg msg): 
      <m.random, cmds> = mapping.cmds(Msg::random, msg, m.random, twiceUpdate);
    
    case codeMirror(Msg msg):
      m.codeMirror = examples::CodeMirror::update(msg, m.codeMirror);
      
    case clock(Msg msg):
      m.clock = examples::Clock::update(msg, m.clock);
  }
  
  return withCmds(m, cmds);
}
