@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::App

import salix::Node;
import salix::Core;
import salix::Diff;
import salix::Patch;

import util::Webserver;
import util::Reflective;
import IO;
import String;
import Map;
import List;

private loc libRoot = getModuleLocation("salix::App").parent.parent;

data Msg;

@doc{The basic App type:
- serve to start serving the application
- stop to shutdown the server}
alias App[&T] = tuple[void() serve, void() stop];

@doc{Construct an App over model type &T, providing a view, a model update,
a http loc to serve the app to, and a location to resolve static files.
The keyword param root identifies the root element in the html document.}
App[&T] app(&T() init, void(&T) view, &T(Msg, &T) update, loc http, loc static, 
            Subs[&T] subs = noSubs, str root = "root", Parser parser = parseMsg) { 

  Node asRoot(Node h) = h[attrs=h.attrs + ("id": root)];

  Node currentView = empty();
  
  &T currentModel;
  
  Response transition(list[Cmd] cmds, &T newModel ) {

    list[Sub] mySubs = subs(newModel);
    
    Node newView = asRoot(render(newModel, view));
    Patch myPatch = diff(currentView, newView);

    //iprintln(myPatch);
    currentView = newView;
    currentModel = newModel;
    
    return response(("commands": cmds, "subs": mySubs, "patch": myPatch));
  }


  Response _handle(Request req) {
    // initially, just render the view, for the initial model.

    if (get("/init") := req) {
      currentView = empty();
      <cmds, model> = initialize(init, view);
      return transition(cmds, model);
    }
    
    
    // if receiving an (encoded) message
    if (get("/msg") := req) {
      //println("Parsing request: <req.parameters>");
      Msg msg = params2msg(req.parameters, parser);
      <cmds, newModel> = execute(msg, update, currentModel);
      return transition(cmds, newModel);
    }
    
    // everything else is considered static files.
    if (get(p:/\.<ext:[^.]*>$/) := req, ext in mimeTypes) {
      if (exists(libRoot + p)) {
        return fileResponse(libRoot + p, mimeTypes[ext], ());
      }
      else {
        return fileResponse(static[path="<static.path>/<p>"], mimeTypes[ext], ());
      }
    }
    
    // or not found
    return response(notFound(), "not handled: <req.path>");
  }

  return <
    () { println("Serving at: <http>"); serve(http, _handle); }, 
    () { shutdown(http); }
   >;
}

