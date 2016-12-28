module lib::Trace

import gui::HTML;
import gui::App;
import gui::Decode;
import List;

alias TraceModel[&T]
  = tuple[list[Msg] msgs, &T model]
  ;
  
void traceView(TraceModel[&T] model, void(&T) subView) {
  div(() {
    div(class("row"), () {
      div(class("col-lg-8"), () {
        subView(model.model);
      });
      div(class("col-lg-4"), () {
        ul(() {
          for (Msg m <- model.msgs) {
            li(style(<"list-style", "none">, <"font-size", "small">), "<m>");
          }
        });
      });
    });
  });
}

TraceModel[&T] traceUpdate(sub(Msg msg), TraceModel[&T] m) = m.update(m.model);