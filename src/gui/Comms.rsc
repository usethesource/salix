module gui::Comms

import gui::Encode;
import Type;
import List;
import String;

data Msg;

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
  = applyMaps(h, decode(h.id, #Msg(str))(p["string"]));

Msg booleanParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h.id, #Msg(bool))(p["boolVal"] == true));

Msg integerParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h.id, #Msg(int))(toInt(params["intVal"])));


Msg applyMaps(Handle h, Msg msg) = ( msg | decode(m, #(Msg(Msg)))(it) | int m <- h.maps );

public /*const*/ Mapping mapping = gui::Encode::mapping;

private map[str, Msg(Handle, map[str, str])] msgParsers = (
  "nothing": nothingParser,
  "string": stringParser,
  "boolean": booleanParser,
  "integer": integerParser
);

