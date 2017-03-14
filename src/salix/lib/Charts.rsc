module salix::lib::Charts

import salix::Node;
import salix::Core;

data DataTable
  = gtable(list[Column] columns, list[Row] rows);

data Row
  = grow(list[Cell] cells);  

data Column
  = gcolumn(str \type, str role="", str label="", str id="");
  
data Cell
  = gcell(value v, str formatted = "", map[str, value] props = ());
  
// TODO: make this immediate like dagre/treeView

void chart(str id, str chartType, DataTable table, map[str,value] options=()) 
  = build([], Node(list[Node] _, list[Attr] attrs) {
       return native("charts", id, (), (), (),
         extra = (
           "chartType": chartType,
           "dataTable": table,
           "options": options
         ));
    });
  