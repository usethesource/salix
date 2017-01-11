@license{
  Copyright (c) 2016-2017 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

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

import salix::lib::CodeMirror;

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
  = app(initAll, viewAll, editAll, |http://localhost:9213|, |project://salix/src|
       , subs = allSubs, parser = parseMsg); 

App[AllModel] debugAllApp() 
  = debug(initAll, myDebugView, editAll, |http://localhost:9213|, |project://salix/src|, subs = allSubs); 
  
AllModel initAll() = <
  mapCmds(Msg::celsius, salix::demo::basic::Celsius::init), 
  mapCmds(Msg::counter, salix::demo::basic::Counter::init), 
  mapCmds(Msg::random, salix::demo::basic::Random::twiceInit),
  mapCmds(Msg::codeMirror, salix::demo::basic::CodeMirror::init),
  mapCmds(Msg::clock, salix::demo::basic::Clock::init) 
>;  
  
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

AllModel editAll(Msg msg, AllModel m) {
  switch (msg) {
    case celsius(Msg msg):
      m.celsius = mapCmds(Msg::celsius, msg, m.celsius, salix::demo::basic::Celsius::update);
      
    case counter(Msg msg):
      m.counter = mapCmds(Msg::counter, msg, m.counter, salix::demo::basic::Counter::update);
    
    case random(Msg msg): 
      m.random = mapCmds(Msg::random, msg, m.random, twiceUpdate);
    
    case codeMirror(Msg msg):
      m.codeMirror = mapCmds(Msg::codeMirror, msg, m.codeMirror, salix::demo::basic::CodeMirror::update);
      
    case clock(Msg msg):
      m.clock = mapCmds(Msg::clock, msg, m.clock, salix::demo::basic::Clock::update);
  }
  
  return withCmd(m, cmd);
}
