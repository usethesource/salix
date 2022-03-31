module salix::demo::charts::ChartDemo

import salix::lib::charts::Charts;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::Index;

alias Model = real;

SalixApp[DataTable] chartsApp(str id = "chartsApp") 
  = makeApp(id, init, withIndex("Charts", id, view, exts = [charts()]), update); 

App[DataTable] chartsWebApp() 
  = webApp(
      chartsApp(),
      |project://salix/src/salix/demo/charts/index.html|, 
      |project://salix/src|
    );

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

void view(Model gold, int w = 400, int h = 300) {
	h2("Google Charts demo");
	
	button(onClick(incGold()), "Increase gold");
	button(onClick(decGold()), "Decrease gold");
	
	chart("myChart", "BarChart", legend("left"), title("Hello Charts"), width(w), height(h), (C col, R row) {
	   col("string", [ColAttr::label("Element")]);
	   col("number", [ColAttr::label("Density")]);
	   col("string", [role("style")]);
	   row((Ce cell) { cell("Copper",[]);   cell(8.94,[]);  cell("color: #b87333",[]); });
	   row((Ce cell) { cell("Silver",[]);   cell(10.49,[]); cell("color: silver",[]);  }); 
	   row((Ce cell) { cell("Gold",[]);     cell(gold,[]);  cell("color: gold",[]);    });
	   row((Ce cell) { cell("Platinum",[]); cell(21.45,[]); cell("color: #e5e4e2",[]); }); 
	});
}
