module gui::Core

// import this if you need commands/subscriptions, or define your
// own event handling parsers.

import List;
import String;

@doc{This is the basic Message data type that clients
will extend with concrete constructors.

Note, that instead of make Html parametric on Msg (Html[&Msg])
we use a single type and ADT extension. This decision makes
a lot of code slightly less verbose, but sacrifices additional
type checking when nesting components.}
data Msg;

@doc{Handles represent (encoded) functions to decode events.
 id: identifies the decoder function (e.g., of type Msg(int))
 maps: identifies the active mappers for this handle.  }
data Handle
  = handle(int id, list[int] maps = [])
  ;


@doc{The encoding interface between an App and this library.
An app set this variable to its encapsulated encoder before
rendering. This ensures that encoding is relative to app and not global.
Encoding produces handles for arbitrary values, at some path,
recording the list of active message transformers at the moment of call.} 
public int(value) _encode;

public &T(int,type[&T]) _decode;

@doc{The stack of active msg transformers at some point during rendering.}
private list[Msg(Msg)] mappers = [];

Handle encode(value x)
  = handle(_encode(x), maps=[ _encode(f) | Msg(Msg) f <- mappers ]);

&T decode(int id, type[&T] t) = _decode(id, t); 
 
@doc{Subs are like events: they are sent to JS, and Results are sent back.}
data Sub // Subscriptions
  = timeEvery(Handle handle, int interval)
  ;

@doc{Smart constructors for constructing encoded subscriptions.}
Sub timeEvery(Msg(int) int2msg, int interval)
  = timeEvery(encode(int2msg), interval);

@doc{Commands represent actions that need to be performed at the client.}
data Cmd  // Commands
  = random(Handle handle, int from, int to)
  ;
  
@doc{Smart constructors for constructing encoded commands.}
Cmd random(Msg(int) f, int from, int to)
  = random(encode(f), from, to);

alias WithCmds[&T] = tuple[&T model, list[Cmd] commands];  

// functions to hide the representation of WithCmds.
WithCmds[&T] noCmds(&T model) = <model, []>;
WithCmds[&T] withCmds(&T model, list[Cmd] cmds) = <model, cmds>;

alias Subs[&T] = list[Sub](&T);

list[Sub] noSubs(&T t) = [];


@doc{Handlers are what is sent to the client for handling user events.}
data Hnd // Handlers for events
  = succeed(Handle handle)
  | targetValue(Handle handle)
  | targetChecked(Handle handle)
  ;
  
@doc{Smart constructors for constructing encoded event decoders.}
Hnd succeed(Msg msg) = succeed(encode(msg));

Hnd targetValue(Msg(str) str2msg) = targetValue(encode(str2msg));

Hnd targetChecked(Msg(bool) bool2msg) = targetChecked(encode(bool2msg));

Hnd keyCode(Msg(int) int2msg) = keyCode(encode(int2msg)); 

  
@doc{Convert request parameters to a Msg value. Active mappers at `path`
transform the message according to f.}
Msg params2msg(map[str, str] params) 
  = msgParsers[params["type"]](toHandle(params), params);

void msgParser(str typ, Msg(Handle, map[str,str]) parser) {
  msgParsers[typ] = parser;
}

@doc{Parse request parameters into a Handle.}
Handle toHandle(map[str, str] params)
  = handle(toInt(params["id"]), maps=toMaps(params["maps"] ? ""));

list[int] toMaps(str x) = [ toInt(i) | str i <- split(";", x), i != "" ];

Msg nothingParser(Handle h, map[str, str] p) 
  = applyMaps(h, decode(h.id, #Msg)); 

Msg stringParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h.id, #Msg(str))(p["strVal"]));

Msg booleanParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h.id, #Msg(bool))(p["boolVal"] == true));

Msg integerParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h.id, #Msg(int))(toInt(p["intVal"])));


Msg applyMaps(Handle h, Msg msg) = ( msg | decode(m, #(Msg(Msg)))(it) | int m <- h.maps );

private map[str, Msg(Handle, map[str, str])] msgParsers = (
  "nothing": nothingParser,
  "string": stringParser,
  "boolean": booleanParser,
  "integer": integerParser
);

// MAPPING

private &T withMapper(Msg(Msg) f, &T() block) {
  mappers = [f] + mappers;
  &T result = block();
  mappers = mappers[1..];
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
