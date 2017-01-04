module salix::Core

import salix::Node;

import List;
import String;
import IO;

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


/*
 * Encoding/decoding
 */
 
// the "current" top-level view; set by render
private value viewContext; 

// a bidirectional map from values (functions) to ints, with an id counter.
alias Encoding = tuple[int id, map[int, value] from, map[value, int] to]; 

alias RenderState = map[value viewContext, Encoding encoding];

private RenderState state = (); 

private void initViewContext(void(&T) view) {
  viewContext = view;
  // NB: don't initialize to empty, because subs/commands also
  // might change the encoding table during `update`.
  value x = view; // workaround bug.
  if (x notin state) {
    state[x] = <0, (), ()>;
  }
}
 
 // encode functions (for handlers) as integers
private int _encode(value x) {
  Encoding enc = state[viewContext];
  if (x notin enc.to) {
    enc.id += 1;
    enc.from[enc.id] = x;
    enc.to[x] = enc.id;
    state[viewContext] = enc; 
  }
  return enc.to[x];
}

// retrieve the actual function corresponding to a handle identity.
private &U _decode(int id, type[&U] t) = d
  when
    &U d := state[viewContext].from[id];


@doc{The stack of active msg transformers at some point during rendering.}
private list[Msg(Msg)] mappers = [];

// `encode` encodes its argument and all active mappers into a handle.
Handle encode(value x)
  = handle(_encode(x), maps=[ _encode(f) | Msg(Msg) f <- mappers ]);

&T decode(Handle h, type[&T] t) = decode(h.id, t); 

&T decode(int id, type[&T] t) = _decode(id, t); 

/*
 * Rendering
 */
 
@doc{The html element stack used during rendering.}
private list[list[Node]] stack = [];

@doc{Basic stack management functions.}
private void add(Node h) = push(pop() + [h]);

private void push(list[Node] l) { stack += [l]; }

private list[Node] top() = stack[-1];

private list[Node] pop() {
  list[Node] elts = top();
  stack = stack[..-1];
  return elts;
}


@doc{Render turns void returning views for a model &T into an Node node.}  
Node render(&T model, void(&T) block) {
  //println("Rendering <model> through <block>");
  initViewContext(block);
  push([]); 
  block(model);
  // TODO: throw exception if top is empty or
  // size > 1
  return pop()[0];
}


@doc{The basic build function to construct html elements on the stack.
The list of argument values can contain any number of Attr values.
The last argument (if any) can be a block, an Node node, or a value.
In the latter case it is converted to a txt node.}
void build(list[value] vals, Node(list[Node], list[Attr]) elt) {
  
  push([]); // start a new scope for this element's children
  
  if (vals != []) { 
    if (void() block := vals[-1]) { // argument block is just called
      block();
    }
    else if (Node h := vals[-1]) { // a computed node is simply added
      add(h);
    }
    else if (Attr _ !:= vals[-1]) { // else (if not Attr), render as text.
      _text(vals[-1]);
    }
  }
  
  // construct the `elt` using the kids at the top of the stack
  // and any attributes in vals and add it to the parent's list of children.
  add(elt(pop(), [ a | Attr a <- vals ]));
  
}

@doc{Create a text node from an arbitrary value.}
void _text(value v) = add(txt("<v>")); // TODO: HTML encode.


/*
 * Subscriptions and commands
 */

 
@doc{Subs are like events: they are sent to JS, and Results are sent back.}
data Sub // Subscriptions
  = timeEvery(Handle handle, int interval)
  ;

@doc{Smart constructors for constructing encoded subscriptions.}
Sub timeEvery(Msg(int) int2msg, int interval)
  = timeEvery(encode(int2msg), interval);

alias Subs[&T] = list[Sub](&T);

list[Sub] noSubs(&T t) = [];


@doc{Commands represent actions that need to be performed at the client.}
data Cmd  // Commands
  = random(Handle handle, int from, int to)
  | none()
  ;
  
@doc{Smart constructors for constructing encoded commands.}
Cmd random(Msg(int) f, int from, int to)
  = random(encode(f), from, to);

alias WithCmd[&T] = tuple[&T model, Cmd command];  

// functions to hide the representation of WithCmd.
WithCmd[&T] noCmd(&T model) = <model, none()>;
WithCmd[&T] withCmd(&T model, Cmd cmd) = <model, cmd>;


/*
 * Event decoders
 */

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

/*
 * Message parsing
 */  
  
@doc{Convert request parameters to a Msg value. Active mappers at `path`
transform the message according to f.}
Msg params2msg(map[str, str] params) 
  = msgParsers[params["type"]](toHandle(params), params);

@doc{Register a message parser for type `typ`.}
void msgParser(str typ, Msg(Handle, map[str,str]) parser) {
  msgParsers[typ] = parser;
}

@doc{Parse request parameters into a Handle.}
Handle toHandle(map[str, str] params)
  = handle(toInt(params["id"]), maps=toMaps(params["maps"] ? ""));

list[int] toMaps(str x) = [ toInt(i) | str i <- split(";", x), i != "" ];

Msg nothingParser(Handle h, map[str, str] p) 
  = applyMaps(h, decode(h, #Msg)); 

Msg stringParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h, #Msg(str))(p["strVal"]));

Msg booleanParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h, #Msg(bool))(p["boolVal"] == true));

Msg integerParser(Handle h, map[str,str] p) 
  = applyMaps(h, decode(h, #Msg(int))(toInt(p["intVal"])));


Msg applyMaps(Handle h, Msg msg) = ( msg | decode(m, #(Msg(Msg)))(it) | int m <- h.maps );

private map[str, Msg(Handle, map[str, str])] msgParsers = (
  "nothing": nothingParser,
  "string": stringParser,
  "boolean": booleanParser,
  "integer": integerParser
);

/*
 * Mapping
 */

private &T withMapper(Msg(Msg) f, &T() block) {
  // NB: prepend f to mappers, not append to get appropriate innermost mapping order.
  mappers = [f] + mappers;
  &T result = block();
  mappers = mappers[1..];
  return result;
}

// bug: if same name as other mapped, if calling the other
// it can call this one...
list[Sub] mapSubs(Msg(Msg) f, &T t, list[Sub](&T) subs) 
  = withMapper(f, list[Sub]() { return subs(t); });

tuple[&T,Cmd] mapCmd(Msg(Msg) f, Msg msg, &T t, tuple[&T, Cmd](Msg, &T) upd) 
  = withMapper(f, tuple[&T, Cmd]() { return upd(msg, t); });

@doc{Record mapper to transform messages produced in block according f.}
void mapView(Msg(Msg) f, &T t, void(&T) block) { 
   withMapper(f, value() { block(t); return 0; });
}

// Some debugging utils

void _reset() {
  state = ();
  mappers = [];
  stack = [];
}

bool _printState() {
  println("Function table for <viewContext>: ");
  for (int k <- state[viewContext].from) {
    print("  <k>: ");
    println(state[viewContext].from[k]);
  }
  return true;
}

