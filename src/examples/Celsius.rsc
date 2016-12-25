module examples::Celsius

import gui::HTML;
import gui::App;
import String;
import util::Math;

data Msg
  = c(str c)
  | f(str f)
  ;

App celsiusApp() = 
  celsiusApp(37.0, |http://localhost:9193|, |project://elmer/src/examples|); 

App celsiusApp(real m, loc http, loc static) 
  = app(m, view, update, http, static); 

void view(real m) { 
  div(() {
    h2("Celsius to fahrenheit converter");
    p(() {
      text("C: "); 
      input(\value("<round(m)>"),\type("text"), onInput(c));
    });
    p(() {
      text("F: ");
      input(\value("<round(toF(m))>"),\type("text"), onInput(f));
    });
  });
}


real toF(real c) = c * 9.0/5.0 + 32.0;

real toC(real f) = (f - 32.0) * 5.0/9.0;

real update(c(str new), real _) = toReal(new);

real update(f(str new), real _) = toC(toReal(new));


