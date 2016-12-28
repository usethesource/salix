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

@doc{Handlers are what is sent to the client for handling user events.}
data Hnd // Handlers for events
  = succeed(Handle handle)
  | targetValue(Handle handle)
  | targetChecked(Handle handle)
  | change(Handle handle)
  ;
  
@doc{Smart constructors for constructing encoded event decoders.}
Hnd succeed(Msg msg) = Hnd::succeed(encode(msg));

Hnd targetValue(Msg(str) str2msg) = targetValue(encode(str2msg));

Hnd targetChecked(Msg(bool) bool2msg) = targetChecked(encode(bool2msg));

Hnd keyCode(Msg(int) int2msg) = keyCode(encode(int2msg)); 

Hnd change(Msg(int, int, int, int, str, str) ch2msg) 
  = change(encode(ch2msg));
  
// Every Cmd/Hnd/Sub has to have a corresponding Result constructor:

data Result // what comes back from the client (either from Cmd/Hnd/Sub
  = succeed(Handle handle)
  | targetValue(Handle handle, str \value)
  | targetChecked(Handle handle, bool checked)
  | change(Handle handle, int fromLine, int fromCol, int toLine, int toCol, str text, str removed)
  | timeEvery(Handle handle, int time) // from Sub
  | random(Handle handle, int random)  // from Cmd
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

// FROM req.params TO Result

@doc{Construct a Result value from the request parameters.}
Result toResult(map[str, str] params)
  = toResult(params["type"], params);
  
Result toResult("succeed", map[str, str] params)  
  = Result::succeed(toHandle(params));

Result toResult("targetValue", map[str, str] params)  
  = targetValue(toHandle(params), params["value"]);

Result toResult("targetChecked", map[str, str] params)  
  = targetChecked(toHandle(params), params["checked"] == true);

Result toResult("keyCode", map[str, str] params)  
  = keyCode(toHandle(params), toInt(params["keyCode"]));

Result toResult("change", map[str, str] params)
  = change(toHandle(params), toInt(p["fromLine"]), toInt(p["fromCol"]), 
           toInt(p["toLine"]), toInt(p["toCol"]),
           p["text"], p["removed"]);

Result toResult("timeEvery", map[str, str] params)
  = timeEvery(toHandle(params), toInt(p["time"]));
  
Result toResult("random", map[str, str] params)
  = random(toHandle(params), toInt(p["random"]));

@doc{Parse request parameters into a Handle.}
Handle toHandle(map[str, str] params)
  = handle(params["path"], toInt(params["id"]));


// FROM Result TO Msg

@doc{Convert Results to actual messages by applying the functions
returned by the decoder dec, based on the handle.}
Msg toMsg(Result::succeed(Handle h), &T(Handle,type[&T]) dec) 
  = dec(h, #Msg);

Msg toMsg(targetValue(Handle h, str \value), &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(str))(\value);

Msg toMsg(targetChecked(Handle h, bool checked), &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(bool))(checked);

Msg toMsg(oneKeyCode(Handle h, int keyCode), &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int))(keyCode);

Msg toMsg(change(Handle h, int fromLine, int fromCol, int toLine, int toCol, str text, str removed), &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int, int, int, int, str, str))(fromLine, fromCol, toLine, toCol, text, removed);
           
Msg toMsg(timeEvery(Handle h, int time), map[str, str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int))(time);
 
Msg toMsg(random(Handle h, int random), map[str, str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int))(random);


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
