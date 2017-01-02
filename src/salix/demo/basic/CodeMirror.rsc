module salix::demo::basic::CodeMirror

import salix::HTML;
import salix::App;
import salix::lib::CodeMirror;
import IO;

alias Model = tuple[list[Msg] changes, str src];

App[str] cmApp()
  = app(init(), view, update, |http://localhost:9000|, |project://salix/src|); 


Model init() {
  registerCodeMirror();
  return <[], "function hello() {\n  console.log(\'Hello world\');\n}">;
}

data Msg
  = myChange(int, int, int, int, str, str)
  ;

Model update(Msg msg, Model model) {
  switch (msg) {
    case m:myChange(int fl, int fc, int tl, int tc, str txt, str del):
      model.changes += [m];
  }
  return model;
}

void view(Model model) {
  div(() {
    h2("Code Mirror demo");
    div(() {
      codeMirror(style(("height": "auto")), onChange(myChange), 
        mode("javascript"), lineNumbers(true), \value(model.src));
    });
    for (Msg m <- model.changes) {
      text(m);
      text("; ");
    }
  });
}