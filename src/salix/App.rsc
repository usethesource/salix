module salix::App

import salix::Node;
import salix::Core;
import salix::Diff;
import salix::Patch;

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


@doc{Helper function for apps that don't need commands.}
App[&T] app(&T model, void(&T) view, &T(Msg, &T) update, loc http, loc static, 
            Subs[&T] subs = noSubs, str root = "root") 
 = app(noCmds(model), view, emptyCmds(update), http, static, subs = subs, root = root);

@doc{Construct an App over model type &T, providing a view, a model update,
a http loc to serve the app to, and a location to resolve static files.
The keyword param root identifies the root element in the html document.}
App[&T] app(WithCmds[&T] modelWithCmds, void(&T) view, WithCmds[&T](Msg, &T) update, loc http, loc static, 
            Subs[&T] subs = noSubs, str root = "root") {

  Node asRoot(Node h) = h[attrs=h.attrs + ("id": root)];

  Node currentView = empty();
  
  &T currentModel;
  
  Response transition(&T newModel, list[Cmd] myCmds) {
    
    if (myCmds != []) {
      return response([myCmds, [], patch(-1)]);
    }
    
    list[Sub] mySubs = subs(newModel);
    
    Node newView = asRoot(render(newModel, view));
    Patch myPatch = diff(currentView, newView);

    currentView = newView;
    currentModel = newModel;
    
    return response([[], mySubs, myPatch]);
  }

  // the main handler to interpret http requests.
  // BUG: mixes with constructors that are in scope!!!
  Response _handle(Request req) {
    
    // initially, just render the view, for the current model.
    if (get("/init") := req) {
      <newModel, myCmds> = modelWithCmds;
      return transition(newModel, myCmds);
    }
    
    
    // if receiving an (encoded) message
    if (get("/msg") := req) {
      //println("Parsing request");
      Msg msg = params2msg(req.parameters);
      println("Processing: <msg>");
      <newModel, myCmds> = update(msg, currentModel);
      return transition(newModel, myCmds);
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

