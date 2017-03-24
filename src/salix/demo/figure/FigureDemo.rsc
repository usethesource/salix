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
          f.hcat(() {
            f.circle(lineColor("blue"));
            f.ellipse(cx(40), cy(90), lineColor("green"));
          });
        });
        f.box(lineColor("red"));
      });
    });
  });
}

//void view(Model m) { 
//  div {
//    h2 "Immediate mode figures";
//    figure(100, 200) {
//      vcat {
//        box(lineColor: "black") {
//          hcat {
//            circle(lineColor: "blue");
//            circle(lineColor: "green");
//          }
//        }
//        box(lineColor: "red");
//      }
//    }
//  }
//}
//
