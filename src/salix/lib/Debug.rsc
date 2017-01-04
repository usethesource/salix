module salix::lib::Debug

import salix::HTML;
import salix::App;
import salix::Core;
import salix::Node; // for null()...

import List;

alias DebugModel[&T]
  = tuple[int current, list[&T] models, list[Msg] messages, WithCmd[&T](Msg, &T) update]
  ;
  
data Msg
  = next()
  | prev()
  | sub(Msg msg)
  | goto(int version)
  ;

App[DebugModel[&T]] debug(WithCmd[&T] model, 
                          void(DebugModel[&T]) view, // // can't wrap view implicitly, because it'll lead to closures... 
                          WithCmd[&T](Msg, &T) upd, loc http, loc static,
                          Subs[&T] subs = noSubs, str root = "root")
  = app(wrapModel(model, upd), view, debugUpdate, http, static,
        subs = wrapSubs(subs), root = root); 


Subs[DebugModel[&T]] wrapSubs(Subs[&T] subs) 
  = list[Sub](DebugModel[&T] m) { return mapSubs(Msg::sub, m.models[m.current], subs); };

WithCmd[DebugModel[&T]] wrapModel(WithCmd[&T] model, WithCmd[&T](Msg, &T) upd) 
  = withCmd(<0, [model.model], [], upd>, model.command);


void debugView(DebugModel[&T] model, void(&T) subView) {
  div(() {
    div(class("row"), () {
      div(class("col-lg-8"), () {
        
        button(onClick(prev()), "Prev");
        text("<model.current>");
        button(onClick(next()), "Next");
        
        div(style(<"border", "1px solid">), () {
          mapView(Msg::sub, model.models[model.current], subView);
        });
      
      });
      
      div(class("col-lg-4"), () {
      
        ul(style(<"all", "unset">), () {
          for (int i <- [0..size(model.messages)]) {
            li(style(("list-style": "none", "padding": "0 0" ,"font-size": "small", "border-bottom": "none")), () {
               a(style(("font-weight": "bold" | i == model.current)),
                  onClick(goto(i)), model.messages[i]);      
            });
          }
        });
      
      });
    });
  });
}

WithCmd[DebugModel[&T]] debugUpdate(Msg msg, DebugModel[&T] m) {
  Cmd cmd = none();

  switch (msg) {
  
    case next():
      m.current = m.current < size(m.models) - 1 ? m.current + 1 : m.current;
       
    case prev(): 
      m.current = m.current > 0 ? m.current - 1 : m.current;
      
    case sub(Msg s): {
      <newModel, cmd> = mapCmd(Msg::sub, s, m.models[m.current], m.update);
      m.models += [newModel];
      m.messages += [msg];
      m.current = size(m.models) - 1;
    }

    case goto(int v): 
      m.current = v;
  }
  
  return withCmd(m, cmd);
}

