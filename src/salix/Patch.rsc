@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::Patch

import salix::Node;
import Map;
import List;
import String; 

@doc{Patch are positioned at pos in the parent element where
they originate. This allows sparse/shallow traversal during
patching: not all kids of an element will have changes, so
patches for those kids will not end up in the patch at all.
At each level a list of edits can be applied.
A root patch will have pos = - 1.}
data Patch
  = patch(int pos, list[Patch] patches = [], list[Edit] edits = [])
  ;

@doc{Primitive edit constructs.}
data Edit
  = setText(str contents)
  | replace(Node html)
  | removeNode() 
  | appendNode(Node html) 
  | setAttr(str name, str val)
  | setProp(str name, str val)
  | setEvent(str name, Hnd handler)
  | setExtra(str name, value \value)
  | removeAttr(str name)
  | removeProp(str name)
  | removeEvent(str name)
  | removeExtra(str name)
  ; 

@doc{Applying a patch to an Node node; only for testing.}
Node apply(Patch p, Node html) {
  assert any(Edit e <- p.edits, e is replace) ==> p.patches == [];
  
  html = ( html | apply(e, it) | Edit e <- p.edits );
  
  assert p.patches != [] ==> html is element;  
  for (Patch p <- p.patches) {
    assert p.pos < size(html.kids);
    html.kids[p.pos] = apply(p, html.kids[p.pos]);
  }

  return html;
}
  
Node apply(setText(str _txt), txt(_)) = txt(_txt);
Node apply(replace(Node html), _) = html;
Node apply(appendNode(Node html), Node e) = e[kids=e.kids + [html]];
Node apply(removeNode(), Node e) = e[kids = e.kids[..-1]];
Node apply(removeAttr(str name), Node html) = html[attrs=delete(html.attrs, name)];
Node apply(removeProp(str name), Node html) = html[props=delete(html.props, name)];
Node apply(removeEvent(str event), Node html) = html[events=delete(html.events, event)];
Node apply(setAttr(str name, str val), Node html) = html[attrs = html.attrs + (name: val)];
Node apply(setProp(str name, str val), Node html) = html[props = html.props + (name: val)];
Node apply(setEvent(str event, Hnd h), Node html) = html[events = html.events + (event: h)];

