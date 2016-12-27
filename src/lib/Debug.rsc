module lib::Debug

import gui::HTML;
import gui::App;
import List;

// TODO: make an undoable component
// which simply reuses an original model with keyword params so that
// parents are unaware of it. 

// See here for more inspiration:
// https://github.com/elm-lang/virtual-dom/blob/master/src/VirtualDom/Expando.elm

alias DebugModel[&T]
  = tuple[int current, list[&T] models, &T(Msg, &T) update]
  ;
  
data Msg
  = next()
  | prev()
  | sub(Msg msg)
  | ignore(Msg msg)
  | goto(int version)
  ;

App[DebugModel[&T]] debug(&T model, void(&T) view, &T(Msg, &T) upd, loc http, loc static)
  = app(wrapModel(model, upd), wrapView(view), debugUpdate, http, static); 

DebugModel[&T] wrapModel(&T model, &T(Msg, &T) upd) 
  = <0, [model], upd>;

void(DebugModel[&T] d) wrapView(void(&T) view) 
  = void(DebugModel[&T] d) { debugView(d, view); };

void debugView(DebugModel[&T] model, void(&T) subView) {
  div(() {
    button(onClick(prev()), "Prev");
    text("<model.current>");
    button(onClick(next()), "Next");
    p("Current model <model.models[model.current]>");
    
    div(style(<"border", "1px solid">), () {
      mapped(Msg::sub, model.models[model.current], subView);
    });
    
    h2("Previous versions");
    for (int i <- [0..size(model.models)]) {
      div(style(<"border", "1px dotted">), () {
        p(i == model.current ? style(<"color", "red">) : null(), "Version: <i>");
        button(onClick(goto(i)), "Goto <i>");
        mapped(Msg::ignore, model.models[i], subView);
      });
    }
  });
}

DebugModel[&T] debugUpdate(next(), DebugModel[&T] m)
  = m[current = m.current < size(m.models) - 1 ? m.current + 1 : m.current]; 
  
DebugModel[&T] debugUpdate(prev(), DebugModel[&T] m)
  = m[current = m.current > 0 ? m.current - 1 : m.current];
  
DebugModel[&T] debugUpdate(sub(Msg msg), DebugModel[&T] m)
  = m[current=size(m.models)][models = m.models + [m.update(msg, m.models[m.current])]];
 
DebugModel[&T] debugUpdate(ignore(Msg msg), DebugModel[&T] m)
 = m; 
 
DebugModel[&T] debugUpdate(goto(int version), DebugModel[&T] m)
 = m[current=version]; 
 