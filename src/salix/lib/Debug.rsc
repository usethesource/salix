@license{
  Copyright (c) 2016-2017 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}
module salix::lib::Debug

import salix::HTML;
import salix::App;
import salix::Core;
import salix::Node; // for null()...

import List;

alias DebugModel[&T]
  = tuple[int current, list[&T] models, list[Msg] messages, &T(Msg, &T) update]
  ;
  
data Msg
  = next()
  | prev()
  | sub(Msg msg)
  | goto(int version)
  ;

App[DebugModel[&T]] debug(&T() model, 
                          void(DebugModel[&T]) view, // // can't wrap view implicitly, because it'll lead to closures... 
                          &T(Msg, &T) upd, loc http, loc static,
                          Subs[&T] subs = noSubs, str root = "root")
  = app(wrapModel(model, upd), view, debugUpdate, http, static,
        subs = wrapSubs(subs), root = root); 


Subs[DebugModel[&T]] wrapSubs(Subs[&T] subs) 
  = list[Sub](DebugModel[&T] m) { return mapSubs(Msg::sub, m.models[m.current], subs); };

DebugModel[&T] wrapModel(&T() model, &T(Msg, &T) upd) 
  = DebugModel[&T]() {
      &T m = mapCmds(Msg::sub, model);
      return withCmd(<0, [m], [], upd>, c);
    };


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

DebugModel[&T] debugUpdate(Msg msg, DebugModel[&T] m) {

  switch (msg) {
  
    case next():
      m.current = m.current < size(m.models) - 1 ? m.current + 1 : m.current;
       
    case prev(): 
      m.current = m.current > 0 ? m.current - 1 : m.current;
      
    case sub(Msg s): {
      newModel = mapCmds(Msg::sub, s, m.models[m.current], m.update);
      m.models += [newModel];
      m.messages += [msg];
      m.current = size(m.models) - 1;
    }

    case goto(int v): 
      m.current = v;
  }
  
  return m;
  
}

