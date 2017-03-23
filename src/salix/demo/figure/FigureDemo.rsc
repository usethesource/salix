module salix::demo::figure::FigureDemo

import salix::lib::RenderFigure;
import salix::App;
import salix::HTML;

alias Model = int;

App[Model] figureApp() = 
  app(init, view, update, |http://localhost:9199|, |project://salix/src|); 


Model init() = 37;

data Msg;

Model update(Msg msg, Model m) = m;

void view(Model m) { 
  div(() {
    h2("Immediate mode figures");
    salix::lib::RenderFigure::figure(100, 200, (Fig f) {
      f.vcat(() {
        f.box(lineColor("black"), () {
          f.circle(lineColor("blue"));
        });
        f.box(lineColor("red"));
      });
    });
  });
}