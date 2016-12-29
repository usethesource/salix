module examples::Clock

import gui::SVG;
import gui::HTML;
import gui::App;
import gui::Render;
import gui::Comms;
import util::Math;

// bigger example: https://github.com/pghalliday/elm-introduction/blob/master/clock.elm

alias Model = tuple[int time, bool running];

Model init() = <1, false>;

data Msg
  = tick(int time)
  | toggle()
  ;

list[Sub] subs(Model m) = [timeEvery(tick, 1000) | m.running ];

Model update(tick(int time), Model t) = t[time=time];
Model update(toggle(), Model t) = t[running=!t.running];

App[Model] clockApp() = 
  app(init(), examples::Clock::view, examples::Clock::update, 
    |http://localhost:9100|, |project://elmer/src/examples|,
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



