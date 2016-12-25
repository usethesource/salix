module gui::App

import gui::HTML;
import gui::Diff;
import gui::Patch;

import util::Webserver;
import IO;
import String;
import Map;
import List;

Decoder toDecoder(map[str, str] params)
  = decoder(params["type"], params["path"], toInt(params["id"]));

Msg toMsg(decoder("succeed", _, int id), str _, &T(int,type[&T]) dec) 
  = dec(id, #Msg);

Msg toMsg(decoder("targetValue", _, int id), str d, &T(int,type[&T]) dec) 
  =  dec(id, #Msg(str))(d);

Msg toMsg(decoder("targetChecked", _, int id), str d, &T(int,type[&T]) dec) 
  = dec(id, #Msg(bool))(d == "true");

Msg toMsg(decoder("keyCode", _, int id), str d, &T(int,type[&T]) dec) 
  = dec(id, #Msg(int))(toInt(d));
  
// todo: remove duplication with params[path]
Msg params2msg(map[str, str] params, Msg(str, Msg) f, &T(int,type[&T]) dec) 
  = f(params["path"], toMsg(toDecoder(params), params["data"] ? "", dec));

alias App = tuple[void() serve, void() stop];

App app(&T model, void(&T) view, &T(Msg, &T) update, loc http, loc static) {
  
  int id = -1;

  map[int, value] _from  = ();
  map[value, int] _to = ();
  map[str, list[Msg(Msg)]] _mappers = ();
  
  Decoder myEncode(str typ, value x, str path, list[Msg(Msg)] mappers) {
    if (x notin _to) {
      id += 1;
      _from[id] = x;
      _to[x] = id;
    }
    _mappers[path] = mappers;
    return decoder(typ, path, _to[x]);
  }
  
  &U decode(int id, type[&U] t) = d
    when &U d := _from[id];
  
  Msg mapEm(str path, Msg msg) 
    = ( msg | f(it) | path in _mappers, Msg(Msg) f <- reverse(_mappers[path]) );

  Html current;

  Response handle(Request req) {
    //withEncode(myEncode); ?? does not work!?!?!
    gui::HTML::_encode = myEncode;

    if (get("/init") := req) {
      current = render(model, view);
      println("Initial:");
      iprintln(current);
      return response(current);
    }
    
    if (get("/msg") := req) {
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

  return <() { serve(http, handle); }, () { shutdown(http); }>;
}