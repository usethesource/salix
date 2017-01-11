@license{
  Copyright (c) 2016-2017 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::Patch

import salix::Node;
import Map;
import List;
import Node;
import String;

@doc{Patch are positioned at pos in the parent element where
they originate. This allows sparse/shallow traversal during
patching: not all kids of an element will have changes, so
patches for those kids will not end up in the patch at ll.
At each level a list of edits can be applied.
A root patch will have pos - 1.}
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
  | removeAttr(str name)
  | removeProp(str name)
  | removeEvent(str name)
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
  
Node apply(setText(str txt), txt(_)) = txt(txt);
Node apply(replace(Node html), _) = html;
Node apply(appendNode(Node html), Node e) = e[kids=e.kids + [html]];
Node apply(removeNode(), Node e) = e[kids = e.kids[..-1]];
Node apply(removeAttr(str name), Node html) = html[attrs=delete(html.attrs, name)];
Node apply(removeProp(str name), Node html) = html[props=delete(html.props, name)];
Node apply(removeEvent(str event), Node html) = html[events=delete(html.events, name)];
Node apply(setAttr(str name, str val), Node html) = html[attrs = html.attrs + (name: val)];
Node apply(setProp(str name, str val), Node html) = html[props = html.props + (name: val)];
Node apply(setEvent(str event, Hnd h), Node html) = html[events = html.events + (event: h)];

