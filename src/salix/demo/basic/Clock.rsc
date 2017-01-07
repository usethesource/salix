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

list[Sub] subs(Model m) = [timeEvery(tick, 1000) | m.running ];

Model update(Msg msg, Model t) {
  switch (msg) {
   case tick(int time): t.time = time;
   case toggle(): t.running = !t.running;
  }
  return t;
}

App[Model] clockApp() = 
  app(init, view, update, 
    |http://localhost:9100|, |project://salix/src|,
    subs = subs); 


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



