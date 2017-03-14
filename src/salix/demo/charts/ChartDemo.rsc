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
     grow([gcell("Copper"), gcell(8.94), gcell("color: #b87333")]), 
     grow([gcell("Silver"), gcell(10.49), gcell("color: silver")]), 
     grow([gcell("Gold"), gcell(19.30), gcell("color: gold")]),
     grow([gcell("Platinum"), gcell(21.45), gcell("color: #e5e4e2")]) 
  ]
);

App[DataTable] chartsApp()
  = app(init, view, update, |http://localhost:7001|, |project://salix/src|);

DataTable init() = exampleTable();

data Msg
  = noOp()
  | incGold()
  | decGold()
  ;


DataTable update(Msg msg, DataTable m) {
  switch (msg) {
    case incGold(): 
      if (real gold := m.rows[2].cells[1].v) {
        m.rows[2].cells[1].v = gold + 1.0;
      }
    case decGold():
      if (real gold := m.rows[2].cells[1].v) {
        m.rows[2].cells[1].v = gold - 1.0;
      }
  }
 return m;
} 

void view(DataTable m) {
  div(() {
    
    h2("Google Charts demo");
    
    button(onClick(incGold()), "Increase gold");
    button(onClick(decGold()), "Decrease gold");
    
    chart("myChart", "BarChart", legend("left"), title("Hello Charts"), width(400), height(300), (C col, R row) {
       for (Column c <- m.columns) {
         col(c.\type, ColAttr::label(c.label), ColAttr::role(c.role));
       }
       for (Row r <- m.rows) {
         row((Ce cell) {
            for (Cell c <- r.cells) {
              cell(c.v);
            }
         });
       }
    });
    
  });
}

//void view_(DataTable m) {
//  div(() {
//    
//    h2("Google Charts demo");
//    
//    button(onClick(incGold()), "Increase gold");
//    button(onClick(decGold()), "Decrease gold");
//    
//    chart_("myChart", "BarChart", m, options=("legend": "left", "title": "Hello charts", 
//       "width": 400, "height": 300));
//
//
//    h3("More!");
//    chart("pie", "PieChart", m, options=("legend": "left", "title": "Hello charts", 
//       "width": 400, "height": 300));
//    
//  });
//}