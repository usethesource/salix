module lib::Debug

import gui::HTML;
import gui::App;
import gui::Core;
import gui::Node; // for null()...
import List;

alias DebugModel[&T]
  = tuple[int current, list[&T] models, list[Msg] messages, WithCmds[&T](Msg, &T) update]
  ;
  
data Msg
  = next()
  | prev()
  | sub(Msg msg)
  | goto(int version)
  ;

//App[DebugModel[&T]] debug(&T model, void(&T) view, &T(Msg, &T) upd, loc http, loc static)
//  = app(wrapModel(model, upd), wrapView(view), debugUpdate, http, static); 

App[DebugModel[&T]] debug(WithCmds[&T] model, void(&T) view, 
                          WithCmds[&T](Msg, &T) upd, loc http, loc static,
                          Subs[&T] subs = noSubs, str root = "root")
  = app(wrapModel(model, upd), wrapView(view), debugUpdate, http, static,
        subs = wrapSubs(subs), root = root); 


Subs[DebugModel[&T]] wrapSubs(Subs[&T] subs) 
  = list[Sub](DebugModel[&T] m) { return mapping.subs(Msg::sub, m.models[m.current], subs); };

WithCmds[DebugModel[&T]] wrapModel(WithCmds[&T] model, WithCmds[&T](Msg, &T) upd) 
  = withCmds(<0, [model.model], [], upd>, model.commands);

void(DebugModel[&T]) wrapView(void(&T) view) 
  = void(DebugModel[&T] d) { debugView(d, view); };


void debugView(DebugModel[&T] model, void(&T) subView) {
  div(() {
    div(class("row"), () {
      div(class("col-lg-8"), () {
        
        button(onClick(prev()), "Prev");
        text("<model.current>");
        button(onClick(next()), "Next");
        
        div(style(<"border", "1px solid">), () {
          mapping.view(Msg::sub, model.models[model.current], subView);
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

WithCmds[DebugModel[&T]] debugUpdate(Msg msg, DebugModel[&T] m) {
  list[Cmd] cmds = [];
  
  switch (msg) {
  
    case next():
      m.current = m.current < size(m.models) - 1 ? m.current + 1 : m.current;
       
    case prev():
      m.current = m.current > 0 ? m.current - 1 : m.current;
      
    case sub(Msg s): {
      <newModel, cmds> = mapping.cmds(Msg::sub, s, m.models[m.current], m.update);
      m.models += [newModel];
      m.messages += [s];
      m.current += 1;
    }

    case goto(int v): 
      m.current = v;
  }
  
  return withCmds(m, cmds);
}

