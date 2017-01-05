module salix::lib::XTerm

import salix::Core;
import salix::Node;


// http://xtermjs.org/docs/api/Terminal/

/*
  term.prompt = function () {
          term.write('\r\n' + shellprompt);
        };
        
        term.on('key', function (key, ev) {
          var printable = (
              !ev.altKey && !ev.altGraphKey && !ev.ctrlKey && !ev.metaKey
          );

          if (ev.keyCode == 13) {
            term.prompt();
          } else if (ev.keyCode == 8) {
            // Do not delete the prompt
            if (term.x > shellprompt.length) {
              term.write('\b \b');
            }
          } else if (printable) {
            term.write(key);
          }
        });
        
        
        term.on('paste', function (data, ev) {
            term.write(data);
        });
        
        
*/

data Cmd
  = blur(Handle handle, str id)
  | clear(Handle handle, str id)
  | destroy(Handle handle, str id)
  | focus(Handle handle, str id)
  | getOption(Handle handle, str id, str key)
  | setOption(Handle handle, str id, str key, value val)
  | refresh(Handle handle, str id, int \start, int end, bool queue)
  | reset(Handle handle, str id)
  | resize(Handle handle, str id, int x, int y)  // cols, rows
  | scrollDisp(Handle handle, str id, int n) // negative is up/positive is down
  | scrollPages(Handle handle, str id, int n) // idem.
  | scrollToTop(Handle handle, str id)
  | scrollToBottom(Handle handle, str id)
  | write(Handle handle, str id, str text)
  | writeln(Handle handle, str id, str text)
  ;


Cmd blur(Msg f, str id) = blur(encode(f), id);
Cmd clear(Msg f, str id) = clear(encode(f), id);
Cmd destroy(Msg f, str id) = destroy(encode(f), id);
Cmd focus(Msg f, str id) = focus(encode(f), ud);
Cmd getOption(Msg(str) f, str id, str key) = getOption(encode(f), id, key);
Cmd setOption(Msg f, str id, str key, value val) = setOption(encode(f), id, key, val);
Cmd refresh(Msg f, str id, int \start, int end, bool queue) = refresh(encode(f), id, \start, end, queue);
Cmd reset(Msg f, str id) = reset(encode(f), id);
Cmd resize(Msg f, str id, int x, int y) = resize(encode(f), id, x, y);
Cmd scrollDisp(Msg f, str id, int n) = scrollDisp(encode(f), id, n);
Cmd scrollPages(Msg f, str id, int n) = scrollPages(encode(f), id, n);
Cmd scrollToTop(Msg f, str id) = scrollToTop(encode(f), id);
Cmd scrollToBottom(Msg f, str id) = scrollToBottom(encode(f), id);
Cmd write(Msg f, str id, str text) = write(encode(f), id, text);
Cmd writeln(Msg f, str id, str text) = writeln(encode(f), id, text);  
  
data Hnd
  = eventData(Handle handle)
  | keyName(Handle handle)
  | startEnd(Handle handle)
  | colsRows(Handle handle)
  | ydisp(Handle handle)
  ;


void xterm(str id, value vals...) 
  = build(vals, Node(list[Node] _, list[Attr] attrs) {
       return native("xterm", id, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
    });


// Attributes/properties/events

Attr cols(int val) = prop("cols", "<val>");
Attr rows(int val) = prop("rows", "<val>");
Attr cursorBlink(bool b) = prop("cursorBlink", "<b>");

Attr prompt(str val) = prop("prompt", val);



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



