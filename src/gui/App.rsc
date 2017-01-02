module gui::App

import gui::Node;
import gui::Core;
import gui::Diff;
import gui::Patch;

import util::Webserver;
import IO;
import String;
import Map;
import List;

data Msg;

@doc{The basic App type:
- serve to start serving the application
- stop to shutdown the server}
alias App[&T] = tuple[void() serve, void() stop];


WithCmds[&T](Msg, &T) emptyCmds(&T(Msg, &T) update)
  = WithCmds[&T](Msg m, &T t) { return noCmds(update(m, t)); };

@doc{Internal app state}
alias AppState = tuple[
  int id, // last assigned handle id
  map[int, value] from, // bijection between handle identities and decoder functions
  map[value, int] to
];


@doc{Helper function for apps that don't need commands.}
App[&T] app(&T model, void(&T) view, &T(Msg, &T) update, loc http, loc static, 
            Subs[&T] subs = noSubs, str root = "root") 
 = app(noCmds(model), view, emptyCmds(update), http, static, subs = subs, root = root);

@doc{Construct an App over model type &T, providing a view, a model update,
a http loc to serve the app to, and a location to resolve static files.
The keyword param root identifies the root element in the html document.}
App[&T] app(WithCmds[&T] modelWithCmds, void(&T) view, WithCmds[&T](Msg, &T) update, loc http, loc static, 
            Subs[&T] subs = noSubs, str root = "root") {

  AppState state = < -1, (), ()>;
  
  // encode functions (for handlers) as integers
  int myEncode(value x) {
    if (x notin state.to) {
      state.id += 1;
      state.from[state.id] = x;
      state.to[x] = state.id;
    }
    return state.to[x];
  }
  
  // retrieve the actual function corresponding to a handle identity.
  &U myDecode(int id, type[&U] t) = d
    when &U d := state.from[id];
  
  Node asRoot(Node h) = h[attrs=h.attrs + ("id": root)];

  Node current;

  &T model;

  // the main handler to interpret http requests.
  // BUG: mixes with constructors that are in scope!!!
  Response _handle(Request req) {
    // publish my encoder and decoder to gui::Encode.
    // todo: make a function.
    gui::Core::_encode = myEncode;
    gui::Core::_decode = myDecode;

    // initially, just render the view, for the current model.
    if (get("/init") := req) {
      model = modelWithCmds.model;
      list[Sub] mySubs = subs(model);
      list[Cmd] myCmds = modelWithCmds.commands;
      current = asRoot(render(model, view));
      return response([current, mySubs, myCmds]);
    }
    
    
    // if receiving an (encoded) message
    if (get("/msg") := req) {
      
      // decode it into a Msg value in four steps
      // - construct a handle from the request's params
      // - decode it, to obtain a message decoder
      // - apply the decoder to the additional values in req.params
      // - apply all message transformers that were in scope for handle
      Msg msg = params2msg(req.parameters);
      
      
      println("Processing: <msg>");
      
      // update the model
      <model, myCmds> = update(msg, model);
      
      // compute the new view
      Node newView = asRoot(render(model, view));
      
      // compute the patch to be sent to the browser
      Patch myPatch = diff(current, newView);
      
      // update the current view
      current = newView;
      
      list[Sub] mySubs = subs(model);
      //println("Mysubs: <mySubs>");
      
      // send the patch.
      return response([myPatch, mySubs, myCmds]); 
    }
    
    // everything else is considered static files.
    if (get(p:/\.<ext:[^.]*>$/) := req, ext in mimeTypes) {
      return fileResponse(static[path="<static.path>/<p>"], mimeTypes[ext], ());
    }
    
    // or not found
    return response(notFound(), "not handled: <req.path>");
  }

  return <
    () { println("Serving at: <http>"); serve(http, _handle); }, 
    () { shutdown(http); }
   >;
}

