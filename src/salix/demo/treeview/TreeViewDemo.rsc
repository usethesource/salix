module salix::demo::treeview::TreeViewDemo

import salix::Core;
import salix::App;
import salix::lib::TreeView;
import salix::HTML;
import IO;

import lang::json::IO;

list[TreeNode] myTree() = [
  tnode("Parent 1",
    nodes = [
      tnode("Child 1",
        nodes = [
          tnode("Grandchild 1"),
          tnode("Grandchild 2")
        ]
      ),
      tnode("Child 2")
    ]
  ),
  tnode("Parent 2", color="red"),
  tnode("Parent 3"),
  tnode("Parent 4"),
  tnode("Parent 5")
];

App[list[TreeNode]] treeViewApp()
  = app(init, view, update, |http://localhost:7031|, |project://salix/src|
       , parser = parseMsg);

list[TreeNode] init() = myTree();

data Msg
  = click()
  | selected(str nodeId)
  ;
  

list[TreeNode] update(Msg msg, list[TreeNode] m) {
  switch (msg) {
    case click(): println("click");
    case selected(str id) : println("id = <id>");
  }
  return m;
}

void view(list[TreeNode] m) {
  div(() {
    treeView("myTree", m, onNodeCollapsed(Msg::selected));
  });
}  
