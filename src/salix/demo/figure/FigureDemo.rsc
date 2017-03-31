module salix::demo::figure::FigureDemo

import salix::lib::RenderFigure;
import salix::lib::Figure; // for alignments
import salix::App;
import salix::HTML;
import salix::SVG;
import IO;

alias Model = int;

App[Model] figureApp() = 
  app(init, view, update, |http://localhost:9199|, |project://salix/src|); 


Model init() = 37;

data Msg
  = click(str x);

Model update(Msg msg, Model m) {
  println("Clicked: <msg>");
  return m;
}

//http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/Vis/Figure/Figures/box/box.html
void boxExamples(Fig f) {
  f.vcat(vgap(10), () {
    f.box(size(<150,50>), fillColor("lightGray"));
    f.box(size(<150,50>), fillColor("lightGray"), () {
      f.box(shrink(0.8), fillColor("green"));
    });
    
    f.box(size(<150, 50>), fillColor("lightGray"), () {
      f.box(shrink(0.8), align(<0, 0>), fillColor("green"));
    });
    
    f.box(grow(1.2), fillColor("blue"), () {
      f.box(size(<150, 50>), fillColor("lightGray"));
    });
    
    f.box(lineColor("black"), () {
      f.box(lineColor("black"), shrink(0.5), () {
        f.box(lineColor("black"), shrink(0.5), () {
          f.box(lineColor("black"), shrink(0.5));
        });
      });
    });
    
  });
}

// grid examples: http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/Vis/Figure/Figures/grid/grid.html

void gridExample1() {
  salix::lib::RenderFigure::figure(200, 100, (Fig f) {
    f.grid(size(<200, 100>), (GridRow row) {
      row(() {
        f.box(fillColor("Red"), () { f.text("bla\njada"); });
        f.ellipse(fillColor("Blue"));
        f.box(fillColor("Yellow"));  
      });
      row(() {
        f.box(fillColor("Green"), () { f.ellipse(fillColor("Yellow")); });
        f.box(fillColor("Purple"));
        f.box(fillColor("Orange"), () { f.text("blablablabla"); });
      });
    });
  });
}

void gridExample2() {
  salix::lib::RenderFigure::figure(200, 100, (Fig f) {
    f.grid(hgap(10),vgap(15), size(<200, 100>), (GridRow row) {
      row(() {
        f.box(fillColor("Red"), () { f.text("bla\njada"); });
        f.ellipse(fillColor("Blue"));
        f.box(fillColor("Yellow"));  
      });
      row(() {
        f.box(fillColor("Green"), () { f.ellipse(fillColor("Yellow")); });
        f.box(fillColor("Purple"));
        f.box(fillColor("Orange"), () { f.text("blablablabla"); });
      });
    });
  });
}


void gridExample3() {
 salix::lib::RenderFigure::figure(200, 200, (Fig f) {
   f.grid((GridRow row) {
     row(() {
       f.box(fillColor("Red"));
       f.box(fillColor("Blue"));
       f.box(fillColor("Yellow"));
     });
     row(() {
       f.box(fillColor("Green"));
       f.box(fillColor("Orange"));
     });
     row(() {
       f.box(fillColor("Silver"));
     });
   });
 });
}

void gridExample4() {
 salix::lib::RenderFigure::figure(200, 200, (Fig f) {
   f.grid((GridRow row) {
     row(() {
       f.box(fillColor("Red"));
       f.box(size(<20, 20>), resizable(false), align(topRight), fillColor("Blue"));
       f.box(fillColor("Yellow"));
     });
     row(() {
       f.box(fillColor("Green"));
       f.box(fillColor("Purple"));
       f.box(fillColor("Orange"));
     });
     row(() {
       f.box(fillColor("Silver"));
     });
   });
 });
}

// -> bert: nesting grid/vcat/hcat does not work

void view(Model m) { 
  div(() {
    h2("Immediate mode figures");
    div(class("col-md-4"), () {
      h4(() {
        a(href("http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/Vis/Figure/Figures/box/box.html"), "Box examples");
      });
      salix::lib::RenderFigure::figure(500, 1200, (Fig f) {
        boxExamples(f);
      });
    });
    div(class("col-md-4"), () {
      h4(() {
        a(href("http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/Vis/Figure/Figures/grid/grid.html"), "Grid examples");
      });
      gridExample1();
      gridExample2();
      //gridExample3();
      //gridExample4();
    });
    
    //salix::lib::RenderFigure::figure(500, 700, (Fig f) {
    //  f.vcat(gap(<20, 20>), () {
    //    f.box(lineColor("black"), () {
    //      f.hcat(() {
    //        f.circle(shrink(0.8), lineColor("blue"));
    //        f.ellipse(cx(40), cy(90), lineColor("green"));
    //      });
    //    });
    //    f.box(lineColor("red"));
    //    f.grid((GridRow row) {
    //      row(() {
    //        f.text("A");
    //        f.text("B");
    //      });
    //      row(() {
    //        f.text(align(bottomRight), "C");
    //        f.text("D");
    //        f.text("Jurgen");
    //        f.text("Piet");
    //      });
    //    });
    //  });
    //});
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
