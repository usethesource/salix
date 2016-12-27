module examples::TodoMVC

import gui::HTML;
import gui::App;

import util::Maybe;
import List;

/*
 * Not supported yet:
 * - focus (cmds)
 * - persistence
 * - routing?
 * - keyed elements
 */

// The full application state of our todo app.
alias Model = tuple[list[Entry] entries, str field, int uid, str visibility];

alias Entry = tuple[str description, bool completed, bool editing, int id];


App[Model] todoMVC() 
  = app(emptyModel(), view, update, |http://localhost:9180|, |project://elmer/src/examples|);
  
Model emptyModel() = <[], "", 0, "All">;

Entry newEntry(str desc, int id) = <desc, false, false, id>;

alias Cmd[&T] = tuple[void]; // todo;

Model init(nothing()) = emptyModel();
Model init(just(Model m)) = m;

//init savedModel =
// Maybe.withDefault emptyModel savedModel ! []



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

// TODO: we don't have commands yet.

Model update(noOp(), Model model)
  = model;

Model update(add(), Model model)
  = model[uid=model.uid + 1][field=""]
      [entries=model.field == "" 
         ? model.entries 
         : model.entries + [newEntry(model.field, model.uid)]];

Model update(updateField(str s), Model model) = model[field=s];

Model update(editingEntry(int id, bool isEditing), Model model) {
  Entry updateEntry(Entry t) = t.id == id ? t[editing=isEditing] : t;
  
  return model[entries=[ updateEntry(e) | e <- model.entries ]];
         //batch([attempt(Msg(value x) { return noOp(); }, focus /* ??? */)])>; 
}

Model update(updateEntry(int id, str task), Model model) {
  Entry updateEntry(Entry t) = t.id == id ? t[description=task] : t; 
  return model[entries=[ updateEntry(e) | e <- model.entries ]];
}

// BUG: model[entries = [ e | Entry e <- model.entries, e.id != id ]];
// eval returns type error when comprehension returns empty list.
Model update(delete(int id), Model model)
  = model[entries = l]
  when list[Entry] l := [ e | Entry e <- model.entries, e.id != id ];

Model update(deleteComplete(), Model model)
  = model[entries = l]
  when list[Entry] l := [ e | e <- model.entries, !e.completed ];

Model update(check(int id, bool isCompleted), Model model) {
  Entry updateEntry(Entry t) = t.id == id ? t[completed=isCompleted] : t;
  return model[entries=[ updateEntry(e) | e <- model.entries ]];
}

Model update(checkAll(bool isCompleted), Model model) 
  = model[entries=[ e[completed=isCompleted] | e <- model.entries ]];
  
Model update(changeVisibility(str visibility), Model model)
  = model[visibility=visibility]; 

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

Attr onEnter(Msg msg) 
  = event("keydown", oneKeyCode(13, Msg(int code) { return msg; }));

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
      for (e <- entries, isVisible(e)) {
        viewEntry(e);
      }
    });
  
  });
  
}

// VIEW INDIVIDUAL ENTRIES

//viewKeyedEntry : Entry -> ( String, void Msg )
//viewKeyedEntry todo =
//    ( toString todo.id, lazy viewEntry todo )
//


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
      text(", inspired by Evan\'s version in Elm");
    });
    p(() {
      text("Based ");
      a(href("http://todomvc.com"), "TodoMVC");
    });
  });
}

