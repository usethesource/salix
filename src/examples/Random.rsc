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



WithCmds[Model] init() = <<1>, []>;
  
WithCmds[Model] update(roll(), Model m) = <m, [random(newFace, 1, 6)]>;

WithCmds[Model] update(newFace(int n), Model m) = <m[dieFace=n], []>;

void view(Model m) {
  div(() {
     h1(m.dieFace);
     button(onClick(roll()), "Roll");
  });
}

// Twice

alias TwiceModel = tuple[Model model1, Model model2];

data Msg = sub1(Msg msg) | sub2(Msg msg);

App[TwiceModel] twiceRandomApp()
  = app(twiceInit(), twiceView, twiceUpdate, 
    |http://localhost:9098|, |project://elmer/src/examples|); 

WithCmds[TwiceModel] twiceInit() = <<m1, m2>, []>
  when 
    <Model m1, list[Cmd] cmds1> := init(),
    <Model m2, list[Cmd] cmds2> := init();
  

WithCmds[TwiceModel] twiceUpdate(Msg::sub1(Msg msg), TwiceModel m)
  = <<m1, m.model2>, cmds1>
  when 
    <Model m1, list[Cmd] cmds1> := mapping.cmds(Msg::sub1, msg, m.model1, update);

WithCmds[TwiceModel] twiceUpdate(Msg::sub2(Msg msg), TwiceModel m)
  = <<m.model1, m2>, cmds2>
  when 
    <Model m2, list[Cmd] cmds2> := mapping.cmds(Msg::sub2, msg, m.model2, update);   

void twiceView(TwiceModel m) {
  div(() {
    mapping.view(Msg::sub1, m.model1, view);
    mapping.view(Msg::sub2, m.model2, view);
  });
}


