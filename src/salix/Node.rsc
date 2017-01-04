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
  // TODO:
  | shadow(list[Node] kids, map[str, str] attrs, map[str, str] props, map[str, Hnd] events)
  | txt(str contents)
  | empty() 
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


@doc{Helper functions to partition list of Attrs into attrs, props and events} 
map[str,str] attrsOf(list[Attr] attrs) = ( k: v | attr(str k, str v) <- attrs );

map[str,str] propsOf(list[Attr] attrs) = ( k: v | prop(str k, str v) <- attrs );

map[str,Hnd] eventsOf(list[Attr] attrs) = ( k: v | event(str k, Hnd v) <- attrs );


