module salix::demo::basic::Random

import salix::HTML;
import salix::Core;
import salix::App;

import util::Math;

alias Model = tuple[int dieFace];

data Msg
  = roll()
  | newFace(int face)
  ;

App[Model] randomApp()
  = app(init(), view, update, |http://localhost:9098|, |project://salix/src|); 

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
  = app(twiceInit(), twiceView, twiceUpdate, |http://localhost:9098|, |project://salix/src|); 

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
      <m.model1, cmds> = mapCmds(sub1, s, m.model1, update);
      
    case sub2(Msg s):
      <m.model2, cmds> = mapCmds(sub2, s, m.model2, update);
  }
  
  return withCmds(m, cmds);
}

void twiceView(TwiceModel m) {
  div(() {
    h2("Two times roll a die");
    mapView(sub1, m.model1, view);
    mapView(sub2, m.model2, view);
  });
}


