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


data Decoder
  = random(Handle h, int result);

data Cmd
  = random(Handle handle, int from, int to)
  ;

Cmd random(Msg(int) f, int from, int to) = random(encode(f), val);  
 
tuple[Model,list[Cmd]] init() = <<1>, []>;
  
tuple[Model,list[Cmd]] update(roll(), Model m) = <m, [random(newFace, 1, 6)]>;

tuple[Model,list[Cmd]] update(newFace(int n), Model m) = <m[dieFace=n], []>;

void view(Model m) {
  div(() {
     h1(m.dieFace);
     button(onClick(roll()), "Roll");
  });
}

