@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::Diff

import salix::Node;
import salix::Patch;
import Node;
import List;
import util::Math;

bool sanity(Node h1, Node h2) = apply(diff(h1, h2), h1) == h2;

Patch diff(Node old, Node new) = diff(old, new, -1);

Patch diff(Node old, Node new, int idx) {
  if (old is empty) {
    return patch(idx, edits = [replace(new)]);
  }

  if (getName(old) != getName(new)) {
    return patch(idx, edits = [replace(new)]);
  }
  
  if (old is txt, new is txt) {
    if (old.contents != new.contents) {
      return patch(idx, edits = [setText(new.contents)]);
    }
    return patch(idx);
  }
  
  if (old is native, new is native) {
    edits = diffMap(#str, old.props, new.props, setProp, removeProp)
      + diffMap(#str, old.attrs, new.attrs, setAttr, removeAttr)
      + diffEventMap(old.events, new.events)
      + diffMap(#value, old.extra, new.extra, setExtra, removeExtra);
    if (old.id != new.id) {
      edits += setProp("id", new.id);
    }
    return patch(idx, edits = edits);  
  }
  
  if (old is element, old.tagName != new.tagName) {
    return patch(idx, edits = [replace(new)]);
  }

  // same kind of elements
  edits = diffMap(#str, old.attrs, new.attrs, setAttr, removeAttr)
    + diffMap(#str, old.props, new.props, setProp, removeProp)  
    + diffEventMap(old.events, new.events);
  
  return diffKids(old.kids, new.kids, patch(idx, edits = edits));
}

Patch diffKids(list[Node] oldKids, list[Node] newKids, Patch myPatch) {
  oldLen = size(oldKids);
  newLen = size(newKids);
  
  for (int i <- [0..min(oldLen, newLen)]) {
    Patch p = diff(oldKids[i], newKids[i], i);
    if (p.edits != [] || p.patches != []) {
      myPatch.patches += [p];
    }
  }
  
  myPatch.edits += oldLen <= newLen
      ? [ appendNode(newKids[i]) | int i <- [oldLen..newLen] ]
      : [ removeNode() | int _ <- [newLen..oldLen] ];
  
  return myPatch;
}


// something goes wrong with parameterized function type and binding them to constructors.
list[Edit] diffEventMap(map[str, Hnd] old, map[str, Hnd] new) {
  edits = for (str k <- old) {
    if (k in new) {
      if (new[k] != old[k]) {
        append setEvent(k, new[k]);
      }
    }
    else {
      append removeEvent(k);
    }
  }
  edits += [ setEvent(k, new[k]) | k <- new, k notin old ];
  return edits;
} 


list[Edit] diffMap(type[&T] _, map[str, &T] old, map[str, &T] new, Edit(str, &T) upd, Edit(str) del) {
  edits = for (str k <- old) {
    if (k in new) {
      if (new[k] != old[k]) {
        append upd(k, new[k]);
      }
    }
    else {
      append del(k);
    }
  }
  edits += [ upd(k, new[k]) | k <- new, k notin old ];
  return edits;
} 

