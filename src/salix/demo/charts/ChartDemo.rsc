module salix::demo::charts::ChartDemo

import salix::lib::Charts;
import salix::HTML;
import salix::Core;
import salix::App;

alias Model = real;

App[DataTable] chartsApp()
  = app(init, view, update, |http://localhost:7001|, |project://salix/src|);

Model init() = 19.30;

data Msg
  = incGold()
  | decGold()
  ;


Model update(Msg msg, Model m) {
  switch (msg) {
    case incGold(): m += 1.0;
    case decGold(): m -= 1.0;
  }
 return m;
} 

void view(Model gold) {
  div(() {
    
    h2("Google Charts demo");
    
    button(onClick(incGold()), "Increase gold");
    button(onClick(decGold()), "Decrease gold");
    
    chart("myChart", "BarChart", legend("left"), title("Hello Charts"), width(400), height(300), (C col, R row) {
       col("string", ColAttr::label("Element"));
       col("number", ColAttr::label("Density"));
       col("string", role("style"));
       row((Ce cell) { cell("Copper");   cell(8.94);  cell("color: #b87333"); });
       row((Ce cell) { cell("Silver");   cell(10.49); cell("color: silver");  }); 
       row((Ce cell) { cell("Gold");     cell(gold);  cell("color: gold");    });
       row((Ce cell) { cell("Platinum"); cell(21.45); cell("color: #e5e4e2"); }); 
    });
    
  });
}
