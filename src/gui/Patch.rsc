module gui::Patch

import gui::HTML;
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
  = patch(int pos, list[Patch] patches, list[Edit] edits)
  ;

@doc{Primitive edit constructs.}
data Edit
  = setText(str contents)
  | replace(Html html)
  | removeNode() 
  | appendNode(Html html) 
  | setAttr(str name, str val)
  | setProp(str name, str val)
  | setEvent(str name, Decoder decoder)
  | removeAttr(str name)
  | removeProp(str name)
  | removeEvent(str name)
  ; 

@doc{Applying a patch to an Html node; only for testing.}
Html apply(Patch p, Html html) {
  assert any(Edit e <- p.edits, e is replace) ==> p.patches == [];
  
  html = ( html | apply(e, it) | Edit e <- p.edits );
  
  assert p.patches != [] ==> html is element;  
  for (Patch p <- p.patches) {
    assert p.pos < size(html.kids);
    html.kids[p.pos] = apply(p, html.kids[p.pos]);
  }

  return html;
}
  
Html apply(setText(str txt), txt(_)) = txt(txt);
Html apply(replace(Html html), _) = html;
Html apply(appendNode(Html html), Html e) = e[kids=e.kids + [html]];
Html apply(removeNode(), Html e) = e[kids = e.kids[..-1]];
Html apply(removeAttr(str name), Html html) = html[attrs=delete(html.attrs, name)];
Html apply(removeProp(str name), Html html) = html[props=delete(html.props, name)];
Html apply(removeEvent(str event), Html html) = html[events=delete(html.events, name)];
Html apply(setAttr(str name, str val), Html html) = html[attrs = html.attrs + (name: val)];
Html apply(setProp(str name, str val), Html html) = html[props = html.props + (name: val)];
Html apply(setEvent(str event, Decoder dec), Html html) = html[events = html.events + (event: dec)];

