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
import examples::Clock;
import examples::Random;


alias AllModel = tuple[
  real celsius, 
  examples::Counter::Model counter, 
  ListModel[str] listDemo,
  examples::Random::TwiceModel random,
  examples::Clock::Model clock
];

data Msg
  = celsius(Msg msg)
  | counter(Msg msg)
  | listDemo(Msg msg)
  | random(Msg msg)
  | clock(Msg msg)
  ;

App[AllModel] allApp() 
  = app(initAll(), viewAll, editAll, 
        |http://localhost:9161|, |project://elmer/src/examples|,
        subs = examples::All::subs); 

App[DebugModel[AllModel]] debugAllApp() 
  = debug(initAll(), viewAll, editAll, 
        |http://localhost:9161|, |project://elmer/src/examples|); 
  
WithCmds[AllModel] initAll() = noCmds(<
  37.0, 
  examples::Counter::init(), 
  <["hello", "world!"], editStr, initStr>,
  examples::Random::twiceInit().model,
  examples::Clock::init() 
>);  
  
list[Sub] subs(AllModel m) 
  = mapping.subs(Msg::clock, m.clock, examples::Clock::subs);
  
void viewAll(AllModel m) {
  div(() {
     mapping.view(Msg::celsius, m.celsius, examples::Celsius::view);
     mapping.view(Msg::counter, m.counter, examples::Counter::view);
     mapping.view(Msg::listDemo, m.listDemo, examples::ListDemo::view);
     mapping.view(Msg::random, m.random, examples::Random::twiceView);
     mapping.view(Msg::clock, m.clock, examples::Clock::view);
  });
}

WithCmds[AllModel] editAll(celsius(Msg msg), AllModel m) 
  = noCmds(m[celsius=examples::Celsius::update(msg, m.celsius)]);

WithCmds[AllModel] editAll(counter(Msg msg), AllModel m) 
  = noCmds(m[counter=examples::Counter::update(msg, m.counter)]);
  
WithCmds[AllModel] editAll(listDemo(Msg msg), AllModel m)
  = noCmds(m[listDemo=editList(msg, m.listDemo)]);

//mapping.cmds(sub1, msg, m.model1, update)

WithCmds[AllModel] editAll(random(Msg msg), AllModel m)
  = withCmds(m[random=r], cmds) 
  when
    <examples::Random::TwiceModel r, list[Cmd] cmds> := 
      mapping.cmds(Msg::random, msg, m.random, examples::Random::twiceUpdate);

WithCmds[AllModel] editAll(clock(Msg msg), AllModel m) 
  = noCmds(m[clock=examples::Clock::update(msg, m.clock)]);
  
default WithCmds[AllModel] editAll(Msg msg, AllModel m) = noCmds(m)
  when bprintln("Uncatched: <msg>");
  

