
## Elmer: Elm-style Web GUIs in Rascal

Elmer is Rascal library for developing Web-based GUI programs. It emulates the [Elm Architecture](https://guide.elm-lang.org/architecture/), but since Rascal does not run in the browser (yet), most user code written in Rascal is executed on the server. HTML is sent to the browser and the browser sends messages back to the server, where they are interpreted on the model, to construct the new view. 

The concepts described below are shamelessly copied from Elm; this document describes merely how they are realized in the context of Rascal.

### A Counter Application

Elmer is best understood through an example. Here we describe a simple counter application.

First we define the model, which is simply an integer:

    alias Model = int;

The initial model is 0:
    
    Model init() = 0;

The model is changed by interpreting messages. In Elmer, all messages are of the `Msg` type. Other components might extend the same algebraic data type `Msg` for their own purposes. Here we have two messages: one to increment the counter and one to decrement it. 

    data Msg = inc() | dec();

The evaluator (conventionally called `update`) can be implemented as follows:

    Model update(inc(), Model n) = n + 1;
    Model update(dec(), Model n) = n - 1;

Note that the pattern-based dispatch style of writing functions makes message interpretation open for extension.

With the model and the `update` function in place, we can now define the view as follows: 

    void view(Model m) {
      div(() {
        h2("My first counter app in Rascal");
        button(onClick(inc()), "+");
        div(m.count);
        button(onClick(dec()), "-");
      });
    }

A few notes are in order here. A view in Elmer is a function from a model (in this case, of type `Model`) to `void`. Views defined in this style call HTML generating functions defined in the `gui::HTML` module, which are all `void` functions too. You can use the `render` function in `gui::Render` to turn a view and a model into an actual `Node` value, but typically you should never have to call this explicitly. Consider the `void` functions as "drawing" functions, painting HTML structure on an implicit canvas. This imperative style has the advantage that all regular control-flow constructs of Rascal can be used during view construction. 

The top element of the counter view consists of a single `div`. Within the `div` there's an `h2` header element, two `button`s and a `div` showing the current model value. Notice how `void` closures are used to express nesting.

The `button` elements receive attributes to setup event-handling. In this case, the `onClick` attribute wraps an `Msg` value to indicate that this message must be sent if the button is clicked. The main render loop will forward such messages to `update` to obtain a new model value, which in turn is used to create the updated view.

Now that we've defined all required components of a simple Elmer app, how do we tie it all together? This is where the `app` function comes in: it takes an initial model, a view function, an update function, and two locations capturing the host+port configuration and the path to serve static assets from, respectively. Here's the definition of the counter app: 

    App[Model] counterApp() 
      = app(init(), view, update, |http://localhost:9197|, |file:///...|); 

The returned value of type `App[Model]` is a tuple containing function to start and stop the application, like so:

    counter = counterApp();
    counter.serve(); // start the application
    counter.stop(); // shut it down

And that's it! After calling `counter.serve()`, you can use the counter app at `http://localhost:9197/index.html`.

Wait, we forgot one thing. Here's the minimally required `index.html`  file need to run Elmer apps:

	<!DOCTYPE html>
	<html>
	  <script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
	  <script src="elmer.js"></script>
	  <script>$(document).ready(start);</script>
	  <body><div id="root"></div></body>
	</html>

Elmer requires JQuery to do Ajax calls. Elmer apps hook into the `div` with `id` "root" by default. This default can be overridden, however, through the `root` keyword parameter of the `app` function.

### Nesting Components by Mapping

Components encapsulate their own models and sets of messages. In order to nest components inside one another, parent components must route incoming messages to the originating child component. This is where "mapping" comes in.

As an example, let's consider an app that contains the counter app twice. Clicking increment or decrement on either of the counters should not affect the other. Here's how mapping solves this problem.

    import examples::Counter;
    import gui::HTML;
    
    // combine two counter models
    alias ModelTwice = tuple[Model counter1, Model counter2];
    
    // extend Msg
    data Msg = counter1(Msg msg) | counter2(Msg m);
    
    // update
    ModelTwice updateTwice(counter1(Msg msg), ModelTwice m) 
      = update(msg, m.counter1);

    ModelTwice updateTwice(counter2(Msg msg), ModelTwice m) 
      = update(msg, m.counter2);
    
    // define the view
    void viewTwice(ModelTwice model) {
      div(() {
        mapping.view(model.counter1, view);
        mapping.view(model.counter2, view);
      });
    }

The important bit here is that the `view` function of the counter app is embedded twice, via the special `mapping.view` function (exported by `gui::Comms`). It takes as its first argument a function of type `Msg(Msg)` (i.e., a message transformer), and a view (of type `void(&T)`) as its second argument. In this case we provide the `counter1` and `counter2` constructors as message transformers. The function `mapping.view` now ensures that whenever a message is received that originates from the first counter it is wrapped in `counter1`. For instance, `inc()` will be wrapped as `counter1(inc())` and passed to `updateTwice` who will route it to `update` on `m.counter1`. Same for `counter2`.

If we didn't use mapping here, the function `updateTwice` could directly interpret `inc()` and `dec()`, but it wouldn't know which counter model to update! Alternatively, however, you shouldn't use mapping if you *want* two views sharing the same model. In this case, there's no need for advanced routing of messages, and the two `view` functions can be simply called twice, on the same model. For instance, like this:

    void viewTwice(Model model) {
      div(() {
        view(model);
        view(model);
      });
    }

### Subscriptions

Subscriptions can be used to listen to events of interest which are not produced by users interacting with the page. Examples include incoming data on Web sockets, or timers. In Elmer these are represented by the type `Sub` (defined in `gui::Decode`). Currently, there's only one: 

	timeEvery(Msg(int) time2msg, int interval) 

To be notified of subscriptions, provide a function of type `list[Sub](&T)` (where `&T` represents your model type) to the `subs` keyword parameter of `app`.

As as example, let's say we'd like to automatically increment our counter every 5 seconds. This can be achieved as follows:

	import gui::Comms; // defines the Sub ADT

	data Msg  // extend Msg to respond to subscription
     = tick(int time);

	list[Sub] counterSubs(Model m) = [timeEvery(tick, 5000)];
	
	Model update(tick(_), Model n) = n + 1;
	
	
This code states that every 5 seconds we will be notified of the event through the message `tick` which will contain the current time. The `update` function is extended to modify the model as intended.

Finally modify the invocation to `app` as follows:

	App[Model] counterApp() = app(..., subs = counterSubs);
      
If your nested components have subscriptions, you need to map them in the same way as views are mapped, but this time using `mapping.subs`. For instance, here's how to map the subscriptions of each counter to combine them into a list of subscriptions of `counterTwice`, assuming the counter app defines its list of subscriptions for a model as `counterSubs(Model m)`:

	list[Sub] subsTwice(ModelTwice m)
	  = mapping.subs(counter1, m.counter1, counterSubs)
	  + mapping.subs(counter2, m.counter2, counterSubs);


### Commands

Commands are used to trigger side-effects. Instead of simply returning a new model in `update`, this function will now also return a (possibly empty) list of commands of type `Cmd`. This result is captured in the type `WithCmds[&T]` which is tuple of a model of type `&T` and a list of commands. The helper functions `noCmds(&T)` and `withCmds(&T, list[Cmd])` can be used to construct such result values.

As an example, here's the counter's `init` and `update` functions modified to cater for commands:

	WithCmds[Model] init() = noCmds(0);
	
	WithCmds[Model] update(inc(), Model n) = noCmds(n + 1);
	WithCmds[Model] update(dec(), Model n) = noCmds(n - 1);
	
Of course, nothing changes in the behavior yet. Let's add some additional logic: whenever you press the increment button, we'll generate a command to add some random "jitter" to the counter value.
Here's how:

	data Msg = ... | jitter(int j);
	
	WithCmds[Model] update(inc(), Model n) 
	  = withCmds(n + 1, [random(jitter, -10, 10)]);
	
	WithCmds[Model] update(jitter(int j), Model n) = noCmds(n + j);

We've added a new message, `jitter` with an integer argument. The `update` function is modified so that whenever the counter is incremented, we'll do that, but also produce a command, in this case `random`.
The command `random` is predefined and will generate a random integer in the provided range. The result is sent back and mapped into the `jitter` message.
The `update` function uses this message to add "jitter" to the counter value.

Again, when nesting components, the commands of the child components need to be mapped to properly handle the resulting messages. 

	updateTwice

### Guide to the modules

- App: contains the top-level `app` function and `App[&T]` data type.

- HTML: defines all HTML5 elements and attributes as convenient functions. All element functions (such as `div`, `h2`, etc.) accept a variable sequence of `value`s (i.e. they are "vararg" functions). All values can be attributes (as, e.g., produced by `onClick`, `class` etc.). The last value (if any) can also be either a block (of type `void()`), a `Node`, or a plain Rascal value. In the latter case, it's converted to a string and rendered as an HTML text node.  

- SVG: same as HTML, but for SVG. 

- Render: defines the rendering logic to convert "views" to HTML `Node`s. Only needed if you define your own attributes or elements, or if you need to call `render` explicitly. 

- Comms: contains the logic of representing and mapping handlers, commands, and subscriptions in such a way that they can be sent to and received from the browser. Import this if you use subscriptions, if you need mapping (see above), or if you're defining your own events, commands or subscriptions. 

- Diff & Patch: internal modules for diffing and patching `Node`. You should never have to import these modules. 


### Extending the Framework

Extending the framework with new events, commands or subscriptions is facilitated by Rascal's extensible data types. In all cases, you define new constructors for handlers (`Hnd`), commands (`Cmd`) or subscriptions (`Sub`). Since all three of those values are sent over the write, they have to be encoded. The framework provides functions to do so. Handlers, commands and subscriptions produce results, which are sent back to the server. This means that you'll also have to write a `Result` decoder, if the type of data is unsupported. In some cases the Javascript needs to be modified in order to accommodate the construct. 

#### Events

An event is defined using the following pattern:

	Attr <eventName>(Msg(...) something2msg) 
	  = event("<eventName", <handler>(something2msg));

This code defines an event function named `eventName`, accepting a function to map some event data to a `Msg`. It is defined using the `event` constructor which takes the name of the event and a "handler". Handlers are used to process event data such that it can eventually be fed into the argument function `something2msg`. Handlers thus are specific for such functions.

Standard handlers include `succeed(Msg)` which simply returns the argument when the event succeeds; `targetValue(Msg(str))` feeds the value property of the target element of the event into the argument function to obtain a message; and `targetChecked(Msg(bool))` which can be used on checkboxes and radio buttons. These are ready to use in your event definitions. 

If the standard handlers are not sufficient, you can also define your own. By extending the `Hnd` data type, and providing a smart constructor turning the handler function into serializable form. As an example, `targetValue` is defined as follows:

	data Hnd
     = ...
     | targetValue(Handle handle);

	Hnd targetValue(Msg(str) str2msg) = targetValue(encodeHnd(str2msg));

The type `Handle` is an opaque type representing the handler function in serializable form. The function `encode` uses internal magic to turn an arbitrary value into a handle. 

The reverse is also needed: turning a handle received from the client into the corresponding message as produced by the handler function. This is performed by interpreting `Result`s. Such a result is then converted to a message on the server. For instance, the result of `targetValue` is represented using the `Result` constructor `string(Handle,str)`. Here's how such a result is turned into a message:

	Msg toMsg(string(Handle handle, str s), &T(Handle,type[&T]) decode) 
	  =  decode(handle, #Msg(str))(s);

The function `toMsg` receives two parameters: first, the `Result` as received from the client, and second, a function to magically turn a handle into an arbitray type (as specified by the reified type). How and why this function is provided is irrelevant here; suffice it to say that the `decode` function captures some local state to perform its parsing magic which prevents it from being an ordinary function. The handle is decoded into a function `Msg(str)`, which is applied to the value component in the `string` result. 

Values of type `Hnd` are are interpreted in the client to produce `Result` values. Therefore, adding your own handlers requires changing the Javascript code to support the new kind.

#### Subscriptions & Commands

Extend `Sub` with new constructor for sending to client.
extend decoder to represent a decoder for this subscription
define smart constructor that encodes decoding functions
extend js to handle the new subscription.

For instance, `timeEvery` is defined as follows:

	data Sub = timeEvery(Handle handle, int interval);

	Sub timeEvery(Msg(int) int2msg, int n) = timeEvery(encodeSub(int2msg), n);


For instance, the `random` command is defined as follows:

	data Cmd = random(Handle handle, int from, int to);
  
	Cmd random(Msg(int) f, int from, int to) = random(encodeCmd(f), from, to);


New subscriptions and commands always require modifying the Javascript to interpret them. 

#### Interop with JS

// Natives

