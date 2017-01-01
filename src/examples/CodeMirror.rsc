module examples::CodeMirror

import gui::HTML;
import gui::App;
import lib::codemirror::CodeMirror;
import IO;

alias Model = tuple[int times, str src];

App[str] cmApp()
  = app(<0, "function hello() {}">, view, update, 
        |http://localhost:9000|, |project://elmer/src|); 


data Msg
  = addEditor()
  | removeEditor()
  | myChange(int, int, int, int, str, str)
  ;

Model update(Msg msg, Model model) {
  switch (msg) {
    case addEditor(): model.times += 1;
    case removeEditor(): model.times -= 1;
  }
  return model;
}

void view(Model model) {
  println("Model: <model>");
  div(() {
    button(onClick(addEditor()), "Add one");
    button(onClick(removeEditor()), "Remove one");
    br();
    div(() {
      for (int i <- [0..model.times]) {
        codeMirror(style(("height": "auto")), onChange(myChange), 
          mode("javascript"), lineNumbers(true), \value(model.src));
      }
    });
  });
}