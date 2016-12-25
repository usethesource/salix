module examples::ListDemo

import gui::HTML;
import gui::App;
import gui::List;

App listApp() 
  = app(<["hello", "world!"], editStr, initStr>, view, editList, 
        |http://localhost:9199|, |project://elmer/src/examples|); 

data Msg
  = changeText(str x)
  ;

void view(ListModel[str] m) {
  listView(m, strView);
}

void strView(str x) {
  input(\type("text"), \value(x), onInput(changeText));
}

str initStr(int i) = "Edit string <i>";

str editStr(changeText(str x), str _) = x;
