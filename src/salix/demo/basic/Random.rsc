@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Random

import salix::HTML;
import salix::Core;
import salix::App;

alias Model = tuple[int dieFace];

data Msg
  = roll()
  | newFace(int face)
  ;

SalixApp[Model] randomApp(str id = "root") = makeApp(id, init, view, update);

// Single
App[Model] randomWebApp() 
  = webApp(
      randomApp(),
      |project://salix/src/salix/demo/basic/index.html|, 
      |project://salix/src|
    );

// Twice
App[Model] twiceWebApp() 
  = webApp(
      "twiceApp",
      {randomApp(id = "random1"), randomApp(id = "random2")},
      |project://salix/src/salix/demo/basic/twice.html|, 
      |project://salix/src|
    );


Model init() = <1>;

Model update(Msg msg, Model m) {
  switch (msg) {
    
    case roll(): 
      do(random(newFace, 1, 6));
    
    case newFace(int n): 
      m.dieFace = n; 
  
  }
  
  return m;
}

void view(Model m) {
  div(() {
     button(onClick(roll()), "Roll");
     text(m.dieFace);
  });
}
   

