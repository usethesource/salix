module gui::App

import gui::HTML;
import gui::Diff;
import gui::Patch;

import util::Webserver;
import IO;
import String;
import Map;
import List;
import Type;

Handle toHandle(map[str, str] params)
  = handle(params["path"], toInt(params["id"]));

Decoder toDecoder(map[str, str] params)
  = make(#Decoder, params["type"], [toHandle(params)], ());

Msg toMsg(succeed(Handle h), map[str,str] p, &T(int,type[&T]) dec) 
  = dec(h.id, #Msg);

Msg toMsg(targetValue(Handle h), map[str,str] p, &T(int,type[&T]) dec) 
  =  dec(h.id, #Msg(str))(p["data"]);

Msg toMsg(targetChecked(Handle h), map[str,str] p, &T(int,type[&T]) dec) 
  = dec(h.id, #Msg(bool))(p["data"] == "true");

Msg toMsg(oneKeyCode(Handle h), map[str,str] p, &T(int,type[&T]) dec) 
  = dec(h.id, #Msg(int))(toInt(p["data"]));

Msg toMsg(cursorActivity(Handle h), map[str,str] p, &T(int,type[&T]) dec) 
  = dec(h.id, #Msg(int, int, int, str, str))(
           toInt(p["line"]), toInt(p["start"]), toInt(p["end"]), p["string"], p["tokenType"]);

Msg toMsg(change(Handle h), map[str,str] p, &T(int,type[&T]) dec) 
  = dec(h.id, #Msg(int, int, int, int, str, str))(
           toInt(p["fromLine"]), toInt(p["fromCol"]), 
           toInt(p["toLine"]), toInt(p["toCol"]),
           p["text"], p["removed"]);
  
// todo: remove duplication with params[path]
Msg params2msg(map[str, str] params, Msg(str, Msg) f, &T(int,type[&T]) dec) 
  = f(params["path"], toMsg(toDecoder(params), params, dec));

alias App[&T] = tuple[
  void() serve, 
  void() stop, 
  void(void(&T), &T(Msg, &T)) hotSwap
];

App[&T] app(&T model, void(&T) view, &T(Msg, &T) update, loc http, loc static) {
  
  int id = -1;

  map[int, value] _from  = ();
  map[value, int] _to = ();
  map[str, list[Msg(Msg)]] _mappers = ();
  
  Handle myEncode(value x, str path, list[Msg(Msg)] mappers) {
    if (x notin _to) {
      id += 1;
      _from[id] = x;
      _to[x] = id;
    }
    _mappers[path] = mappers;
    return handle(path, _to[x]);
  }
  
  &U decode(int id, type[&U] t) = d
    when &U d := _from[id];
  
  Msg mapEm(str path, Msg msg) 
    = ( msg | f(it) | path in _mappers, Msg(Msg) f <- reverse(_mappers[path]) );

  Html current;

  // mixes with constructors that are in scope!!!
  Response _handle(Request req) {
    //withEncode(myEncode); ?? does not work!?!?!
    gui::HTML::_encode = myEncode;

    if (get("/init") := req) {
      current = render(model, view);
      //println("Initial:");
      //iprintln(current);
      return response(current);
    }
    
    if (get("/msg") := req) {
      //println("");
      //println(req.parameters);
      Msg msg = params2msg(req.parameters, mapEm, decode);
      println("Processing: <msg>");
      model = update(msg, model);
      Html newView = render(model, view);
      Patch p = diff(current, newView);
      current = newView;
      return response(p); 
    }
    
    if (get(p:/\.<ext:.*>$/) := req, ext in mimeTypes) {
      return fileResponse(static[path="<static.path>/<p>"], mimeTypes[ext], ());
    }
    
    return response(notFound(), "not handled: <req.path>");
  }

  return <
    () { serve(http, _handle); }, 
    () { shutdown(http); },
    (void(&T) v, &T(Msg, &T) u) { view = v; update = u; }
   >;
}