@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

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

SalixApp[Model] celsiusApp(str id = "root") = makeApp(id, init, view, update);

App[Model] celsiusWebApp() 
  = webApp(
      celsiusApp(),
      index = |project://salix/src/salix/demo/basic/index.html|, 
      static = |project://salix/src|
    ); 

Model init() = 37.0;

void view(Model m) { 
  div(() {
    h2("Celsius to fahrenheit converter");
    p(() {
      text("C: "); 
      input(\value("<round(m)>"),\type("number"), onInput(c));
    });
    p(() {
      text("F: ");
      input(\value("<round(toF(m))>"),\type("number"), onInput(f));
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


