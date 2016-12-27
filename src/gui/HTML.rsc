module gui::HTML

import List;
import String;
import IO;


/*
 * NB: as of now, this module cannot be extended, since the global
 * variables will be copied; this leads to strange results if
 * different modules use different globals... 
 *
 * We need the globals, however, because we don't want to pass any
 * extra data to the user functions h1/h2/... etc. The only limitation
 * is thus that case-based functions in this module cannot be extended.
 * Adding new element functions, or even element constructors is fine.
 */

@doc{This is the basic Message data type that clients
will extend with concrete constructors.

Note, that instead of make Html parametric on Msg (Html[&Msg])
we use a single type and ADT extension. This decision makes
a lot of code slightly less verbose, but sacrifices additional
type checking when nesting components.}
data Msg;

@doc{The basic Html node type, defining constructors for
elements, text nodes, and native nodes (which are managed in js).}
data Html
  = element(str tagName, list[Html] kids, map[str, str] attrs, map[str, str] props, map[str, Decoder] events)
  // TODO: native should additional have arbitrary data...
  | native(str kind, str key, map[str, str] attrs, map[str, str] props, map[str, Decoder] events)
  | txt(str contents)
  ;  
  

@doc{Generalized attributes to be produced by explicit attribute construction
functions (such as class(str), onClick(Msg), or \value(str)).
null() acts as a zero element and is always ignored.}
data Attr
  = attr(str name, str val)
  | prop(str name, str val)
  | event(str name, Decoder decoder, map[str,str] options = ())
  | null()
  ;

// TODO: keyed elements 

@doc{Handles represent (encoded) functions to decode events.}
data Handle
  = handle(str path, int id);

@doc{Decoders represent functions to decode event types and data.
Here they are represented without functions, but using Handles
so that they can be serialized to JSON.}
data Decoder
  = succeed(Handle handle)
  | targetValue(Handle handle)
  | targetChecked(Handle handle)
  | oneKeyCode(Handle handle, int keyCode = -1)
  | cursorActivity(Handle handle)
  | change(Handle handle)
  ;

@doc{The encoding interface between an App and this library.
An app needs to set this variable to its encapsulated encoder before
rendering. This ensures that encoding is relative to app and not global.

Encoding produces handles for arbitrary values, at some path,
recording the list of active message transformers at the moment of call.} 
public Handle(value, str, list[Msg(Msg)]) _encode;

@doc{The html element stack used during rendering.}
private list[list[Html]] stack = [];

@doc{Basic stack management functions.}
private void add(Html h) = push(pop() + [h]);

private void push(list[Html] l) { stack += [l]; }

private list[Html] top() = stack[-1];

private list[Html] pop() {
  list[Html] elts = top();
  stack = stack[..-1];
  return elts;
}

@doc{The stack of active msg transformers at some point during rendering.}
private list[Msg(Msg)] mappers = [];

@doc{Compute the current path as a string from the stack.}
private str currentPath() = intercalate("_", [ size(l) | list[Html] l <- stack ]);

  
@doc{Smart constructors for constructing encoded event decoders.}
Decoder succeed(Msg msg) = succeed(_encode(msg, currentPath(), mappers));

Decoder targetValue(Msg(str) str2msg) = targetValue(_encode(str2msg, currentPath(), mappers));

Decoder targetChecked(Msg(bool) bool2msg) = targetChecked(_encode(bool2msg, currentPath(), mappers));

Decoder keyCode(Msg(int) int2msg) = keyCode(_encode(int2msg, currentPath(), mappers)); 

Decoder oneKeyCode(int keyCode, Msg(int) int2msg) 
  = oneKeyCode(_encode(int2msg, currentPath(), mappers), keyCode = keyCode); 
  
Decoder cursorActivity(Msg(int, int, int, str, str) token2msg) 
  = cursorActivity(_encode(token2msg, currentPath(), mappers));

Decoder change(Msg(int, int, int, int, str, str) ch2msg) 
  = change(_encode(ch2msg, currentPath(), mappers));


@doc{Helper functions to partition list of Attrs into attrs, props and events} 
map[str,str] attrsOf(list[Attr] attrs) = ( k: v | attr(str k, str v) <- attrs );

map[str,str] propsOf(list[Attr] attrs) = ( k: v | prop(str k, str v) <- attrs );

map[str,Decoder] eventsOf(list[Attr] attrs) = ( k: v | event(str k, Decoder v) <- attrs );

@doc{Render turns void returning views for a model &T into an Html node.}  
Html render(&T model, void(&T) block) {
  push([]); 
  block(model);
  return pop()[0];
}

@doc{Record mapper to transform messages produced in block according f.}
void mapped(Msg(Msg) f, &T t, void(&T) block)
  = mapped(f, void() { block(t); });

void mapped(Msg(Msg) f, void() block) {
  mappers += [f];
  block();
  mappers = mappers[..-1];
}

@doc{The basic build function to construct html elements on the stack.
The list of argument values can contain any number of Attr values.
The last argument (if any) can be a block, an Html node, or a value.
In the latter case it is converted to a txt node.}
void build(list[value] vals, Html(list[Html], list[Attr]) elt) {
  
  push([]); // start a new scope for this elements children
  
  if (vals != []) { 
    if (void() block := vals[-1]) { // argument block is just called
      block();
    }
    else if (Html h := vals[-1]) { // a computed node is simply added
      add(h);
    }
    else if (Attr _ !:= vals[-1]) { // else (if not Attr), render as text.
      text(vals[-1]);
    }
  }
  
  // construct the `elt` using the kids at the top of the stack
  // and any attributes in vals and add it to the parent's list of children.
  add(elt(pop(), [ a | Attr a <- vals ]));
  
}


@doc{Create a text node.}
void text(value v) = add(txt("<v>")); // TODO: HTML encode.


@doc{The element render functions below all call build
to interpret the list of values; build will call the
second argument (_h1 etc.) to construct the actual
Html values.}
void h1(value vals...) = build(vals, _h1);
void h2(value vals...) = build(vals, _h2);
void h3(value vals...) = build(vals, _h3);
void h4(value vals...) = build(vals, _h4);
void h5(value vals...) = build(vals, _h5);
void h6(value vals...) = build(vals, _h6);
void div(value vals...) = build(vals, _div);
void p(value vals...) = build(vals, _p);
void hr(value vals...) = build(vals, _hr);
void pre(value vals...) = build(vals, _pre);
void blockquote(value vals...) = build(vals, _blockquote);
void span(value vals...) = build(vals, _span);
void a(value vals...) = build(vals, _a);
void code(value vals...) = build(vals, _code);
void em(value vals...) = build(vals, _em);
void strong(value vals...) = build(vals, _strong);
void i(value vals...) = build(vals, _i);
void b(value vals...) = build(vals, _b);
void u(value vals...) = build(vals, _u);
void sub(value vals...) = build(vals, _sub);
void sup(value vals...) = build(vals, _sup);
void br(value vals...) = build(vals, _br);
void ol(value vals...) = build(vals, _ol);
void ul(value vals...) = build(vals, _ul);
void li(value vals...) = build(vals, _li);
void dl(value vals...) = build(vals, _dl);
void dt(value vals...) = build(vals, _dt);
void dd(value vals...) = build(vals, _dd);
void img(value vals...) = build(vals, _img);
void iframe(value vals...) = build(vals, _iframe);
void canvas(value vals...) = build(vals, _canvas);
void math(value vals...) = build(vals, _math);
void form(value vals...) = build(vals, _form);
void input(value vals...) = build(vals, _input);
void textarea(value vals...) = build(vals, _textarea);
void button(value vals...) = build(vals, _button);
void select(value vals...) = build(vals, _select);
void option(value vals...) = build(vals, _option);
void section(value vals...) = build(vals, _section);
void nav(value vals...) = build(vals, _nav);
void article(value vals...) = build(vals, _article);
void aside(value vals...) = build(vals, _aside);
void header(value vals...) = build(vals, _header);
void footer(value vals...) = build(vals, _footer);
void address(value vals...) = build(vals, _address);
void main(value vals...) = build(vals, _main);
void body(value vals...) = build(vals, _body);
void figure(value vals...) = build(vals, _figure);
void figcaption(value vals...) = build(vals, _figcaption);
void table(value vals...) = build(vals, _table);
void caption(value vals...) = build(vals, _caption);
void colgroup(value vals...) = build(vals, _colgroup);
void col(value vals...) = build(vals, _col);
void tbody(value vals...) = build(vals, _tbody);
void thead(value vals...) = build(vals, _thead);
void tfoot(value vals...) = build(vals, _tfoot);
void tr(value vals...) = build(vals, _tr);
void td(value vals...) = build(vals, _td);
void th(value vals...) = build(vals, _th);
void fieldset(value vals...) = build(vals, _fieldset);
void legend(value vals...) = build(vals, _legend);
void label(value vals...) = build(vals, _label);
void datalist(value vals...) = build(vals, _datalist);
void optgroup(value vals...) = build(vals, _optgroup);
void keygen(value vals...) = build(vals, _keygen);
void output(value vals...) = build(vals, _output);
void progress(value vals...) = build(vals, _progress);
void meter(value vals...) = build(vals, _meter);
void audio(value vals...) = build(vals, _audio);
void video(value vals...) = build(vals, _video);
void source(value vals...) = build(vals, _source);
void track(value vals...) = build(vals, _track);
void embed(value vals...) = build(vals, _embed);
void object(value vals...) = build(vals, _object);
void param(value vals...) = build(vals, _param);
void ins(value vals...) = build(vals, _ins);
void del(value vals...) = build(vals, _del);
void small(value vals...) = build(vals, _small);
void cite(value vals...) = build(vals, _cite);
void dfn(value vals...) = build(vals, _dfn);
void abbr(value vals...) = build(vals, _abbr);
void time(value vals...) = build(vals, _time);
void var(value vals...) = build(vals, _var);
void samp(value vals...) = build(vals, _samp);
void kbd(value vals...) = build(vals, _kbd);
void s(value vals...) = build(vals, _s);
void q(value vals...) = build(vals, _q);
void mark(value vals...) = build(vals, _mark);
void ruby(value vals...) = build(vals, _ruby);
void rt(value vals...) = build(vals, _rt);
void rp(value vals...) = build(vals, _rp);
void bdi(value vals...) = build(vals, _bdi);
void bdo(value vals...) = build(vals, _bdo);
void wbr(value vals...) = build(vals, _wbr);
void details(value vals...) = build(vals, _details);
void summary(value vals...) = build(vals, _summary);
void menuitem(value vals...) = build(vals, _menuitem);
void menu(value vals...) = build(vals, _menu);

Html _h1(list[Html] kids, list[Attr] attrs) = element("h1", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _h2(list[Html] kids, list[Attr] attrs) = element("h2", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _h3(list[Html] kids, list[Attr] attrs) = element("h3", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _h4(list[Html] kids, list[Attr] attrs) = element("h4", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _h5(list[Html] kids, list[Attr] attrs) = element("h5", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _h6(list[Html] kids, list[Attr] attrs) = element("h6", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _div(list[Html] kids, list[Attr] attrs) = element("div", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _p(list[Html] kids, list[Attr] attrs) = element("p", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _hr(list[Html] kids, list[Attr] attrs) = element("hr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _pre(list[Html] kids, list[Attr] attrs) = element("pre", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _blockquote(list[Html] kids, list[Attr] attrs) = element("blockquote", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _span(list[Html] kids, list[Attr] attrs) = element("span", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _a(list[Html] kids, list[Attr] attrs) = element("a", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _code(list[Html] kids, list[Attr] attrs) = element("code", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _em(list[Html] kids, list[Attr] attrs) = element("em", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _strong(list[Html] kids, list[Attr] attrs) = element("strong", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _i(list[Html] kids, list[Attr] attrs) = element("i", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _b(list[Html] kids, list[Attr] attrs) = element("b", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _u(list[Html] kids, list[Attr] attrs) = element("u", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _sub(list[Html] kids, list[Attr] attrs) = element("sub", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _sup(list[Html] kids, list[Attr] attrs) = element("sup", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _br(list[Html] kids, list[Attr] attrs) = element("br", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _ol(list[Html] kids, list[Attr] attrs) = element("ol", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _ul(list[Html] kids, list[Attr] attrs) = element("ul", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _li(list[Html] kids, list[Attr] attrs) = element("li", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _dl(list[Html] kids, list[Attr] attrs) = element("dl", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _dt(list[Html] kids, list[Attr] attrs) = element("dt", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _dd(list[Html] kids, list[Attr] attrs) = element("dd", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _img(list[Html] kids, list[Attr] attrs) = element("img", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _iframe(list[Html] kids, list[Attr] attrs) = element("iframe", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _canvas(list[Html] kids, list[Attr] attrs) = element("canvas", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _math(list[Html] kids, list[Attr] attrs) = element("math", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _form(list[Html] kids, list[Attr] attrs) = element("form", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _input(list[Html] kids, list[Attr] attrs) = element("input", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _textarea(list[Html] kids, list[Attr] attrs) = element("textarea", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _button(list[Html] kids, list[Attr] attrs) = element("button", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _select(list[Html] kids, list[Attr] attrs) = element("select", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _option(list[Html] kids, list[Attr] attrs) = element("option", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _section(list[Html] kids, list[Attr] attrs) = element("section", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _nav(list[Html] kids, list[Attr] attrs) = element("nav", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _article(list[Html] kids, list[Attr] attrs) = element("article", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _aside(list[Html] kids, list[Attr] attrs) = element("aside", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _header(list[Html] kids, list[Attr] attrs) = element("header", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _footer(list[Html] kids, list[Attr] attrs) = element("footer", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _address(list[Html] kids, list[Attr] attrs) = element("address", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _main(list[Html] kids, list[Attr] attrs) = element("main", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _body(list[Html] kids, list[Attr] attrs) = element("body", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _figure(list[Html] kids, list[Attr] attrs) = element("figure", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _figcaption(list[Html] kids, list[Attr] attrs) = element("figcaption", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _table(list[Html] kids, list[Attr] attrs) = element("table", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _caption(list[Html] kids, list[Attr] attrs) = element("caption", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _colgroup(list[Html] kids, list[Attr] attrs) = element("colgroup", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _col(list[Html] kids, list[Attr] attrs) = element("col", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _tbody(list[Html] kids, list[Attr] attrs) = element("tbody", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _thead(list[Html] kids, list[Attr] attrs) = element("thead", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _tfoot(list[Html] kids, list[Attr] attrs) = element("tfoot", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _tr(list[Html] kids, list[Attr] attrs) = element("tr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _td(list[Html] kids, list[Attr] attrs) = element("td", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _th(list[Html] kids, list[Attr] attrs) = element("th", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _fieldset(list[Html] kids, list[Attr] attrs) = element("fieldset", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _legend(list[Html] kids, list[Attr] attrs) = element("legend", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _label(list[Html] kids, list[Attr] attrs) = element("label", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _datalist(list[Html] kids, list[Attr] attrs) = element("datalist", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _optgroup(list[Html] kids, list[Attr] attrs) = element("optgroup", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _keygen(list[Html] kids, list[Attr] attrs) = element("keygen", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _output(list[Html] kids, list[Attr] attrs) = element("output", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _progress(list[Html] kids, list[Attr] attrs) = element("progress", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _meter(list[Html] kids, list[Attr] attrs) = element("meter", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _audio(list[Html] kids, list[Attr] attrs) = element("audio", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _video(list[Html] kids, list[Attr] attrs) = element("video", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _source(list[Html] kids, list[Attr] attrs) = element("source", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _track(list[Html] kids, list[Attr] attrs) = element("track", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _embed(list[Html] kids, list[Attr] attrs) = element("embed", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _object(list[Html] kids, list[Attr] attrs) = element("object", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _param(list[Html] kids, list[Attr] attrs) = element("param", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _ins(list[Html] kids, list[Attr] attrs) = element("ins", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _del(list[Html] kids, list[Attr] attrs) = element("del", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _small(list[Html] kids, list[Attr] attrs) = element("small", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _cite(list[Html] kids, list[Attr] attrs) = element("cite", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _dfn(list[Html] kids, list[Attr] attrs) = element("dfn", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _abbr(list[Html] kids, list[Attr] attrs) = element("abbr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _time(list[Html] kids, list[Attr] attrs) = element("time", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _var(list[Html] kids, list[Attr] attrs) = element("var", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _samp(list[Html] kids, list[Attr] attrs) = element("samp", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _kbd(list[Html] kids, list[Attr] attrs) = element("kbd", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _s(list[Html] kids, list[Attr] attrs) = element("s", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _q(list[Html] kids, list[Attr] attrs) = element("q", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _mark(list[Html] kids, list[Attr] attrs) = element("mark", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _ruby(list[Html] kids, list[Attr] attrs) = element("ruby", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _rt(list[Html] kids, list[Attr] attrs) = element("rt", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _rp(list[Html] kids, list[Attr] attrs) = element("rp", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _bdi(list[Html] kids, list[Attr] attrs) = element("bdi", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _bdo(list[Html] kids, list[Attr] attrs) = element("bdo", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _wbr(list[Html] kids, list[Attr] attrs) = element("wbr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _details(list[Html] kids, list[Attr] attrs) = element("details", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _summary(list[Html] kids, list[Attr] attrs) = element("summary", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _menuitem(list[Html] kids, list[Attr] attrs) = element("menuitem", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Html _menu(list[Html] kids, list[Attr] attrs) = element("menu", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

/*
 * Attributes
 */
 
Attr style(tuple[str, str] styles...) = attr("style", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ])); 
Attr property(str name, value val) = prop(name, "<val>");
Attr attribute(str name, str val) = attr(name, val);
Attr class(str val) = attr("class", val);
Attr classList(tuple[str, bool] classes...) = attr("class", intercalate(" ", [ k | <k, true > <- classes ]));
Attr id(str val) = attr("id", val);
Attr title(str val) = attr("title", val);
Attr hidden(bool h) = h ? attr("hidden", "true") : null(); // ???
Attr \type(str val) = attr("type", val);
Attr \value(str val) = prop("value", val);
Attr defaultValue(str val) = attr("defaultValue", val); // should be attr value?
Attr checked(bool checked) = checked ? attr("checked", "true") : null();
Attr placeholder(str val) = attr("placeholder", val);
Attr selected(bool selected) = selected ? attr("selected", "true") : null();

Attr accept(str val) = attr("accept", val);
Attr acceptCharset(str val) = attr("acceptCharset", val);
Attr action(str val) = attr("action", val);
Attr autocomplete(bool val) = attr("autocomplete", "<val>");
Attr autofocus(bool val) = attr("autofocus", "<val>");
Attr disabled(bool val) = attr("disabled", "<val>");
Attr enctype(str val) = attr("enctype", val);
Attr formaction(str val) = attr("formaction", val);
Attr \list(str val) = attr("list", val);
Attr maxlength(int val) = attr("maxlength", "<val>");
Attr minlength(int val) = attr("minlength", "<val>");
Attr method(str val) = attr("method", val);
Attr multiple(bool val) = attr("multiple", "<val>");
Attr name(str val) = attr("name", val);
Attr novalidate(bool val) = attr("novalidate", "<val>");
Attr pattern(str val) = attr("pattern", val);
Attr readonly(bool val) = attr("readonly", "<val>");
Attr required(bool val) = attr("required", "<val>");
Attr size(int val) = attr("size", "<val>");
Attr \for(str val) = attr("for", val);
Attr form(str val) = attr("form", val);
Attr max(str val) = attr("max", val);
Attr min(str val) = attr("min", val);
Attr step(str val) = attr("step", val);
Attr cols(int val) = attr("cols", "<val>");
Attr rows(int val) = attr("rows", "<val>");
Attr wrap(str val) = attr("wrap", val);
Attr href(str val) = attr("href", val);
Attr target(str val) = attr("target", val);
Attr download(bool val) = attr("download", "<val>");
Attr downloadAs(str val) = attr("downloadAs", val);
Attr hreflang(str val) = attr("hreflang", val);
Attr media(str val) = attr("media", val);
Attr ping(str val) = attr("ping", val);
Attr \rel(str val) = attr("rel", val);

Attr ismap(bool val) = attr("ismap", "<val>");
Attr usemap(str val) = attr("usemap", val);
Attr shape(str val) = attr("shape", val);
Attr coords(str val) = attr("coords", val);
Attr src(str val) = attr("src", val);
Attr height(int val) = attr("height", "<val>");
Attr width(int val) = attr("width", "<val>");
Attr alt(str val) = attr("alt", val);
Attr autoplay(bool val) = attr("autoplay", "<val>");
Attr controls(bool val) = attr("controls", "<val>");
Attr loop(bool val) = attr("loop", "<val>");
Attr preload(str val) = attr("preload", val);
Attr poster(str val) = attr("poster", val);
Attr \default(bool val) = attr("default", "<val>");
Attr kind(str val) = attr("kind", val);
Attr srclang(str val) = attr("srclang", val);
Attr sandbox(str val) = attr("sandbox", val);
Attr seamless(bool val) = attr("seamless", "<val>");
Attr srcdoc(str val) = attr("srcdoc", val);
Attr reversed(bool val) = attr("reversed", "<val>");
Attr \start(int val) = attr("start", "<val>");
Attr align(str val) = attr("align", val);
Attr colspan(int val) = attr("colspan", "<val>");
Attr rowspan(int val) = attr("rowspan", "<val>");
Attr headers(str val) = attr("headers", val);
Attr scope(str val) = attr("scope", val);
Attr async(bool val) = attr("async", "<val>");
Attr charset(str val) = attr("charset", val);
Attr content(str val) = attr("content", val);
Attr defer(bool val) = attr("defer", "<val>");
Attr httpEquiv(str val) = attr("httpEquiv", val);
Attr language(str val) = attr("language", val);
Attr scoped(bool val) = attr("scoped", "<val>");
Attr accesskey(str char) = attribute("accesskey", char); // ??? keycode?
Attr contenteditable(bool val) = attr("contenteditable", "<val>");
Attr contextmenu(str val) = attr("contextmenu", val);
Attr dir(str val) = attr("dir", val);
Attr draggable(str val) = attr("draggable", val);
Attr dropzone(str val) = attr("dropzone", val);
Attr itemprop(str val) = attr("itemprop", val);
Attr lang(str val) = attr("lang", val);
Attr spellcheck(bool val) = attr("spellcheck", "<val>");
Attr tabindex(int val) = attr("tabindex", "<val>");
Attr challenge(str val) = attr("challenge", val);
Attr keytype(str val) = attr("keytype", val);
Attr cite(str val) = attr("cite", val);
Attr \datetime(str val) = attr("datetime", val);
Attr pubdate(str val) = attr("pubdate", val);
Attr manifest(str val) = attr("manifest", val);


/*
 * Events
 */
 
Attr onClick(Msg msg) = event("click", succeed(msg));
Attr onDoubleClick(Msg msg) = event("dblclick", succeed(msg));
Attr onMouseDown(Msg msg) = event("mouseDown", succeed(msg));
Attr onMouseUp(Msg msg) = event("mouseUp", succeed(msg));
Attr onMouseEnter(Msg msg) = event("mouseEnter", succeed(msg));
Attr onMouseLeave(Msg msg) = event("mouseLeave", succeed(msg));
Attr onMouseOver(Msg msg) = event("mouseOver", succeed(msg));
Attr onMouseOut(Msg msg) = event("mouseOut", succeed(msg));
Attr onSubmit(Msg msg) = event("submit", succeed(msg));
Attr onBlur(Msg msg) = event("blur", succeed(msg));
Attr onSubmit(Msg msg) = event("focus", succeed(msg));
Attr onInput(Msg(str) f) = event("input", targetValue(f)); 
Attr onCheck(Msg(bool) f) = event("check", targetChecked(f));

// Code mirror ones...
Attr onCursorActivity(Msg(int, int, int, str, str) f) 
  = event("cursorActivity", cursorActivity(f));

Attr onChange(Msg(int, int, int, int, str, str) f)
  = event("change", change(f));