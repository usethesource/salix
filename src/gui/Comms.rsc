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

alias Subs = list[Sub];

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

data Result // what comes back from the client (either from Cmd/Hnd/Sub
  = nothing(Handle handle)
  | string(Handle handle, str strVal)
  | boolean(Handle handle, bool boolVal)
  | integer(Handle handle, int intVal) 
  ;
  
@doc{Convert request parameters to a Msg value. Active mappers at `path`
transform the message according to f.}
Msg params2msg(map[str, str] params, Msg(str, Msg) f) 
  = f(params["path"], toMsg(toResult(params)));

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
Msg toMsg(nothing(Handle h)) = decode(h, #Msg);

Msg toMsg(string(Handle h, str s)) = decode(h, #Msg(str))(s);

Msg toMsg(boolean(Handle h, bool b)) = decode(h, #Msg(bool))(b);

Msg toMsg(integer(Handle h, int i)) = decode(h, #Msg(int))(i);

           
