module salix::demo::treeview::TreeViewDemo

import salix::Core;
import salix::App;
import salix::lib::TreeView;
import salix::HTML;
import IO;

import lang::json::IO;

App[list[node]] treeViewApp()
  = app(init, view, update, |http://localhost:7031|, |project://salix/src|
       , parser = parseMsg);

list[node] init() = [];

data Msg
  = click()
  | selected(str nodeId)
  ;
  

list[node] update(Msg msg, list[node] m) {
  switch (msg) {
    case click(): println("click");
    case selected(str id) : println("id = <id>");
  }
  return m;
}

void view(list[node] m) {
  div(() {
    //treeView("myTree", m, onNodeCollapsed(Msg::selected));
    viewTree(onNodeCollapsed(Msg::selected), (T tnode) {
      tnode("Parent 1", () {
        tnode("Child 1", () {
          tnode("Grandchild 1");
          tnode("Grandchild 2");
        });
        tnode("Child 2");
     });
    tnode("Parent 2", color("red"));
    tnode("Parent 3", selected());
    tnode("Parent 4");
    tnode("Parent 5");
    });
  });
}  
