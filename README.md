
## Salix: Elm-style Web GUIs in Rascal (work in progress)

© Tijs van der Storm [@tvdstorm](https://twitter.com/tvdstorm) 

DISCLAIMER: this very much work in progress; the design may change in significant ways, especially on the Javascript side of things.  

Salix is Rascal library for developing Web-based GUI programs. It emulates the [Elm Architecture](https://guide.elm-lang.org/architecture/), but since Rascal does not run in the browser (yet), all user code written in Rascal is executed on the server. HTML patches are sent to the browser and the browser sends messages back to the server, where they are interpreted on the model, to construct the new view. 

The concepts described below are shamelessly copied from Elm; this document describes merely how they are realized in the context of Rascal.

### Teaser: a web-based, live IDE for a simple state machine DSL

(Click to open the video)

[![ScreenShot](https://raw.github.com/cwi-swat/salix/master/resources/salix-ide.png)](https://youtu.be/2S9YL8u6Tes)

### A Counter Application

Salix is best understood through an example. Here we describe a simple counter application.

First we define the model, which is simply an integer:

```rascal
    alias Model = int;
```

The initial model is 0:
    
```rascal
    Model init() = 0;
```

The model is changed by interpreting messages. In Salix, all messages are of the `Msg` type. Other components might extend the same algebraic data type `Msg` for their own purposes. Here we have two messages: one to increment the counter and one to decrement it. 

```rascal
    data Msg = inc() | dec();
```

The evaluator (conventionally called `update`) can be implemented as follows:

```rascal
	Model update(Msg msg, Model model) {
	  switch (msg) {
	    case inc(): model += 1;
	    case dec(): model -= 1;
	  }
	  return model;
	}
```
Note that the `+=` and `-=` notation seems to suggest we're doing in-place mutation of the model here, this is not the case (even if the model is a tuple or constructor): Rascal's assignments will create a new model and assign it to the model variable. 

With the model and the `update` function in place, we can now define a view as follows: 

```rascal
    void view(Model m) {
      div(() {
        h2("My first counter app in Rascal");
        button(onClick(inc()), "+");
        div(m.count);
        button(onClick(dec()), "-");
      });
    }
```

A few notes are in order here. A view in Salix is a function from a model (in this case, of type `Model`) to `void`. Views defined in this style call HTML generating functions defined in the `salix::HTML` module, which are all `void` functions too.  Consider the `void` functions as "drawing" functions, painting HTML structure on an implicit canvas. This imperative style has the advantage that all regular control-flow constructs of Rascal can be used during view construction. Notice how `void` closures are used to express nesting.

The `button` elements receive attributes to setup event-handling. In this case, the `onClick` attribute wraps an `Msg` value to indicate that this message must be sent if the button is clicked. The main render loop will forward such messages to `update` to obtain a new model value, which in turn is used to create the updated view.

Now that we've defined all required components of a simple Salix app, how do we tie it all together? 
First we define a function to make a `SalixApp` using the `makeApp` function: it takes a unique identifier (as string), a function to produce the initial model, a view function and an update function.
Salix applications could be served via other protocols than http, hence a `SalixApp` is a general model of the application.

```rascal
    SalixApp[Model] counterApp(str appId = "counterApp") = makeApp(appId, init, view, update);
```
In the above example we have bound the `appId` using a keyword parameter. This means, if wanted, a user can give this application another id (see the section on Nesting Multiple Salix Apps).


Now we can create a web application using the `webApp` function. 
This function takes a `SalixApp`, the location of the index html file and the base directory for all other files that need to be served statically.
Here's the definition of the counter web app: 

```rascal
    App[Model] counterWebApp() 
      = webApp(counterApp(), |file:///.../index.html|, |file:///...|); 
```

The returned value of type `App[Model]` is a special Rascal type called `Content`. Whenever the Rascal REPL interprets this type a webserver 
will automatically be started and its content shown in a tab in the IDE.

So starting our counter application in the REPL is nothing more than importing the module and calling the function:

```rascal
    rascal> import Counter;
     ok
    rascal> counterWebApp();
     Serving visual content at |http://localhost:9050/|
```

And that's it! You can use the counter app directly in the IDE or click on the link to open it in your favorite browser.

Wait, we forgot one thing. Here's the minimally required `index.html`  file need to run Salix apps:

```html
	<!DOCTYPE html>
	<html>
	  <script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
	  <script src="<somewhere>/salix.js"></script>
	  <script>$(document).ready(new Salix("counterApp").start);</script>
	  <body><div id="counterApp"></div></body>
	</html>
```

Salix currently requires JQuery to do Ajax calls. 
Both the Salix javascript object and the `div` that will hold the apps content must have the same name as the given id. In this case it is "counterApp".

### Nesting Components by Mapping

Applications encapsulate their own models and sets of messages. 
Nesting multiple application (aka multiple `SalixApp`) is straightforward. 

As an example, let's consider an app that contains the counter app twice. 
Clicking increment or decrement on either of the counters should not affect the other. 
Here's how to implement this in Salix:

```rascal
    import Counter;
    import salix::HTML;
    
    // combine two counter models
    alias ModelTwice = tuple[Model counter1, Model counter2];
    
    // extend Msg
    data Msg = sub1(Msg msg) | sub2(Msg m);
    
    // update
    ModelTwice updateTwice(Msg msg, ModelTwice model) {
      switch (msg) {
        case sub1(Msg m): model.counter1 = update(m, model.counter1);
        case sub2(Msg m): model.counter2 = update(m, model.counter2);
      }
      return model;
    }
    
    // define the view
    void viewTwice(ModelTwice model) {
      div(() {
        mapView(sub1, model.counter1, view);
        mapView(sub2, model.counter2, view);
      });
    } 
```

The important bit here is that the `view` function of the counter app is embedded twice, via the special `mapView` function. It takes as its first argument a function of type `Msg(Msg)` (i.e., a message transformer), a model as its second argument, and a view (of type `void(&T)`) as its last argument. In this case we provide the `sub1` and `sub2` constructors as message transformers. The function `mapView` now ensures that whenever a message is received that originates from the first counter it is wrapped in `sub1`, and that any message from the second counter is wrapped in `sub2`. For instance, `inc()` from the first counter will be wrapped as `sub1(inc())` and passed to `updateTwice` who will route it to `update` on `m.counter1`. Same for the second counter.

If we didn't use mapping here, the function `updateTwice` could directly interpret `inc()` and `dec()`, but it wouldn't know which counter model to update! Alternatively, however, you shouldn't use mapping if you *want* two views sharing the same model. In this case, there's no need for routing of messages, and the two `view` functions can be simply called twice, on the same model. For instance, like this:

```rascal
    void viewTwice(Model model) {
      div(() {
        view(model);
        view(model);
      });
    }
```

    
### Subscriptions

Subscriptions can be used to listen to events of interest which are not produced by users interacting with the page. 
Examples include incoming data on Web sockets, or timers. 
In Salix these are represented by the type `Sub` (defined in `salix::Core`). 
Currently, there's only one: 

```rascal
	timeEvery(str appId, Msg(int) time2msg, int interval) 
```

To be notified of subscriptions, provide a function of type `list[Sub](str,&T)` (where `&T` represents your model type and `str` the bound application id) to the `subs` keyword parameter of `app`.

As as example, let's say we'd like to automatically increment our counter every 5 seconds. This can be achieved as follows:

```rascal
	import salix::Core; // defines the Sub ADT

	data Msg  // extend Msg to respond to timeEvery subscription
     = ...
     | tick(int time);

	list[Sub] counterSubs(str appId, Model m) = [timeEvery(appId, tick, 5000)];
	
	Model update(Msg msg, Model model) {
	  switch (msg) {
	    ...
	    case tick(_): model += 1;
	  }
	  return model;
	}
```	
	
This code states that every 5 seconds we will be notified of the event through the message `tick` which will contain the current time. The `update` function is changed to modify the model as intended.

Finally modify the invocation to `app` as follows:

```rascal
	SalixApp[Model] counterApp() = makeApp(..., subs = counterSubs);
```

If your nested components have subscriptions, you need to map them in the same way that views are mapped, but this time using `mapSubs`. For instance, here's how to map the subscriptions of each counter to combine them into a list of subscriptions of `counterTwice`, assuming the counter app defines its list of subscriptions for a model as `counterSubs(Model m)`:

```rascal
	list[Sub] subsTwice(ModelTwice m)
	  = mapSubs(sub1, m.counter1, counterSubs)
	  + mapSubs(sub2, m.counter2, counterSubs);
```

### Commands

Commands are used to trigger side-effects. Instead of simply returning a new model in `update`, this function will now also "do" commands. Commands are values of the type `Cmd`. The helper function `do` can be used to "execute" commands. Whenever you call `do`, however, the command is merely *scheduled* for execution in the runtime (client). The top-level `app` function will collect all commands that have been "done" during `update` (or `init`) and send them over to the client for actual execution.

So, let's add some additional logic to the counter applicaiton: whenever you press the increment button, we'll generate a command to add some random "jitter" to the counter value.
Here's how:

```rascal
	data Msg = ... | jitter(int j);
	
	Model update(Msg msg, Model model) {
	 
	  switch (msg) {
	    case inc(): {
	      model += 1;
	      do(random(jitter, -10, 10));
	    }
	    ...
	    case jitter(int j):
	      model += j;
	  }

	  return model;
	}
```
	

We've added a new message, `jitter` with an integer argument. The `update` function is modified so that whenever the counter is incremented, we'll do that, but also produce a command using `do`, in this case the predefined `random` command which will generate a random integer in the provided range. When the resulting random number is sent back it will be wrapped in a `jitter` message. The `update` function uses this message to add "jitter" to the counter value.

Just like views and subscriptions, commands should be mapped whenever components are nested. Here's how `mapCmds` can be used to wrap commands generated by childeren in the `twice` app:

```rascal
    ModelTwice updateTwice(Msg msg, ModelTwice model) {
      switch (msg) {
        case sub1(Msg m): model.counter1 = mapCmds(sub1, m, model.counter1, update);
        case sub2(Msg m): model.counter2 = mapCmds(sub2, m, model.counter2, update);
      }
      return model;
    }
```

### Guide to the modules

- [salix::App](https://github.com/cwi-swat/salix/blob/master/src/salix/App.rsc): defines the top-level `makeApp` and `webApp` functions and defines the `SalixApp[&T]` and `App[&T]` data type.

- [salix::HTML](https://github.com/cwi-swat/salix/blob/master/src/salix/HTML.rsc), [salix::SVG](https://github.com/cwi-swat/salix/blob/master/src/salix/SVG.rsc): define  HTML5 resp. SVG elements and attributes as convenient functions. All element functions (such as `div`, `h2`, etc.) accept a variable sequence of `value`s (i.e. they are "vararg" functions). All values can be attributes (as, e.g., produced by `onClick`, `class` etc.). The last value (if any) can also be either a block (of type `void()`), a `Node`, or a plain Rascal value. In the latter case, it's converted to a string and rendered as an HTML text node.  

- [salix::Core](https://github.com/cwi-swat/salix/blob/master/src/salix/Core.rsc): contains the logic of representing and mapping handlers, commands, and subscriptions in such a way that they can be sent to and received from the browser. Import this if you use subscriptions, if you need mapping (see above), or if you're defining your own events, commands or subscriptions. 

- [salix::Node](https://github.com/cwi-swat/salix/blob/master/src/salix/Node.rsc): defines the `Node` data type for representing views. Only needed if you define your own attributes or elements. 

- [salix::Diff](https://github.com/cwi-swat/salix/blob/master/src/salix/Diff.rsc), [salix::Patch](https://github.com/cwi-swat/salix/blob/master/src/salix/Patch.rsc): internal modules for diffing and patching `Node`. You should never have to import these modules. 

#### Example programs

- [salix::demo::basic::Celsius](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/basic/Celsius.rsc): celsius to fahrenheit converter; demonstrates `onInput`.

- [salix::demo::basic::Counter](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/basic/Celsius.rsc): increase and decrease a counter; demonstrates `onClick`.

- [salix::demo::basic::Random](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/basic/Random.rsc): random dice; demonstrates commands.

- [salix::demo::basic::Loop](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/basic/Loop.rsc): run loops via commands; pathological example of commands.

- [salix::demo::basic::Clock](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/basic/Clock.rsc): clock using SVG; demonstrates subscriptions.

- [salix::demo::basic::All](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/basic/All.rsc): combines all previous (basic) demos; demonstrates combining different Salix applications into a single app.

- [salix::demo::shop::Shop](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/shop/Shop.rsc): a simple shop application (adapted from the [Mobx shop demo](https://www.mendix.com/tech-blog/making-react-reactive-pursuit-high-performing-easily-maintainable-react-apps/)).

- [salix::demo::todomvc::TodoMVC](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/todomvc/TodoMVC.rsc): a 90% implementation of [TodoMVC](http://todomvc.com/), ported from [TodoMVC in Elm](https://github.com/evancz/elm-todomvc). 

- [salix::demo::ide::IDE](https://github.com/cwi-swat/salix/blob/master/src/salix/demo/ide/IDE.rsc): simple live programming IDE for a state machine DSL; includes embedded [CodeMirror](http://codemirror.net/) and [xterm.js](http://xtermjs.org/) REPL.


### Extending the Framework

Extending the framework with new events, commands or subscriptions is facilitated by Rascal's extensible data types. In all cases, you define functions to produce handlers (`Hnd`), commands (`Cmd`) or subscriptions (`Sub`). Since all three of those values are sent over the wire, they have to be encoded. The framework provides functions to do so. Handlers, commands and subscriptions produce results, which are sent back to the server. This means that you'll also have to extend the parser to turn received data into a proper message of type `Msg`, if the type of data is not supported by the built-in parser (i.e. `nothing`, `string`, `integer`, or `boolean`). In some cases the Javascript needs to be modified in order to accommodate the construct. 

#### Events

An event is defined using the following pattern:

```rascal
	Attr <eventName>(Msg(...) something2msg) 
	  = event("<eventName>", handler("<handler>", encode(something2msg));
```

This code defines an event function named `eventName`, accepting a function to map some event data to a `Msg`. It is defined using the `event` constructor which takes the name of the event and a "handler". Handlers are used to process event data such that it can eventually be fed into the argument function `something2msg`. Handlers thus are specific for such functions. The handler also encapsulates an encoded representation of the function needed to decode the event data.

Standard handlers include `succeed(Msg)` which simply returns the argument message when the event succeeds; `targetValue(Msg(str))` feeds the value property of the target element of the event into the argument function to obtain a message; and `targetChecked(Msg(bool))` which can be used on checkboxes and radio buttons. These are ready to use in your event definitions. 

If the standard handlers are not sufficient, you can also define your own, by defining functions that produce `Hnd` values. As an example, `targetValue` is defined as follows:

```rascal
	Hnd targetValue(Msg(str) str2msg) = handler("targetValue", encode(str2msg));
```

The reverse is also needed: turning a handle received from the client into the corresponding message as produced by the handler function. This is performed by interpreting the type of the result (represented as a string). Such a result is then converted to a message on the server. For instance, the result of `targetValue` is parsed using the following function:

```rascal
    Msg parseMsg(str appId, "string", Handle h, map[str,str] p) 
      = applyMaps(appId, h, decode(appId, h, #Msg(str))(p["value"]));
```

The function `parseMsg` receives three parameters: first the type of the result (used to dispatch the parse function); second, the `Handle` as received from the client, and third the map of request data that was received from the client.  The `decode` function is used to decode the handle into a function `Msg(str)`, which is then applied to the request parameter `value` to obtain a message. The function `applyMaps` then transforms the resulting message according to the mappers that were active at the time this handle was produced. You should always apply this function, otherwise mapping (see above) won't work.  

You can define a new parser in a similar way, this time dispatching on a different type string. Note, that this also requires modifying the `salix.js` Javascript code to actually produce these new results. Furthermore, the function extension won't be in scope automatically at the top-level `app` function. Thus, before calling `app`, make sure all required parsers are in scope at the call-site, and provide `parseMsg` to the `parser` keyword parameter of `app`. 

#### Subscriptions & Commands 

Salix can be extended with new kinds of subscriptions and commands, similar to how new handlers are defined (e.g., `targetValue`. The only difference is that instead of the `Hnd` type and the `handler` constructor, you now use `Cmd` and `command`, and `Sub` and `subscription` types and constructors, respectively.  

#### Embedding "native" Javascript components

TBD

## Discussion

#### Why are HTML nodes and commands dealt with implicitly?

Salix view functions are defined as `void(&T)`, and update functions have type `&T(Msg, &T)`. 
In the first case, HTML nodes are implicitly constructed; in the second case, commands are implicitly collected. 

As mentioned above, the style of view functions, IMHO, leads to a better programming experience in Rascal, since it allows the use of ordinary control-flow constructs when programming views. In a purely functional, expression-oriented style, it would mean to simulate such control-flow using inline `c ? t : e` conditionals or comprehensions; the use of comprehensions puts the conditions at the end (which can be awkward), and requires visually distracting brackets or parentheses, suggesting nestings that are not there (e.g., nested lists will be flattened away).  
 
For commands the story is somewhat similar: they need to be threaded through and returned from update functions. Rascal does not have syntactic sugar to make this "monadic" style convenient. So explicit threading would require annoying boilerplate code to get commands up to the main loop. Since the HTML nodes are produced implicitly anyway, doing commands implicitly is a compatible design choice. Finally, it's part of Rascal's design itself to be a hybrid functional programming language, in the sense that many idioms and constructs look imperative, without breaking referential transparency. Implicit propagation of commands and construction of HTML ties into that hybrid style.

The effects of views (in terms of DOM construction) and update functions (in terms of generated commands) are captured by the following two functions: 

```rascal
   // turn a message, update function and current model into new model + list of commands
   tuple[list[Cmd], &T] execute(Msg msg, &T(Msg, &T) update, &T model);
   
   // render a model through a view function to obtain a Node
   Node render(&T model, void(&T) view);
```
The function `execute` creates an updated model including a list of generated commands. The function `render` turns a `void` view function in a `Node` structure for some model. Both are called by the top-level `app` function; you should probably never have to call them yourself, except if you'd like to inspect nodes or commands for debugging purposes.  

The current design leads to the following rule of thumb for the application programmer: `update`, `init` or `view` functions should *never* be called directly. As soon as you call  do this, you're bound to break important invariants maintained by the framework.

#### Why is mapping part of the framework?

You'd think it would easy to realize mapping just using a standard `map` function, or comprehensions. You could just simply transform an embedded function, say of type `Msg(int)` using a transformer `Msg(Msg)`. The transformed function would simply be attached at right position in the `Node` tree, -- nothing special.

Unfortunately, such transformed embedded functions can't be serialized over the wire. That's why they are encoded. When receiving a result, the encoding is used to find the original function again. This requires equality on functions. Function equality in Rascal is tricky: two functions are considered equal if they correspond to the same declaration, or if they are *exactly* the same closure (i.e. created at the same execution point). This basically means that you cannot use inline closures as handlers, because on every render, they will lead to new identities, and hence, spurious event handler updates in the browser.  

The same holds for arguments to the mapping functions. Basically this means that you only nest components that are statically known :-(. For instance, a generic editable-list component won't work, since such a component will nest a statically unknown number of element components.


#### Why only a single, universal Msg type?

In Elm, the type for nodes and attributes is parametric on the application defined message type. This adds another level of additional type checking: you can't simply nested HTML generated for one component inside another, because their message types won't match. The type system thus enforces "mapping". Furthermore, the update functions can be checked for completeness, since there's no overlap between constructors from one message type and another. 

In Salix, I've opted to not make the node and attribute types parametric, since the generics of Rascal are rather verbose. All messages are thus represented by the universal `Msg` type. Rascal supports extension of algebraic data types, so each component will simply add their message constructors as they see fit. Note however, that the application programmer has a slightly bigger obligation to make sure that mapping is performed where needed, and that all (relevant) messages are handled correctly.  

#### How to communicate from child to parent?

Whenever a component is nested inside another one, the mapping of command and event messages ensures that messages created in a child component will be routed back to that very same child component. Sometimes, however, you'd like to communicate message *up*, because the responsibility of handling them lies outside the local level.
 
Here's an example. Imagin a read-eval-print-loop (REPL) component showing a commandline where commands can be entered. The REPL is in charge of maintaining history, printing the prompt, interpreting key strokes etc. Whenever the user presses enter however, some command or expression needs to be evaluated, but this is not the responsibility of the REPL itself: the effect of evaluation depends on what the REPL is used for, probably defined in its container. 

Part of the solution is to pass down an `eval` function to the `update` function of the REPL component. Whenever the user now presses enter, the REPL will call that `eval` function, and print out the result at the command line. This is only half the story however: often the evaluation of a command also requires some domain-specific effect outside the REPL itself. How do we get it there? We can't simply trigger messages from the REPL, since nesting the REPL in some context using mapping will make them "local" to the REPL.

A solution is to model such child-parent communication through dedicated message constructors which are to be intercepted by the container. In our simplified REPL example, let's say we have the following update function which receives an additional `eval` function as a parameter. This eval function returns a parent-level message encapsulating what needs to be done upon command evaluation.

```rascal
   data Msg
     = enter(str x)
     ...
     | parent(Msg msg);
    
    ReplModel updateRepl(Msg msg, ReplModel model, Msg(str) eval) {
      switch (msg) {
        case enter(str x): 
          do(write(parent(eval(x)), "ok"));
        ...
      }
    }
```

Whenever the user enters a command (`enter(str)`), the REPL responds by evaluating the command and writing ok to the command line. The command `write` in turn triggers the message returned by `eval` wrapped in the `parent` constructor. The `parent` constructor here functions as the dedicated *up* message constructor.

At the container level, we might have something like this:

```rascal
   Msg eval(str x) {
     str y = ...; // do some eval
     return result(y);
   }

   data Msg
     = ...
     | result(str x)  // result of command eval
     | repl(Msg msg); // repl messages
     
   Model updateMain(Msg msg, Model model) {
     switch (msg) {
       case repl(parent(result(str x))):
          // interpret result 
          
       case repl(Msg sub):
         model.repl = mapCmds(Msg::repl, sub, model.repl, 
             ReplModel(Msg m, ReplModel rm) { return updateRepl(m, rm, eval); });  
     }   
   }
```

The first key thing to note here, is that eval is passed to `updateRepl` using an anonymous function. So eval is communicated *down*. Second, the function `updateMain` intercepts the `parent` `repl` message by pattern matching on `msg`, in this case only intercepting the `result(str)` message. Because this case comes before the normal `repl` message handling, it will prevent the REPL from handling a message it does not know about (`result(str)`). 

So update functions can not only pass arbitrary additional data down the component tree, but they also can intercept messages coming in from above, but headed downwards, for specific purposes. 

#### How are lists of commands executed?

Lists of commands are executed in sequence, causing one synchronous roundtrip to the server at every step. Commands are furthermore always executed before any (queued) events are handled, because commands might invalidate the UI that was actual at the time of queueing such events. It's perfectly possible to starve the UI by producing an infinite command loop. 

One invocation of a model update function might produce a list of commands. Since every message sent back to the server produces a new model, this means that messages from consecutive commands, will be processed in the context of consecutive models, and *not* on the original model that produced the list of commands in the first place. Worse, if such intermediate steps on the model produce commands themselves, they are executed first, before continuing on the remainder of the original list of commands. 

*Aside*: this describes the current situation of the implementation; I'm unsure of the general semantics of sequences of commands produced by a single `update` step. An obvious way out would be to disallow sequences of commands and only allow a single one per update; but, on the other hand, this seems overly restricted and inflexible. 

#### Why is it 'slow'?

Since Rascal does not run in the browser, all communication between user events and commands and the main application loop requires HTTP communication. Basically, all code in Rascal is executed on the server, including differencing of two views. Patches are sent to the browser which updates the actual DOM accordingly, executes commands (if any), and sends back messages (from commands, subscriptions or user events). Then the cycle repeats.

Moreover, to guarantee that model and view evolve in lock-step, the communication between client and server is *synchronous*. This means, events occurring during processing of a previous event (or command) are queued up until the new view is ready. When processing a queued event, Salix detects if it is still valid with respect to the current view before starting to handle it; if an event turns out to be stale (because its handler has been removed, or it's node is not attached to the DOM anymore), it's discarded. Subscription events are treated just like user events, except that staleness is currently not detected. It is therefore possible to retrieve notifications of a subscription *after* you've stopped subscribing to it.

In my experience however, which is as of yet rather limited I must admit, average performance is just fine for many use cases. For doing things like animations, however, the possible latencies introduced by HTTP might present a problem. Fortunately, there are enough use cases left that don't require that kind of performance. Note further that Salix is not meant for developing *web* applications; it's meant to develop browser-based GUI applications. It's not a goal to serve Salix apps over the WWW; HTTP just represents a transport layer for messages, until Rascal can be run in the browser itself.  

 

