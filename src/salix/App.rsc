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
import IO;
import String;
import Map;
import List;

data Msg;

@doc{The basic App type:
- serve to start serving the application
- stop to shutdown the server}
alias App[&T] = tuple[void() serve, void() stop];


alias MVU[&T] = tuple[&T() init, void(&T) view, &T(Msg,&T) update];

data SalixRequest
  = begin()
  | message(map[str, str] params)
  ;
  
data SalixResponse
  = next(list[Cmd] cmds, list[Sub] subs, Patch patch)
  ;
  
alias SalixApp[&T] = SalixResponse(SalixRequest, str);

SalixApp[&T] makeApp(&T() init, void(&T) view, &T(Msg, &T) update, Subs[&T] subs = noSubs, Parser parser = parseMsg) {
  
  Node asRoot(Node h, str scope) = h[attrs=h.attrs + ("id": scope)];

  Node currentView = empty();
  
  &T currentModel;
  
  SalixResponse transition(list[Cmd] cmds, &T newModel, str scope) {

    list[Sub] mySubs = subs(newModel);
    
    Node newView = asRoot(render(newModel, view), scope);
    Patch myPatch = diff(currentView, newView);

    //iprintln(myPatch);
    currentView = newView;
    currentModel = newModel;
    
    return next(cmds, mySubs, myPatch);
  }


  return SalixResponse(SalixRequest req, str scope) {
    // initially, just render the view, for the initial model.
    switch (req) {
      case begin(): {
        currentView = empty();
        <cmds, model> = initialize(init, view);
        return transition(cmds, model, scope);
      }
      case message(map[str,str] params): {
        Msg msg = params2msg(params, parser);
        println("Processing: <scope>/<msg>");
        <cmds, newModel> = execute(msg, update, currentModel);
        return transition(cmds, newModel, scope);
      }
      default: throw "Invalid Salix request <req>";
    }
  };
}

App[&T] webApp(SalixApp[&T] app, loc http, loc static, str scope = "root") { 

  Response respondHttp(SalixResponse r)
    = response(("commands": r.cmds, "subs": r.subs, "patch": r.patch));

  Response _handle(Request req) {
    switch (req) {
      case get("/<scope>/init"):
        return respondHttp(app(begin(), scope));
    
      case get("/<scope>/msg"): 
        return respondHttp(app(message(req.parameters), scope));
      
      case get(p:/\.<ext:[^.]*>$/):
        return fileResponse(static[path="<static.path>/<p>"], mimeTypes[ext], ());

      default: 
        return response(notFound(), "not handled: <req.path>");
    }
    
  }

  return <
    () { println("Serving at (scope = <scope>): <http>"); serve(http, _handle); }, 
    () { shutdown(http); }
   >;
}

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


    if (get("/<root>/init") := req) {
      currentView = empty();
      <cmds, model> = initialize(init, view);
      return transition(cmds, model);
    }
    
    
    // if receiving an (encoded) message
    if (get("/<root>/msg") := req) {
      //println("Parsing request: <req.parameters>");
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

