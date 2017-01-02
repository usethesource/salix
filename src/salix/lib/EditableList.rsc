module salix::lib::EditableList

import salix::HTML;
import salix::Core;
import List;
import IO;

alias ListModel[&T]
  = tuple[list[&T] lst, &T(Msg, &T) update, &T(int) init];
  
data Msg
  = moveUp(int i)
  | moveDown(int i)
  | delete(int i)
  | insertAt(int i) 
  | elemMsg(int i, Msg msg)
  ;

Msg(Msg) toSub(int i) = Msg(Msg msg) { return elemMsg(i, msg); };

void listView(ListModel[&T] m, void(&T) display) {
  div(() {
    ul(() {
      if (m.lst == []) {
        button(onClick(insertAt(0)), "+");
      }
      for (int i <- [0..size(m.lst)]) {
        li(() {
          mapping.view(toSub(i), m.lst[i], display);
          if (i > 0) {
            button(onClick(moveUp(i)), "^");
          }
          if (i < size(m.lst) - 1) {
            button(onClick(moveDown(i)), "v");
          }
          button(onClick(delete(i)), "-");
          button(onClick(insertAt(i)), "+");
        });
      }
    });
  });
}


ListModel[&T] editList(moveUp(int i), ListModel[&T] m) {
  &T t = m.lst[i];
  m.lst = delete(m.lst, i);
  return m[lst = insertAt(m.lst, i - 1, t)];
}
  
ListModel[&T] editList(moveDown(int i), ListModel[&T] m) {
  &T t = m.lst[i];
  m.lst = delete(m.lst, i);
  return m[lst = insertAt(m.lst, i + 1, t)];
}

ListModel[&T] editList(delete(int i), ListModel[&T] m)
  = m[lst = delete(m.lst, i)];
  
ListModel[&T] editList(insertAt(int i), ListModel[&T] m)
  = m[lst = insertAt(m.lst, i, m.init(i))];
  
ListModel[&T] editList(elemMsg(int i, Msg msg), ListModel[&T] m)
  = m[lst = m.lst[0..i] + [m.update(msg, m.lst[i])] + m.lst[i+1..]];
  
  
  