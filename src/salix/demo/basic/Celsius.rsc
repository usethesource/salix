module salix::demo::basic::Celsius

import salix::App;
import salix::HTML;
import String;
import util::Math;


alias Model = real;

data Msg
  = c(str c)
  | f(str f)
  ;

App[Model] celsiusApp() = 
  app(init, |http://localhost:9193|, |project://salix/src|); 


Model init() = 37.0;

void view(Model m) { 
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

real update(Msg msg, Model model) {
  switch (msg) {
    case c(str new): model = toReal_(new);
    case f(str new): model = toC(toReal_(new));
  }
  return model;
}


