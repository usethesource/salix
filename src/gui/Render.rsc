module gui::Render

/*
 * NB: as of now, this module cannot be extended, since the global
 * variables will be copied; this leads to strange results if
 * different modules use different globals... 
 *
 * We need the globals, however, because we don't want to pass any
 * extra data to the user functions h1/h2/... etc. The only limitation
 * is thus that case-based functions in this module cannot be extended.
 * Adding new element functions, or even element constructors is fine.
 */

@doc{This is the basic Message data type that clients
will extend with concrete constructors.

Note, that instead of make Html parametric on Msg (Html[&Msg])
we use a single type and ADT extension. This decision makes
a lot of code slightly less verbose, but sacrifices additional
type checking when nesting components.}
data Msg;

// TODO: Html -> Node (as it also represents SVG)

@doc{The basic Html node type, defining constructors for
elements, text nodes, and native nodes (which are managed in js).}
data Html
  = element(str tagName, list[Html] kids, map[str, str] attrs, map[str, str] props, map[str, Decoder] events)
  // TODO: native should additional have arbitrary data...
  | native(str kind, str key, map[str, str] attrs, map[str, str] props, map[str, Decoder] events)
  | txt(str contents)
  ;  
  

@doc{Generalized attributes to be produced by explicit attribute construction
functions (such as class(str), onClick(Msg), or \value(str)).
null() acts as a zero element and is always ignored.}
data Attr
  = attr(str name, str val)
  | prop(str name, str val)
  | event(str name, Decoder decoder, map[str,str] options = ())
  | null()
  ;

// TODO: keyed elements 

@doc{Handles represent (encoded) functions to decode events.}
data Handle
  = handle(str path, int id);

@doc{Decoders represent functions to decode event types and data.
Here they are represented without functions, but using Handles
so that they can be serialized to JSON.}
data Decoder
  = succeed(Handle handle)
  | targetValue(Handle handle)
  | targetChecked(Handle handle)
  | oneKeyCode(Handle handle, int keyCode = -1)
  | cursorActivity(Handle handle)
  | change(Handle handle)
  ;

@doc{The encoding interface between an App and this library.
An app needs to set this variable to its encapsulated encoder before
rendering. This ensures that encoding is relative to app and not global.

Encoding produces handles for arbitrary values, at some path,
recording the list of active message transformers at the moment of call.} 
public Handle(value, str, list[Msg(Msg)]) _encode;

@doc{The html element stack used during rendering.}
private list[list[Html]] stack = [];

@doc{Basic stack management functions.}
private void add(Html h) = push(pop() + [h]);

private void push(list[Html] l) { stack += [l]; }

private list[Html] top() = stack[-1];

private list[Html] pop() {
  list[Html] elts = top();
  stack = stack[..-1];
  return elts;
}

@doc{The stack of active msg transformers at some point during rendering.}
public list[Msg(Msg)] mappers = [];

@doc{Compute the current path as a string from the stack.}
str currentPath() = intercalate("_", [ size(l) | list[Html] l <- stack ]);

@doc{Smart constructors for constructing encoded event decoders.}
Decoder succeed(Msg msg) = succeed(_encode(msg, currentPath(), mappers));

Decoder targetValue(Msg(str) str2msg) = targetValue(_encode(str2msg, currentPath(), mappers));

Decoder targetChecked(Msg(bool) bool2msg) = targetChecked(_encode(bool2msg, currentPath(), mappers));

Decoder keyCode(Msg(int) int2msg) = keyCode(_encode(int2msg, currentPath(), mappers)); 

Decoder oneKeyCode(int keyCode, Msg(int) int2msg) 
  = oneKeyCode(_encode(int2msg, currentPath(), mappers), keyCode = keyCode); 
  
Decoder cursorActivity(Msg(int, int, int, str, str) token2msg) 
  = cursorActivity(_encode(token2msg, currentPath(), mappers));

Decoder change(Msg(int, int, int, int, str, str) ch2msg) 
  = change(_encode(ch2msg, currentPath(), mappers));


@doc{Helper functions to partition list of Attrs into attrs, props and events} 
map[str,str] attrsOf(list[Attr] attrs) = ( k: v | attr(str k, str v) <- attrs );

map[str,str] propsOf(list[Attr] attrs) = ( k: v | prop(str k, str v) <- attrs );

map[str,Decoder] eventsOf(list[Attr] attrs) = ( k: v | event(str k, Decoder v) <- attrs );


@doc{Render turns void returning views for a model &T into an Html node.}  
Html render(&T model, void(&T) block) {
  push([]); 
  block(model);
  return pop()[0];
}

@doc{Record mapper to transform messages produced in block according f.}
void mapped(Msg(Msg) f, &T t, void(&T) block)
  = mapped(f, void() { block(t); });

void mapped(Msg(Msg) f, void() block) {
  mappers += [f];
  block();
  mappers = mappers[..-1];
}

@doc{The basic build function to construct html elements on the stack.
The list of argument values can contain any number of Attr values.
The last argument (if any) can be a block, an Html node, or a value.
In the latter case it is converted to a txt node.}
void build(list[value] vals, Html(list[Html], list[Attr]) elt) {
  
  push([]); // start a new scope for this elements children
  
  if (vals != []) { 
    if (void() block := vals[-1]) { // argument block is just called
      block();
    }
    else if (Html h := vals[-1]) { // a computed node is simply added
      add(h);
    }
    else if (Attr _ !:= vals[-1]) { // else (if not Attr), render as text.
      text(vals[-1]);
    }
  }
  
  // construct the `elt` using the kids at the top of the stack
  // and any attributes in vals and add it to the parent's list of children.
  add(elt(pop(), [ a | Attr a <- vals ]));
  
}


@doc{Create a text node.}
void text(value v) = add(txt("<v>")); // TODO: HTML encode.
