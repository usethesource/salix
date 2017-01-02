module examples::Random

import gui::HTML;
import gui::Core;
import gui::App;

import util::Math;

alias Model = tuple[int dieFace];

data Msg
  = roll()
  | newFace(int face)
  ;

// Idea: do commands/subs similar to nodes: collect them via void functions.
// this would avoid all the hassle with lifting/models into WithCmds[...]
// and make the types much less verbose everywhere. 
// so similar to render, we have functions to collect subs and cmds
// subscribe(Sub);
// do(Cmd); 
// WithCmds[&T] doing(&T(Msg, &T) upd) --> collects them.
// toplevel we get
// v' = render(view)
// <m', cmds> = commands(model, update)
// subs can be just a function it doesn't require the flattening etc.
// our statements already do the "monad" thing of flattening.
// this is better, the repetition of the types in case-based defs is annoyning
// also: we don't want open extensibility here (hardly possible: views aren't open)
// , so it's fine to use switch.

App[Model] randomApp()
  = app(init(), view, update, |http://localhost:9098|, |project://elmer/src/examples|); 

WithCmds[Model] init() = noCmds(<1>);

WithCmds[Model] update(Msg msg, Model m) {
  list[Cmd] cmds = [];
  switch (msg) {
    
    case roll(): 
      cmds = [random(newFace, 1, 6)];
    
    case newFace(int n): 
      m.dieFace = n; 
  
  }
  return withCmds(m, cmds);
}


void view(Model m) {
  div(() {
     button(onClick(roll()), "Roll");
     text(m.dieFace);
  });
}

// Twice

App[TwiceModel] twiceRandomApp()
  = app(twiceInit(), twiceView, twiceUpdate, |http://localhost:9098|, |project://elmer/src/examples|); 

data TwiceModel 
  = twice(Model model1, Model model2);

WithCmds[TwiceModel] twiceInit() {
  <m1, _> = init(); // todo: need mapping of cmds, outside of update
  <m2, _> = init();
 return noCmds(twice(m1, m2));
}

data Msg = sub1(Msg msg) | sub2(Msg msg);

WithCmds[TwiceModel] twiceUpdate(Msg msg, TwiceModel m) {
  list[Cmd] cmds = [];
  
  switch (msg) {
    case sub1(Msg s):
      <m.model1, cmds> = mapping.cmds(sub1, s, m.model1, update);
      
    case sub2(Msg s):
      <m.model2, cmds> = mapping.cmds(sub2, s, m.model2, update);
  }
  
  return withCmds(m, cmds);
}

void twiceView(TwiceModel m) {
  div(() {
    h2("Two times roll a die");
    mapping.view(sub1, m.model1, view);
    mapping.view(sub2, m.model2, view);
  });
}


