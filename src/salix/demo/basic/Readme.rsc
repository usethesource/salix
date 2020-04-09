@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Readme

import salix::App;
import salix::Core;
import salix::HTML;


alias Model = int;

Model init() = 0;


SalixApp[Model] readmeApp(str appId = "root")
  = makeApp(appId, init, view, update, subs = counterSubs);

App[Model] readmeWebApp() 
  = webApp(
      readmeApp(),
      |project://salix/src/salix/demo/basic/index.html|, 
      |project://salix/src|
    );

list[Sub] counterSubs(str appId, Model _) = [timeEvery(appId, tick, 5000)];

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

