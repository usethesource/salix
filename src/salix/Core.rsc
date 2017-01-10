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


@doc{Initialize viewContext for an initial model, so that cmds are properly mapped.}
tuple[list[Cmd], &T] initialize(&T() init, void(&T) view) {
  initViewContext(view);
  return execute(init);
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
  = subscription(str name, Handle handle, map[str, value] args = ())
  ;

@doc{Smart constructors for constructing encoded subscriptions.}
Sub timeEvery(Msg(int) int2msg, int interval)
  = subscription("timeEvery", encode(int2msg), args = ("interval": interval));

alias Subs[&T] = list[Sub](&T);

list[Sub] noSubs(&T t) = [];


@doc{Commands represent actions that need to be performed at the client.}
data Cmd  // Commands
  = command(str name, Handle handle, map[str,value] args = ())
  | none()
  ;
 
 
private list[Cmd] commands = []; 

void do(Cmd cmd) {
  commands += [cmd];
}  
  
// the pendant of render, but on init and update
tuple[list[Cmd], &T] execute(Msg msg, &T(Msg, &T) update, &T model) {
  commands = [];
  &T newModel = update(msg, model);
  return <commands, newModel>;
}

tuple[list[Cmd], &T] execute(&T() init) {
  commands = [];
  &T newModel = init();
  return <commands, newModel>;
}
  
@doc{Smart constructors for constructing encoded commands.}
Cmd random(Msg(int) f, int from, int to)
  = command("random", encode(f), args = ("from": from, "to": to));

/*
 * Event decoders
 */

data Hnd // Handlers for events
  = handler(str name, Handle handle, map[str,value] args = ())
  ;
  
/*
 * Message parsing
 */  
  
alias Parser = Msg(str,Handle,map[str,str]);  
  
@doc{Convert request parameters to a Msg value. Active mappers at `path`
transform the message according to f.}
Msg params2msg(map[str, str] params, Parser parse) 
  = parse(params["type"], toHandle(params), params);


@doc{Parse request parameters into a Handle.}
Handle toHandle(map[str, str] params)
  = handle(toInt(params["id"]), maps=toMaps(params["maps"] ? ""));

list[int] toMaps(str x) = [ toInt(i) | str i <- split(";", x), i != "" ];

Msg parseMsg("nothing", Handle h, map[str, str] p) 
  = applyMaps(h, decode(h, #Msg)); 

Msg parseMsg("string", Handle h, map[str,str] p) 
  = applyMaps(h, decode(h, #Msg(str))(p["value"]));

Msg parseMsg("boolean", Handle h, map[str,str] p) 
  = applyMaps(h, decode(h, #Msg(bool))(p["value"] == true));

Msg parseMsg("integer", Handle h, map[str,str] p) 
  = applyMaps(h, decode(h, #Msg(int))(toInt(p["value"])));


Msg applyMaps(Handle h, Msg msg) = ( msg | decode(m, #(Msg(Msg)))(it) | int m <- h.maps );

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

&T mapCmds(Msg(Msg) f, Msg msg, &T t, &T(Msg, &T) upd) 
  = withMapper(f, &T() { return upd(msg, t); });

&T mapCmds(Msg(Msg) f, &T() init) 
  = withMapper(f, init);

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

