module salix::demo::treeview::TreeViewDemo

import salix::App;
import salix::lib::treeview::TreeView;
import salix::HTML;

alias Model = str;

SalixApp[Model] treeViewApp(str id = "treeViewDemo") = makeApp(id, init, view, update, parser = parseMsg);

App[Model] treeViewWebApp()
  = webApp(
      treeViewApp(),
      |project://salix/src/salix/demo/treeview/index.html|, 
      |project://salix/src| 
    );

Model init() = "";

data Msg
  = click()
  | selected(str nodeId)
  ;
  

Model update(Msg msg, Model m) {
  switch (msg) {
    case selected(str id) : m = id;
  }
  return m;
}

void view(Model m) {
  div(() {
    h3("Tree view demo");
    h5("Selected: <m>");
    
    treeView(onNodeSelected(Msg::selected), (T tnode) {
      tnode("Parent 1", [() {
        tnode("Child 1", [() {
          tnode("Grandchild 1",[]);
          tnode("Grandchild 2",[]);
        }]);
        tnode("Child 2", [selected()]);
     }]);
     tnode("Parent 2", [color("red")]);
     tnode("Parent 3", []);
     tnode("Parent 4", []);
     tnode("Parent 5", []);
     if (/1$/ := m) {
       tnode("Another one because 1!!!", []);
     }
     if (/2$/ := m) {
       tnode("Another one because 2!!!", []);
     }
   });
 });
}  
