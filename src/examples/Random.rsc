module examples::Random

import gui::HTML;
import gui::Comms;
import gui::App;

import util::Math;

alias Model = tuple[int dieFace];

data Msg
  = roll()
  | newFace(int face)
  ;

App[Model] randomApp()
  = app(init(), view, update, 
    |http://localhost:9098|, |project://elmer/src/examples|); 

WithCmds[Model] init() = noCmds(<1>);
  
WithCmds[Model] update(roll(), Model m) = withCmds(m, [random(newFace, 1, 6)]);

WithCmds[Model] update(newFace(int n), Model m) = noCmds(m[dieFace=n]);

void view(Model m) {
  div(() {
     button(onClick(roll()), "Roll");
     text(m.dieFace);
  });
}

// Twice

data TwiceModel 
  = twice(Model model1, Model model2);


// Smart constructor to construct combined twice models, merging commands.
WithCmds[TwiceModel] twice(WithCmds[Model] m1, WithCmds[Model] m2)
  = withCmds(twice(m1.model, m2.model), m1.commands + m2.commands);

App[TwiceModel] twiceRandomApp()
  = app(twiceInit(), twiceView, twiceUpdate, 
    |http://localhost:9098|, |project://elmer/src/examples|); 

WithCmds[TwiceModel] twiceInit() = twice(init(), init());

data Msg = sub1(Msg msg) | sub2(Msg msg);

WithCmds[TwiceModel] twiceUpdate(sub1(Msg msg), TwiceModel m)
  = twice(mapping.cmds(sub1, msg, m.model1, update), noCmds(m.model2));

WithCmds[TwiceModel] twiceUpdate(sub2(Msg msg), TwiceModel m)
  = twice(noCmds(m.model1), mapping.cmds(sub2, msg, m.model2, update));   

void twiceView(TwiceModel m) {
  div(() {
    h2("Two times roll a die");
    mapping.view(sub1, m.model1, view);
    mapping.view(sub2, m.model2, view);
  });
}


