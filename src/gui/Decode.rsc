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

@doc{Decoders represent functions to decode event and subscription types,
plus additional data.
Here they are represented without functions, but using Handles
so that they can be serialized to JSON.}
data Decoder
  = succeed(Handle handle)
  | targetValue(Handle handle)
  | targetChecked(Handle handle)
  | oneKeyCode(Handle handle, int keyCode = -1)
  | cursorActivity(Handle handle)
  | change(Handle handle)
  | timeEvery(Handle handle) // NB: a decoder of a subscription 
  ;

@doc{Subs are like events, and should contain a decoder...
They are sent to JS, and result in Decoders being sent back.}
data Sub
  = timeEvery(Handle handle, int interval = 1000)
  ;
  
@doc{The encoding interface between an App and this library.
An app needs to set this variable to its encapsulated encoder before
rendering. This ensures that encoding is relative to app and not global.

Encoding produces handles for arbitrary values, at some path,
recording the list of active message transformers at the moment of call.} 
public Handle(value, str, list[Msg(Msg)]) _encode;

Handle encode(value x) = _encode(x, currentPath(), currentMappers());

@doc{The stack of active msg transformers at some point during rendering.}
private list[Msg(Msg)] mappers = [];

list[Msg(Msg)] currentMappers() = mappers;


@doc{Smart constructors for constructing encoded event decoders.}
Decoder succeed(Msg msg) = succeed(encode(msg));

Decoder targetValue(Msg(str) str2msg) = targetValue(encode(str2msg));

Decoder targetChecked(Msg(bool) bool2msg) = targetChecked(encode(bool2msg));

Decoder keyCode(Msg(int) int2msg) = keyCode(encode(int2msg)); 

Decoder oneKeyCode(int keyCode, Msg(int) int2msg) 
  = oneKeyCode(encode(int2msg), keyCode = keyCode); 
  
Decoder cursorActivity(Msg(int, int, int, str, str) token2msg) 
  = cursorActivity(encode(token2msg));

Decoder change(Msg(int, int, int, int, str, str) ch2msg) 
  = change(encode(ch2msg));

@doc{Convert request parameters to a Msg value.
Active mappers at `path`  transform the message according to f.}
Msg params2msg(map[str, str] params, Msg(str, Msg) f, &T(Handle,type[&T]) dec) 
  = f(params["path"], toMsg(toDecoder(params), params, dec));

@doc{Construct a Decoder value from the request parameters.}
Decoder toDecoder(map[str, str] params)
  = make(#Decoder, params["type"], [toHandle(params)], ());

@doc{Parse request parameters into a Handle.}
Handle toHandle(map[str, str] params)
  = handle(params["path"], toInt(params["id"]));


@doc{Convert decoders to actual messages by applying the functions
returned by dec, based on the handle's id.}
Msg toMsg(succeed(Handle h), map[str,str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg);

Msg toMsg(targetValue(Handle h), map[str,str] p, &T(Handle,type[&T]) dec) 
  =  dec(h, #Msg(str))(p["data"]);

Msg toMsg(targetChecked(Handle h), map[str,str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(bool))(p["data"] == "true");

Msg toMsg(oneKeyCode(Handle h), map[str,str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int))(toInt(p["data"]));

Msg toMsg(cursorActivity(Handle h), map[str,str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int, int, int, str, str))(
           toInt(p["line"]), toInt(p["start"]), toInt(p["end"]), p["string"], p["tokenType"]);

Msg toMsg(change(Handle h), map[str,str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int, int, int, int, str, str))(
           toInt(p["fromLine"]), toInt(p["fromCol"]), 
           toInt(p["toLine"]), toInt(p["toCol"]),
           p["text"], p["removed"]);
           
Msg toMsg(timeEvery(Handle h), map[str, str] p, &T(Handle,type[&T]) dec) 
  = dec(h, #Msg(int))(toInt(p["time"]));
 

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
