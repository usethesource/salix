@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::CodeMirror

import salix::HTML;
import salix::App;
import salix::Index;
import salix::lib::codemirror::CodeMirror;

alias Model = tuple[list[Msg] changes, str src];

SalixApp[str] cmApp(str id = "root") 
  = makeApp(id, init, withIndex("CM", view, exts = [codemirror()])
      , update, parser=parseMsg);

App[str] cmWebApp()
  = webApp(
      cmApp(), 
      |project://salix/src/salix/demo/basic/index.html|, 
      |project://salix/src|
    );


Model init() 
  = <[], "function hello() {\n  console.log(\'Hello world\');\n}">;

data Msg
  = myChange(int, int, int, int, str, str)
  ;

Model update(Msg msg, Model model) {
  switch (msg) {
    case m:myChange(int _, int _, int _, int _, str _, str _):
      model.changes += [m];
  }
  return model;
}

void view(Model model) {
  div(() {
    h2("Code Mirror demo");
    div(() {
      codeMirror("cm", style(("height": "auto")), onChange(myChange), 
        mode("javascript"), lineNumbers(true), \value(model.src));
    });
    for (Msg m <- model.changes) {
      text(m);
      text("; ");
    }
  });
}