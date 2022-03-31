@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::todomvc::TodoMVC

import salix::HTML;
import salix::Node;
import salix::Core;
import salix::App;
import salix::Index;

import List;

/*
 * Not supported yet:
 * - focus (cmds)
 * - persistence
 * - routing?
 * - keyed elements
 *
 * Note: directly ported from todomvc in elm (https://github.com/evancz/elm-todomvc)
 */

// The full application state of our todo app.
alias Model = tuple[list[Entry] entries, str field, int uid, str visibility];

alias Entry = tuple[str description, bool completed, bool editing, int id];

SalixApp[Model] todoMVCApp(str id = "todoMVC") 
  = makeApp(id, emptyModel, withIndex("TodoMVC", id, view, css = ["/salix/demo/todomvc/style.css"]), update); 
 

App[Model] todoMVCWebApp() 
  = webApp(
      todoMVCApp(), 
      |project://salix/src/salix/demo/todomvc/todomvc.html|, 
      |project://salix/src|
    );
  
Model emptyModel() = <[], "", 0, "All">;

Entry newEntry(str desc, int id) = <desc, false, false, id>;

// UPDATE

data Msg
  = noOp()
  | updateField(str x)
  | editingEntry(int id, bool editing)
  | updateEntry(int id, str desc)
  | add()
  | delete(int id)
  | deleteComplete()
  | check(int id, bool checked)
  | checkAll(bool checked)
  | changeVisibility(str filt)
  ;

Msg(str) updateEntry(int id) = Msg(str x) { return updateEntry(id, x); };

Model update(Msg msg, Model model) {
  switch (msg) {
    case noOp(): 
      ;
      
    case add(): {
      if (model.field != "") {
        model.uid += 1;
        model.entries += [newEntry(model.field, model.uid)];
        model.field = "";
      }
    }

    case updateField(str s):
      model.field = s;

    case editingEntry(int id, bool isEditing): 
      if (int i <- [0..size(model.entries)], model.entries[i].id == id) {
        model.entries[i].editing = isEditing;
      }
         //batch([attempt(Msg(value x) { return noOp(); }, focus /* ??? */)])>;
         
    case updateEntry(int id, str task): 
      if (int i <- [0..size(model.entries)], model.entries[i].id == id) {
        model.entries[i].description = task;
      }
     
    case delete(int id):
      model.entries = [ e | Entry e <- model.entries, e.id != id ];
       
    case deleteComplete():
      model.entries =  [ e | Entry e <- model.entries, !e.completed ];

    case check(int id, bool isCompleted):
      if (int i <- [0..size(model.entries)], model.entries[i].id == id) {
        model.entries[i].completed = isCompleted;
      }
      
    case checkAll(bool isCompleted): 
      model.entries = [ e[completed=isCompleted] | Entry e <- model.entries ];
  
    case changeVisibility(str visibility):
      model.visibility = visibility;
  }
  
  return model;
} 

// VIEW

void view(Model model) {
  div(class("todomvc-wrapper"), style(<"visibility", "hidden">), () {
    section(class("todoapp"), () {
      viewInput(model.field);
      viewEntries(model.visibility, model.entries);
      viewControls(model.visibility, model.entries);
    });
    infoFooter();
  });
}

void viewInput(str task) {
  header(class("header"), () {
    h1("todos");
    input(class("new-todo"), 
      placeholder("What needs to be done?"),
      autofocus(true),
      \value(task),
      name("newTodo"),
      onInput(updateField),
      onEnter(add()));
  });
}

Attr onEnter(Msg msg) = onKeyDown(Msg (int key) {
  if (key == 13) {
    return msg;
  }
  return noOp();
});

// VIEW ALL ENTRIES

void viewEntries(str visibility, list[Entry] entries) {
  bool isVisible(Entry todo) = todo.completed
    when visibility == "Completed";

  bool isVisible(Entry todo) = !todo.completed
    when visibility == "Active";
  
  default bool isVisible(Entry _) = true;
  
  bool allCompleted = all(e <- entries, e.completed);
  
  str cssVisibility = entries == [] ? "hidden" : "visible";
  
  section(class("main"), style(<"visibility", cssVisibility>), () {
  
    input(class("toggle-all"), 
      \type("checkbox"), name("toggle"), checked(allCompleted),
      onClick(checkAll(!allCompleted)));
  
    label(\for("toggle-all"), "Mark all as complete");
  
    ul(class("todo-list"), () {
      for (Entry e <- entries, isVisible(e)) {
        viewEntry(e);
      }
    });
  
  });
  
}

// VIEW INDIVIDUAL ENTRIES

void viewEntry(Entry todo) {
  li(classList(<"completed", todo.completed>, <"editing", todo.editing>), () {
    div(class("view"), () {
      input(class("toggle"), \type("checkbox"), checked(todo.completed),
        onClick(check(todo.id, !todo.completed)));
        
      label(onDoubleClick(editingEntry(todo.id, true)), todo.description);
      
      button(class("destroy"), onClick(delete(todo.id)));
    });
    
    input(class("edit"), \value(todo.description), name("title"),
      id("todo-<todo.id>"), onInput(updateEntry(todo.id)),
      onBlur(editingEntry(todo.id, false)),
      onEnter(editingEntry(todo.id, false)));
  });
}

// VIEW CONTROLS AND FOOTER

void viewControls(str visibility, list[Entry] entries) {
  entriesCompleted = size([ e | e <- entries, e.completed ]);
  entriesLeft = size(entries) - entriesCompleted;
  
  footer(class("footer"), hidden(entries == []), () {
    viewControlsCount(entriesLeft);
    viewControlsFilters(visibility);
    viewControlsClear(entriesCompleted);
  });
}  

void viewControlsCount(int entriesLeft) {
  str item = entriesLeft == 1 ? " item" : " items";
  span(class("todo-count"), () {
    strong("<entriesLeft>");
    text("<item> left");
  });
}

void viewControlsFilters(str visibility) {
  ul(class("filters"), () {
    visibilitySwap("#/", "All", visibility);
    visibilitySwap("#/active", "Active", visibility);
    visibilitySwap("#/completed", "Completed", visibility);
  });
}

void visibilitySwap(str uri, str visibility, str actualVisibility) {
  li(onClick(changeVisibility(visibility)), () {
    a(href(uri), classList(<"selected", visibility == actualVisibility>), visibility);
  });
}

void viewControlsClear(int entriesCompleted) {
  button(class("clear-completed"), hidden(entriesCompleted == 0),
    onClick(deleteComplete()), "Clear completed (<entriesCompleted>)");
}

void infoFooter() {
  footer(class("info"), () {
    p("Double-click to edit a todo");
    p(() {
      text("Written by ");
      a(href("http://www.cwi.nl~/storm"), "Tijs van der Storm");
      text(", transcribed from ");
      a(href("https://github.com/evancz/elm-todomvc"), "Evan\'s version in Elm");
    });
    p(() {
      text("Based on ");
      a(href("http://todomvc.com"), "TodoMVC");
    });
  });
}

