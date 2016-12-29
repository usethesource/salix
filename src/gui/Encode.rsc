module gui::Encode

import List;
import gui::Render;

@doc{This is the basic Message data type that clients
will extend with concrete constructors.

Note, that instead of make Html parametric on Msg (Html[&Msg])
we use a single type and ADT extension. This decision makes
a lot of code slightly less verbose, but sacrifices additional
type checking when nesting components.}
data Msg;

data Sub;

data Cmd;
 

@doc{Handles represent (encoded) functions to decode events.}
data Handle
  = handle(str path, int id)
  ;


@doc{The encoding interface between an App and this library.
An app set this variable to its encapsulated encoder before
rendering. This ensures that encoding is relative to app and not global.
Encoding produces handles for arbitrary values, at some path,
recording the list of active message transformers at the moment of call.} 
public Handle(value, str, list[Msg(Msg)]) _encode;

public &T(Handle,type[&T]) _decode;

Handle encodeHnd(value x) = _encode(x, renderPath(), currentMappers());

Handle encodeCmd(value x) = _encode(x, mappingPath(), currentMappers());

Handle encodeSub(value x) = _encode(x, mappingPath(), currentMappers());

&T decode(Handle h, type[&T] t) = _decode(h, t);

// MAPPING

@doc{The stack of active msg transformers at some point during rendering.}
private list[Msg(Msg)] mappers = [];


list[Msg(Msg)] currentMappers() = mappers;

private str mappingPath()
  = "nonview_" // prefix to make distinct from render paths
  + intercalate("_", [ "<mapperTable[f]>" | Msg(Msg) f <- currentMappers() ]); 

private int mapId = -1;
private map[value, int] mapperTable = ();

private void recordMapper(Msg(Msg) f) {
  //if (f notin mapperTable) { ?????
  if (value k <- mapperTable, k == f) {
    return;
  }
  mapId += 1;
  mapperTable[f] = mapId;
}

void resetMapping() {
  mappers = [];
  mapId = -1;
  mapperTable = ();
}


//private void add(Html h) = push(pop() + [h]);
//
//private void push(list[Html] l) { stack += [l]; }
//
//private list[Html] top() = stack[-1];
//
//private list[Html] pop() {
//  list[Html] elts = top();
//  stack = stack[..-1];
//  return elts;
//}
//
//private void push(Msg(Msg) f) {
//
//}

private &T withMapper(Msg(Msg) f, &T() block) {
  recordMapper(f);
  mappers += [f];
  &T result = block();
  mappers = mappers[..-1];
  return result;
}

// bug: if same name as other mapped, if calling the other
// it can call this one...
private list[Sub] mappedSubs(Msg(Msg) f, &T t, list[Sub](&T) subs) 
  = withMapper(f, list[Sub]() { return subs(t); });

private tuple[&T,list[Cmd]] mappedCmds(Msg(Msg) f, Msg msg, &T t, tuple[&T, list[Cmd]](Msg, &T) upd) 
  = withMapper(f, tuple[&T, list[Cmd]]() { return upd(msg, t); });

@doc{Record mapper to transform messages produced in block according f.}
private void mappedView(Msg(Msg) f, &T t, void(&T) block) { 
   withMapper(f, value() { block(t); return 0; });
}

alias Mapping = tuple[
  list[Sub](Msg(Msg), &T, list[Sub](&T)) subs,
  tuple[&T, list[Cmd]](Msg(Msg), Msg, &T, tuple[&T, list[Cmd]](Msg, &T)) cmds,
  void(Msg(Msg), &T, void(&T)) view
];

public /*const*/ Mapping mapping = <mappedSubs, mappedCmds, mappedView>;
