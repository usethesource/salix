module salix::HTML

import salix::Node;
import salix::Core;
import List;
import String;
import IO;

data Msg;

@doc{Create a text node.}
void text(value v) = _text(v);


@doc{The element render functions below all call build
to interpret the list of values; build will call the
second argument (_h1 etc.) to construct the actual
Node values.}
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

// Todo: remove this indirection, and just have
// Node(list[Node], list[Attr]) _element(str, ..);

Node _h1(list[Node] kids, list[Attr] attrs) = element("h1", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _h2(list[Node] kids, list[Attr] attrs) = element("h2", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _h3(list[Node] kids, list[Attr] attrs) = element("h3", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _h4(list[Node] kids, list[Attr] attrs) = element("h4", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _h5(list[Node] kids, list[Attr] attrs) = element("h5", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _h6(list[Node] kids, list[Attr] attrs) = element("h6", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _div(list[Node] kids, list[Attr] attrs) = element("div", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _p(list[Node] kids, list[Attr] attrs) = element("p", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _hr(list[Node] kids, list[Attr] attrs) = element("hr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _pre(list[Node] kids, list[Attr] attrs) = element("pre", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _blockquote(list[Node] kids, list[Attr] attrs) = element("blockquote", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _span(list[Node] kids, list[Attr] attrs) = element("span", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _a(list[Node] kids, list[Attr] attrs) = element("a", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _code(list[Node] kids, list[Attr] attrs) = element("code", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _em(list[Node] kids, list[Attr] attrs) = element("em", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _strong(list[Node] kids, list[Attr] attrs) = element("strong", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _i(list[Node] kids, list[Attr] attrs) = element("i", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _b(list[Node] kids, list[Attr] attrs) = element("b", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _u(list[Node] kids, list[Attr] attrs) = element("u", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _sub(list[Node] kids, list[Attr] attrs) = element("sub", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _sup(list[Node] kids, list[Attr] attrs) = element("sup", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _br(list[Node] kids, list[Attr] attrs) = element("br", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _ol(list[Node] kids, list[Attr] attrs) = element("ol", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _ul(list[Node] kids, list[Attr] attrs) = element("ul", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _li(list[Node] kids, list[Attr] attrs) = element("li", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _dl(list[Node] kids, list[Attr] attrs) = element("dl", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _dt(list[Node] kids, list[Attr] attrs) = element("dt", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _dd(list[Node] kids, list[Attr] attrs) = element("dd", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _img(list[Node] kids, list[Attr] attrs) = element("img", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _iframe(list[Node] kids, list[Attr] attrs) = element("iframe", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _canvas(list[Node] kids, list[Attr] attrs) = element("canvas", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _math(list[Node] kids, list[Attr] attrs) = element("math", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _form(list[Node] kids, list[Attr] attrs) = element("form", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _input(list[Node] kids, list[Attr] attrs) = element("input", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _textarea(list[Node] kids, list[Attr] attrs) = element("textarea", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _button(list[Node] kids, list[Attr] attrs) = element("button", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _select(list[Node] kids, list[Attr] attrs) = element("select", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _option(list[Node] kids, list[Attr] attrs) = element("option", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _section(list[Node] kids, list[Attr] attrs) = element("section", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _nav(list[Node] kids, list[Attr] attrs) = element("nav", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _article(list[Node] kids, list[Attr] attrs) = element("article", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _aside(list[Node] kids, list[Attr] attrs) = element("aside", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _header(list[Node] kids, list[Attr] attrs) = element("header", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _footer(list[Node] kids, list[Attr] attrs) = element("footer", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _address(list[Node] kids, list[Attr] attrs) = element("address", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _main(list[Node] kids, list[Attr] attrs) = element("main", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _body(list[Node] kids, list[Attr] attrs) = element("body", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _figure(list[Node] kids, list[Attr] attrs) = element("figure", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _figcaption(list[Node] kids, list[Attr] attrs) = element("figcaption", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _table(list[Node] kids, list[Attr] attrs) = element("table", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _caption(list[Node] kids, list[Attr] attrs) = element("caption", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _colgroup(list[Node] kids, list[Attr] attrs) = element("colgroup", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _col(list[Node] kids, list[Attr] attrs) = element("col", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _tbody(list[Node] kids, list[Attr] attrs) = element("tbody", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _thead(list[Node] kids, list[Attr] attrs) = element("thead", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _tfoot(list[Node] kids, list[Attr] attrs) = element("tfoot", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _tr(list[Node] kids, list[Attr] attrs) = element("tr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _td(list[Node] kids, list[Attr] attrs) = element("td", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _th(list[Node] kids, list[Attr] attrs) = element("th", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _fieldset(list[Node] kids, list[Attr] attrs) = element("fieldset", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _legend(list[Node] kids, list[Attr] attrs) = element("legend", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _label(list[Node] kids, list[Attr] attrs) = element("label", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _datalist(list[Node] kids, list[Attr] attrs) = element("datalist", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _optgroup(list[Node] kids, list[Attr] attrs) = element("optgroup", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _keygen(list[Node] kids, list[Attr] attrs) = element("keygen", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _output(list[Node] kids, list[Attr] attrs) = element("output", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _progress(list[Node] kids, list[Attr] attrs) = element("progress", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _meter(list[Node] kids, list[Attr] attrs) = element("meter", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _audio(list[Node] kids, list[Attr] attrs) = element("audio", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _video(list[Node] kids, list[Attr] attrs) = element("video", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _source(list[Node] kids, list[Attr] attrs) = element("source", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _track(list[Node] kids, list[Attr] attrs) = element("track", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _embed(list[Node] kids, list[Attr] attrs) = element("embed", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _object(list[Node] kids, list[Attr] attrs) = element("object", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _param(list[Node] kids, list[Attr] attrs) = element("param", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _ins(list[Node] kids, list[Attr] attrs) = element("ins", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _del(list[Node] kids, list[Attr] attrs) = element("del", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _small(list[Node] kids, list[Attr] attrs) = element("small", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _cite(list[Node] kids, list[Attr] attrs) = element("cite", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _dfn(list[Node] kids, list[Attr] attrs) = element("dfn", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _abbr(list[Node] kids, list[Attr] attrs) = element("abbr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _time(list[Node] kids, list[Attr] attrs) = element("time", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _var(list[Node] kids, list[Attr] attrs) = element("var", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _samp(list[Node] kids, list[Attr] attrs) = element("samp", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _kbd(list[Node] kids, list[Attr] attrs) = element("kbd", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _s(list[Node] kids, list[Attr] attrs) = element("s", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _q(list[Node] kids, list[Attr] attrs) = element("q", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _mark(list[Node] kids, list[Attr] attrs) = element("mark", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _ruby(list[Node] kids, list[Attr] attrs) = element("ruby", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _rt(list[Node] kids, list[Attr] attrs) = element("rt", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _rp(list[Node] kids, list[Attr] attrs) = element("rp", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _bdi(list[Node] kids, list[Attr] attrs) = element("bdi", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _bdo(list[Node] kids, list[Attr] attrs) = element("bdo", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _wbr(list[Node] kids, list[Attr] attrs) = element("wbr", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _details(list[Node] kids, list[Attr] attrs) = element("details", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _summary(list[Node] kids, list[Attr] attrs) = element("summary", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _menuitem(list[Node] kids, list[Attr] attrs) = element("menuitem", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _menu(list[Node] kids, list[Attr] attrs) = element("menu", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

Node _shadow(list[Node] kids, list[Attr] attrs) = shadow(kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));

/*
 * Attributes
 */
 
Attr style(tuple[str, str] styles...) = attr("style", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ])); 
Attr style(map[str,str] styles) = attr("style", intercalate("; ", ["<k>: <styles[k]>" | k <- styles ])); 

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
Attr onMouseDown(Msg msg) = event("mousedown", succeed(msg));
Attr onMouseUp(Msg msg) = event("mouseup", succeed(msg));
Attr onMouseEnter(Msg msg) = event("mouseenter", succeed(msg));
Attr onMouseLeave(Msg msg) = event("mouseleave", succeed(msg));
Attr onMouseOver(Msg msg) = event("mouseover", succeed(msg));
Attr onMouseOut(Msg msg) = event("mouseout", succeed(msg));
Attr onSubmit(Msg msg) = event("submit", succeed(msg));
Attr onBlur(Msg msg) = event("blur", succeed(msg));
Attr onSubmit(Msg msg) = event("focus", succeed(msg));
Attr onInput(Msg(str) f) = event("input", targetValue(f)); 
Attr onCheck(Msg(bool) f) = event("check", targetChecked(f));

  
@doc{Smart constructors for constructing encoded event decoders.}
Hnd succeed(Msg msg) = handler("succeed", encode(msg));

Hnd targetValue(Msg(str) str2msg) = handler("targetValue", encode(str2msg));

Hnd targetChecked(Msg(bool) bool2msg) = handler("targetChecked", encode(bool2msg));

Hnd keyCode(Msg(int) int2msg) = handler("keyCode", encode(int2msg)); 

  