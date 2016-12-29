module gui::Decode

import gui::Render;
import Type;
import List;
import String;


@doc{This is the basic Message data type that clients
will extend with concrete constructors.

Note, that instead of make Html parametric on Msg (Html[&Msg])
we use a single type and ADT extension. This decision makes
a lot of code slightly less verbose, but sacrifices additional
type checking when nesting components.}
data Msg;


@doc{Handles represent (encoded) functions to decode events.}
data Handle
  = handle(str path, int id);

@doc{Subs are like events: they are sent to JS, and Results are sent back.}
data Sub // Subscriptions
  = timeEvery(Handle handle, int interval)
  ;

alias Subs = list[Sub];

@doc{Smart constructors for constructing encoded subscriptions.}
Sub timeEvery(Msg(int) int2msg, int interval)
  = timeEvery(encode(int2msg), interval);

@doc{Commands represent actions that need to be performed at the client.}
data Cmd  // Commands
  = random(Handle handle, int from, int to)
  ;
  
alias WithCmds[&T] = tuple[&T model, list[Cmd] commands];  
  
@doc{Smart constructors for constructing encoded commands.}
Cmd random(Msg(int) f, int from, int to)
  = random(encode(f), from, to);

@doc{Handlers are what is sent to the client for handling user events.}
data Hnd // Handlers for events
  = succeed(Handle handle)
  | targetValue(Handle handle)
  | targetChecked(Handle handle)
  ;
  
@doc{Smart constructors for constructing encoded event decoders.}
Hnd succeed(Msg msg) = Hnd::succeed(encode(msg));

Hnd targetValue(Msg(str) str2msg) = targetValue(encode(str2msg));

Hnd targetChecked(Msg(bool) bool2msg) = targetChecked(encode(bool2msg));

Hnd keyCode(Msg(int) int2msg) = keyCode(encode(int2msg)); 

data Result // what comes back from the client (either from Cmd/Hnd/Sub
  = nothing(Handle handle)
  | string(Handle handle, str strVal)
  | boolean(Handle handle, bool boolVal)
  | integer(Handle handle, int intVal) 
  ;
  
@doc{The encoding interface between an App and this library.
An app needs to set this variable to its encapsulated encoder before
rendering. This ensures that encoding is relative to app and not global.

Encoding produces handles for arbitrary values, at some path,
recording the list of active message transformers at the moment of call.} 
public Handle(value, str, list[Msg(Msg)]) _encode;

@doc{Smart constructors for handlers, commands or subscriptions use encode}
Handle encode(value x) = _encode(x, currentPath(), currentMappers());


@doc{Convert request parameters to a Msg value. Active mappers at `path`
transform the message according to f.}
Msg params2msg(map[str, str] params, Msg(str, Msg) f, &T(Handle,type[&T]) dec) 
  = f(params["path"], toMsg(toResult(params), dec));

@doc{Construct a Result value from the request parameters.}
Result toResult(map[str, str] params) = toResult(params["type"], params);
  
Result toResult("nothing", map[str, str] p) = nothing(toHandle(p));

Result toResult("string", map[str, str] p) = string(toHandle(p), p["strVal"]);

Result toResult("boolean", map[str, str] p) = boolean(toHandle(p), p["boolVal"] == true);

Result toResult("integer", map[str, str] p) = integer(toHandle(p), toInt(p["intVal"]));


@doc{Parse request parameters into a Handle.}
Handle toHandle(map[str, str] params)
  = handle(params["path"], toInt(params["id"]));


@doc{Convert Results to actual messages by applying the functions
returned by the decoder dec, based on the handle.}
Msg toMsg(nothing(Handle h), &T(Handle,type[&T]) dec) = dec(h, #Msg);

Msg toMsg(string(Handle h, str s), &T(Handle,type[&T]) dec) = dec(h, #Msg(str))(s);

Msg toMsg(boolean(Handle h, bool b), &T(Handle,type[&T]) dec) = dec(h, #Msg(bool))(b);

           
// MAPPING

@doc{The stack of active msg transformers at some point during rendering.}
private list[Msg(Msg)] mappers = [];

list[Msg(Msg)] currentMappers() = mappers;


private &T withMapper(Msg(Msg) f, &T() block) {
  mappers += [f];
  &T result = block();
  mappers = mappers[..-1];
  return result;
}

// bug: if same name as other mapped, if calling the other
// it can call this one...
private list[Sub] mappedSubs(Msg(Msg) f, &T t, list[Sub](&T) subs) 
  = withMapper(f, list[Sub]() { return subs(t); });

@doc{Record mapper to transform messages produced in block according f.}
private void mapped(Msg(Msg) f, &T t, void(&T) block) { 
   withMapper(f, value() { block(t); return 0; });
}

alias Mapping = tuple[
  list[Sub](Msg(Msg), &T, list[Sub](&T)) subs,
  void(Msg(Msg), &T, void(&T)) view
];

public /*const*/ Mapping mapping = <mappedSubs, mapped>;
