@license{
  Copyright (c) 2016-2017 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

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

@doc{Construct an App over model type &T, providing a view, a model update,
a http loc to serve the app to, and a location to resolve static files.
The keyword param root identifies the root element in the html document.}
App[&T] app(&T() init, void(&T) view, &T(Msg, &T) update, loc http, loc static, 
            Subs[&T] subs = noSubs, str root = "root", Parser parser = parseMsg) { 

  Node asRoot(Node h) = h[attrs=h.attrs + ("id": root)];

  Node currentView = empty();
  
  &T currentModel;
  
  
  Response transition(list[Cmd] cmds, &T newModel ) {
    currentModel = newModel;

    list[Sub] mySubs = subs(newModel);
    
    Node newView = asRoot(render(newModel, view));
    Patch myPatch = diff(currentView, newView);

    currentView = newView;
    
    return response(("commands": cmds, "subs": mySubs, "patch": myPatch));
  }


  Response _handle(Request req) {
    
    // initially, just render the view, for the current model.
    if (get("/init") := req) {
      currentView = empty();
      <cmds, model> = initialize(init, view);
      return transition(cmds, model);
    }
    
    
    // if receiving an (encoded) message
    if (get("/msg") := req) {
      //println("Parsing request");
      Msg msg = params2msg(req.parameters, parser);
      println("Processing: <msg>");
      <cmds, newModel> = execute(msg, update, currentModel);
      return transition(cmds, newModel);
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

