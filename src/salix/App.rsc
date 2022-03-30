@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}
@contributor{Jouke Stoel - stoelm@cwi.nl - CWI}

module salix::App

import salix::Node;
import salix::Core;
import salix::Diff;
import salix::Patch;

import util::Webserver;
import util::Maybe;
import IO;
import String;

data Msg;

@doc{The basic Web App type for use within Rascal.}
alias App[&T] = Content;

@doc{SalixRequest and SalixResponse are HTTP independent types that model
the basic workflow of Salix.}
data SalixRequest
  = begin()
  | message(map[str, str] params)
  ;
  
data SalixResponse
  = next(list[Cmd] cmds, list[Sub] subs, Patch patch)
  ;
  
@doc{A function type to describe a basic SalixApp without committing to a 
particular HTTP server yet. The first argument represents the unique id of this application, 
which also must correspond to the DOM element with that string as id.
This allows using one web server to serve/multiplex different Salix apps
on a single page.}
alias SalixApp[&T] = tuple[str id, SalixResponse (SalixRequest) rr];

@doc{Construct a SalixApp over model type &T, providing a view, a model update,
and optionally a list of subscriptions, and a possibly extended parser for
handling messages originating from wrapped "native" elements.}
SalixApp[&T] makeApp(str appId, &T() init, void(&T) view, &T(Msg, &T) update, 
  Subs[&T] subs = list[Sub](&T _) {return [];}, Parser parser = parseMsg, bool debug = false) {
   
  Node asRoot(Node h) = h[attrs=h.attrs + ("id": appId)];

  Node currentView = empty();
  
  Maybe[&T] currentModel = nothing();
   
  SalixResponse transition(list[Cmd] cmds, &T newModel) {

    list[Sub] mySubs = subs(newModel);
    
    Node newView = asRoot(render(newModel, view));
    Patch myPatch = diff(currentView, newView);

    currentView = newView;
    currentModel = just(newModel);
    
    return next(cmds, mySubs, myPatch);
  }
 

  SalixResponse reply(SalixRequest req) {
    // this makes scoping/multiplexing of Salix apps possible
    // without polluting user-space code with non-compositional ids.
    switchTo(appId); // Note also switchFrom in the finally clause.

    switch (req) {

      // initially, just render the view, for the initial model.
      case begin(): {
        currentView = empty();
        <cmds, model> = initialize(init, view);
        SalixResponse resp = transition(cmds, model);
        switchFrom(appId);
        return resp;
      } 

	  // otherwise parse the message and do transition
      case message(map[str,str] params): {
        Msg msg = params2msg(params, parser);
        
        if (debug) {
          println("Processing: <appId>/<msg>");
        }
        
        <cmds, newModel> = execute(msg, update, currentModel.val);
        SalixResponse resp = transition(cmds, newModel);
        switchFrom(appId);
        return resp;
      }
      
      default: throw "Invalid Salix request <req>";
   }	   
  }
  
  return <appId, reply>;
}

@doc{Turn a single Salix App into a web application. The index parameter should point to the local file which holds the index html.
The static parameter should point to the base directory from where static files should be served}
App[&T] webApp(SalixApp[&T] app, loc index, loc static, map[str,str] headers = ()) {
  Response respondHttp(SalixResponse r)
    = response(("commands": r.cmds, "subs": r.subs, "patch": r.patch), header = headers);
 
  Response _handle(Request req) {
    if (get("/") := req) {
      return fileResponse(index, mimeTypes["html"], headers);
    } 
    
    if (get(p:/\.<ext:[^.]*>$/) := req) {
      return fileResponse(static[path="<static.path>/<p>"], mimeTypes[ext], headers);
    }
    
    list[str] path = split("/", req.path);
    
    
    if (get("/<app.id>/init") := req) {
      return respondHttp(app.rr(begin()));
    }
    if (get("/<app.id>/msg") := req) { 
      return respondHttp(app.rr(message(req.parameters)));
    }
     
    return response(notFound(), "not handled: <req.path>");
  }
  
  return content(app.id, _handle);
} 


tuple[void () serve, void () stop] standalone(loc host, App[&T] webapp) 
  = < void () { 
        util::Webserver::serve(host, webapp.callback); 
        println("Started serving Salix webapp at <host>");
      },
      void () { 
        util::Webserver::shutdown(host); 
      } >;