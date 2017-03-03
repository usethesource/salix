module salix::demo::charts::ChartDemo

import salix::lib::Charts;
import salix::HTML;
import salix::Core;
import salix::App;

DataTable exampleTable() = gtable(
  [gcolumn("string", label="Element"),
   gcolumn("number", label="Density"),
   gcolumn("string", role="style")],
   [
     grow([gcell("Copper"), gcell(8.94), gcell("color: #b87333")]),            // RGB value
     grow([gcell("Silver"), gcell(10.49), gcell("color: silver")]),            // English color name
     grow([gcell("Gold"), gcell(19.30), gcell("color: gold")]),
     grow([gcell("Platinum"), gcell(21.45), gcell("color: #e5e4e2")])  // CSS-style declaration
  ]
);

App[DataTable] chartsApp()
  = app(init, view, update, |http://localhost:7000|, |project://salix/src|);

DataTable init() = exampleTable();

data Msg
  = noOp()
  ;


DataTable update(Msg msg, DataTable m) = m; 

void view(DataTable m) {
  div(() {
    
    h2("Google Charts demo");
    
    chart("myChart", "BarChart", m, options=("legend": "left", "title": "Hello charts", 
       "width": 400, "height": 300));


    h3("More!");
    chart("myChart", "PieChart", m, options=("legend": "left", "title": "Hello charts", 
       "width": 400, "height": 300));
    
    chart("myChart", "LineChart", m, options=("legend": "left", "title": "Hello charts", 
       "width": 400, "height": 300));
    
  });
}