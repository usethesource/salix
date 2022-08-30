@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Loop

import salix::App;
import salix::Core;
import salix::HTML;
import salix::Index;

import String;
import List;

alias Model = tuple[int count, list[int] numbers];

Model init() {
  do(random(addNumber, 1, 100));
  return <100, []>;
}

SalixApp[Model] loopApp(str id = "root") 
  = makeApp(id, init, withIndex("Loop", id, view), update); 

App[Model] loopWebApp() 
  = webApp(
      loopApp(), 
      |project://salix/src|
    );

data Msg
  = addNumber(int n)
  | updateCount(str x)
  ;

Model update(Msg msg, Model m) {

  switch (msg) {
    case addNumber(int x): {
      if (size(m.numbers) < m.count) {
        m.numbers += [x];
        do(random(addNumber, 1, 100));
      }
    }
    
    case updateCount(str x): {
      m.count = toInt(x);
      m.numbers = m.numbers[0..m.count];
      do(random(addNumber, 1, 100));
    }
      
  }
  
  return m;
}

void view(Model m) {
 text("Count: ");
 input(\type("text"), \value("<m.count>"), onInput(updateCount));
 for (int i <- [0..size(m.numbers)]) {
   p("<i>: <m.numbers[i]>");
 }
}