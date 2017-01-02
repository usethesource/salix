module demo::basic::Celsius

import salix::HTML;
import salix::App;
import salix::lib::Debug;
import String;
import util::Math;


data Msg
  = c(str c)
  | f(str f)
  ;

App[real] celsiusApp() = 
  celsiusApp(37.0, |http://localhost:9193|, |project://salix/src|); 

App[real] celsiusApp(real m, loc http, loc static) 
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

real toReal_(str s) {
  try {
    return toReal(s);
  }
  catch IllegalArgument():
    return 0.0;
}

real update(Msg msg, real model) {
  switch (msg) {
    case c(str new): model = toReal_(new);
    case f(str new): model = toC(toReal_(new));
  }
  return model;
}


