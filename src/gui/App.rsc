module gui::App

import gui::Render;
import gui::Encode;
import gui::Comms;
import gui::Diff;
import gui::Patch;
import lib::Trace;

import util::Webserver;
import IO;
import String;
import Map;
import List;


alias WithCmds[&T] = tuple[&T model, list[Cmd] commands];  
 
 
@doc{The basic App type:
- serve to start serving the application
- stop to shutdown the server
- hotSwap to replace the capture view and update functions}
alias App[&T] = tuple[
  void() serve, 
  void() stop, 
  void(void(&T), &T(Msg, &T)) hotSwap
];

@doc{Internal app state}
alias AppState = tuple[
  int id, // last assigned handle id
  map[int, value] from, // bijection between handle identities and decoder functions
  map[value, int] to,
  map[str, list[Msg(Msg)]] mappers, // active stack of message mappers per handle path
  bool running
];

AppState newAppState() = < -1, (), (), (), false>;

App[&T] app(&T model, void(&T) view, &T(Msg, &T) update, loc http, loc static, 
            list[Sub](&T) subs = list[Sub](&T t) { return []; }, str root = "root") 
 = app(<model, []>, view, WithCmds[&T](Msg m, &T t) { return <update(m, t), []>; },
     http, static, subs = subs, root = root);

@doc{Construct an App over model type &T, providing a view, a model update,
a http loc to serve the app to, and a location to resolve static files.
The keyword param root identifies the root element in the html document.}
App[&T] app(WithCmds[&T] modelWithCmds, void(&T) view, WithCmds[&T](Msg, &T) update, loc http, loc static, 
            list[Sub](&T) subs = list[Sub](&T t) { return []; }, str root = "root") {

  AppState state = newAppState();
  
  // encode a value and path + active mappers as a handle
  // which can be sent over the wire.
  Handle myEncode(value x, str path, list[Msg(Msg)] mappers) {
    if (x notin state.to) {
      state.id += 1;
      state.from[state.id] = x;
      state.to[x] = state.id;
    }
    state.mappers[path] = mappers;
    return handle(path, state.to[x]);
  }
  
  // retrieve the actual function corresponding to a handle identity.
  &U decode(Handle h, type[&U] t) = d
    when &U d := state.from[h.id];
  
  // apply the message transformers to msg that were in scope at path
  Msg mapEm(str path, Msg msg) 
    = ( msg | f(it) | path in state.mappers, Msg(Msg) f <- reverse(state.mappers[path]) );

  Html asRoot(Html h) = h[attrs=h.attrs + ("id": root)];

  Html current;

  list[Msg] trace = [];
  
  void myTracedView(&T t) { 
    return traceView(<trace, t>, view); 
  };
  
  &T model;

  // the main handler to interpret http requests.
  // BUG: mixes with constructors that are in scope!!!
  Response _handle(Request req) {
    // publish my encoder to gui::Render.
    gui::Encode::_encode = myEncode;

    // initially, just render the view, for the current model.
    if (get("/init") := req) {
      model = modelWithCmds.model;
      list[Sub] mySubs = subs(model);
      list[Cmd] myCmds = modelWithCmds.commands;
      current = asRoot(render(model, myTracedView));
      return response([current, mySubs, myCmds]);
    }
    
    
    // if receiving an (encoded) message
    if (get("/msg") := req) {
      
      // decode it into a Msg value in four steps
      // - construct a handle from the request's params
      // - decode it, to obtain a message decoder
      // - apply the decoder to the additional values in req.params
      // - apply all message transformers that were in scope for handle
      Msg msg = params2msg(req.parameters, mapEm, decode);
      
      
      println("Processing: <msg>");
      trace += [msg];
      if (size(trace) > 50) {
        trace = trace[1..];
      }
      
      // update the model
      // TODO: lets avoid the captured model variable here...
      <model, myCmds> = update(msg, model);
      
      // compute the new view
      Html newView = asRoot(render(model, myTracedView));
      
      // compute the patch to be sent to the browser
      Patch p = diff(current, newView);
      
      // update the current view
      current = newView;
      
      list[Sub] mySubs = subs(model);
      //println("Mysubs: <mySubs>");
      
      // send the patch.
      return response([p, mySubs, myCmds]); 
    }
    
    // everything else is considered static files.
    if (get(p:/\.<ext:.*>$/) := req, ext in mimeTypes) {
      return fileResponse(static[path="<static.path>/<p>"], mimeTypes[ext], ());
    }
    
    // or not found
    return response(notFound(), "not handled: <req.path>");
  }

  return <
    () { state.running = true; serve(http, _handle); }, 
    () { state.running = false; shutdown(http); },
    (void(&T) v, &T(Msg, &T) u) { view = v; update = u; }
   >;
}