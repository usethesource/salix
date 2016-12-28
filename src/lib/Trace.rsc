module lib::Trace

import gui::HTML;
import gui::App;
import gui::Decode;
import List;

alias TraceModel[&T] = tuple[list[Msg] msgs, &T model];


// requires bootstrap  
void traceView(TraceModel[&T] model, void(&T) subView) {
  div(() {
    div(class("row"), () {
      div(class("col-lg-8"), () {
        subView(model.model);
      });
      div(class("col-lg-4"), () {
        ul(style(<"all", "unset">), () {
          for (Msg m <- model.msgs) {
            li(style(("list-style": "none", "padding": "0 0"
                     ,"font-size": "small", "border-bottom": "none")), "<m>");
          }
        });
      });
    });
  });
}

