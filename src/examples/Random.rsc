module examples::Random

import gui::HTML;
import gui::App;
import gui::Decode;

import util::Math;

alias Model = tuple[int dieFace];

data Msg
  = roll()
  | newFace(int face)
  ;

App[Model] randomApp()
  = app(init(), view, update, 
    |http://localhost:9097|, |project://elmer/src/examples|); 


WithCmds[Model] init() = <<1>, []>;
  
WithCmds[Model] update(roll(), Model m) = <m, [random(newFace, 1, 6)]>;

WithCmds[Model] update(newFace(int n), Model m) = <m[dieFace=n], []>;

void view(Model m) {
  div(() {
     h1(m.dieFace);
     button(onClick(roll()), "Roll");
  });
}

