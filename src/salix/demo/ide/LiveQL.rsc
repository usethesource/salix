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

