module gui::Diff

import gui::HTML;
import gui::Patch;
import Node;
import List;
import util::Math;

bool sanity(Html h1, Html h2) = apply(diff(h1, h2), h1) == h2;

Patch diff(Html old, Html new) = diff(old, new, -1);

Patch diff(Html old, Html new, int idx) {
  if (getName(old) != getName(new)) {
    return patch(idx, [], [replace(new)]);
  }
  
  if (old is txt) {
    if (old.contents != new.contents) {
      return patch(idx, [], [setText(new.contents)]);
    }
    return patch(idx, [], []);
  }
  
  if (old is element, old.tagName != new.tagName) {
    return patch(idx, [], [replace(new)]);
  }

  // same kind of elements
  edits = diffMap(old.attrs, new.attrs, setAttr, removeAttr)
    + diffMap(old.props, new.props, setProp, removeProp)  
    + diffMap(old.events, new.events, setEvent, removeEvent);
  
  return diffKids(old.kids, new.kids, patch(idx, [], edits));
}

Patch diffKids(list[Html] oldKids, list[Html] newKids, Patch myPatch) {
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


list[Edit] diffMap(map[str, &T] old, map[str, &T] new, Edit(str, &T) upd, Edit(str) del) {
  edits = for (k <- old) {
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

