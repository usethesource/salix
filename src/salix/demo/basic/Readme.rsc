@license{
  Copyright (c) 2016-2017 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Readme

import salix::App;
import salix::Core;
import salix::HTML;

import String;
import IO;


alias Model = int;

Model init() = 0;


App[Model] readmeApp()
  = app(init, view, update, |http://localhost:7500|, |project://salix/src|
        subs = counterSubs);

list[Sub] counterSubs(Model m) = [timeEvery(tick, 5000)];

data Msg
  = inc()
  | dec()
  | tick(int time)
  | jitter(int j)
  ;

Model update(Msg msg, Model model) {
  switch (msg) {
    case inc(): {
      model += 1;
      do(random(jitter, -10, 10));
    }
    case dec(): model -= 1;
      
    case tick(_): model += 1;
    
    case jitter(int j): model += j;
  }
  return model;
}

void view(Model m) {
  div(() {
    
    h2("My first counter app in Rascal");
    
    button(onClick(inc()), "▲");
    
    div("<m>");
    
    button(onClick(dec()), "▼");

  });
}

