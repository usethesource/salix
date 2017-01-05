module salix::lib::XTerm

import salix::Core;
import salix::Node;


// http://xtermjs.org/docs/api/Terminal/


data Cmd
  = blur()
  | clear()
  | destroy()
  | focus()
  | getOption(str key)
  | setOption(str key, str val)
  | refresh(int \start, int end, bool queue)
  | reset()
  | resize(int x, int y)  // cols, rows
  | scrollDisp(int n) // negative is up/positive is down
  | scrollPages(int n) // idem.
  | scrollToTop()
  | scrollToBottom()
  | write(str text)
  | writeln(str text)
  ;
  
  
data Hnd
  = eventData(Handle handle)
  | keyName(Handle handle)
  | startEnd(Handle handle)
  | colsRows(Handle handle)
  | ydisp(Handle handle)
  ;


void xterm(value vals...) = build(vals, _xterm);

Node _xterm(list[Node] _, list[Attr] attrs)
  = native("xterm", propsOf(attrs), eventsOf(attrs));

// Attributes/properties/events

Attr cols(int val) = prop("cols", "<val>");
Attr rows(int val) = prop("rows", "<val>");
Attr cursorBlink(bool b) = prop("cursorBlink", "<b>");


// standard: blur, focus, keydown, keypress

Attr onData(Msg(str) str2msg) = event("data", eventData(encode(str2msg)));

Attr onKey(Msg(str) str2msg) = event("key", keyName(encode(str2msg)));

Attr onOpen(Msg msg) = event("open", succeed(encode(msg)));

Attr onRefresh(Msg(int, int) int22msg) = event("refresh", startEnd(encode(int22msg)));

Attr onResize(Msg(int, int) int22msg) = event("resize", colsRows(encode(int22msg)));

Attr onScroll(Msg(int) int2msg) = event("scroll", ydisp(encode(int2msg)));

Msg intIntParser(Handle h, map[str, str] p)
  = applyMaps(h, decode(h, #Msg(int,int))(toInt(params["intVal1"]), toInt(params["intVal2"])));

void registerXTerm() {
  msgParser("int-int", intIntParser);
}



