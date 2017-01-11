@license{
  Copyright (c) 2016-2017 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
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

