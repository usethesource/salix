module examples::Clock

import gui::SVG;
import gui::HTML;
import gui::App;
import gui::Render;
import gui::Decode;
import util::Math;

// bigger example: https://github.com/pghalliday/elm-introduction/blob/master/clock.elm

// why does it work with value here and not Model?
App[Model] clockApp() = 
  app(init(), examples::Clock::view, examples::Clock::update, 
    |http://localhost:9100|, |project://elmer/src/examples|,
    subs = subs); 


void view(Model m) {
  div(() {
    p("Hello world!");
    clock(m);
  });
}



alias Model = tuple[int time, bool running];

Model init() = <1, true>;

data Msg
  = tick(int time)
  | toggle()
  ;

list[Sub] subs(Model m) 
  = [timeEvery(1000, tick) | m.running ];

Model update(tick(int time), Model t) = t[time=time];
Model update(toggle(), Model t) = t[running=!t.running];

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
      
 /*
 elm logo:
 
 div(gui::HTML::style(<"height", "100%">, <"width", "100px">), () {
    svg(gui::HTML::style(<"display", "block">, <"float", "left">), version("1.1"), x("0"), y("0"), viewBox("0 0 323.141 322.95"), () {
      polygon(fill("#F0AD00"), points("161.649,152.782 231.514,82.916 91.783,82.916"));
      polygon(fill("#7FD13B"), points("8.867,0 79.241,70.375 232.213,70.375 161.838,0"));
      rect(fill("#7FD13B"), x("192.99"), y("107.392"), width("107.676"), height("108.167"),
        transform("matrix(0.7071 0.7071 -0.7071 0.7071 186.4727 -127.2386)"));
      polygon(fill("#60B5CC"), points("323.298,143.724 323.298,0 179.573,0"));
      polygon(fill("#5A6378"), points("152.781,161.649 0,8.868 0,314.432"));
      polygon(fill("#F0AD00"), points("255.522,246.655 323.298,314.432 323.298,178.879"));
      polygon(fill("#60B5CC"), points("161.649,170.517 8.869,323.298 314.43,323.298"));
    });
  });
  
  */