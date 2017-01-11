@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::ide::LiveQL

import salix::demo::ide::QL;




void qlView(Form f) {
  div(() {
    h2(f.name);
    ul(() {
      for (Question q <- f.questions) {
        questionView(q);
      }
    });
  });
}

void questionView((Question)`<Label l> <Var v>: <Type t>`) {
  label(\for(v), l);
  widgetView(t, v);
}

