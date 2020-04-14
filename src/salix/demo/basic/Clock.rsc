@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Clock

import salix::SVG;
import salix::HTML;
import salix::App;
import salix::Core;
import util::Math;

alias Model = tuple[int time, bool running];

Model init() = <1, false>;

data Msg
  = tick(int time)
  | toggle()
  ;

list[Sub] subs(str id, Model m) = [timeEvery(id, tick, 1000) | m.running ];

Model update(Msg msg, Model t) {
  switch (msg) {
   case tick(int time): t.time = time;
   case toggle(): t.running = !t.running;
  }
  return t;
}

SalixApp[Model] clockApp(str id = "root") 
  = makeApp(id, init, view, update, subs=subs);

App[Model] clockWebApp() 
  = webApp(
      clockApp(),
      index = |project://salix/src/salix/demo/basic/index.html|, 
      static = |project://salix/src|
    );

void view(Model m) {
  div(() {
    h2("Clock using SVG");
    clock(m);
  });
}

void clock(Model m) {
  real angle = 2 * PI() * (toReal(m.time) / 60.0);
  int handX = round(50 + 40 * cos(angle));
  int handY = round(50 + 40 * sin(angle));
  svg(viewBox("0 0 100 100"), width("300px"), () {
    circle(cx("50"), cy("50"), r("45"), fill("#0B79CE"));
    line(x1("50"), y1("50"), x2("<handX>"), y2("<handY>"), stroke("#023963"));
  }); 
  button(onClick(toggle()), "On/Off");
}



