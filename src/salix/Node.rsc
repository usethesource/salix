module salix::Node

import List;
import String;
import IO;


// TODO: make attrs/props/events kw params to save memory
// TODO: make attrs map[str, Attribute] to deal with namespaces

@doc{The basic Html node type, defining constructors for
elements, text nodes, and native nodes (which are managed in js).}
data Node
  = element(str tagName, list[Node] kids, map[str, str] attrs, map[str, str] props, map[str, Hnd] events)
  // Natives don't have attrs, since we don't manage the DOM for it;
  // properties are handled however the internals wish to.
  | native(str kind, map[str, str] props, map[str, Hnd] events, map[str,value] extra = ())
  | txt(str contents)
  ;  

@doc{An abstract type for represent event handlers.}
data Hnd;  

@doc{Generalized attributes to be produced by explicit attribute construction
functions (such as class(str), onClick(Msg), or \value(str)).
null() acts as a zero element and is always ignored.}
data Attr
  = attr(str name, str val)
  | prop(str name, str val)
  | event(str name, Hnd handler, map[str,str] options = ())
  | null()
  ;

// TODO: keyed elements 

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


@doc{Helper functions to partition list of Attrs into attrs, props and events} 
map[str,str] attrsOf(list[Attr] attrs) = ( k: v | attr(str k, str v) <- attrs );

map[str,str] propsOf(list[Attr] attrs) = ( k: v | prop(str k, str v) <- attrs );

map[str,Hnd] eventsOf(list[Attr] attrs) = ( k: v | event(str k, Hnd v) <- attrs );


@doc{Render turns void returning views for a model &T into an Node node.}  
Node render(&T model, void(&T) block) {
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

@doc{Create a text node.}
void _text(value v) = add(txt("<v>")); // TODO: HTML encode.


