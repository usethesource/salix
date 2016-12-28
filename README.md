
## Elmer: Elm-style Web GUIs in Rascal

Elmer is Rascal library for developing Web-based GUI programs. It emulates the [Elm Architecture](https://guide.elm-lang.org/architecture/), but since Rascal does not run in the browser (yet), most user code written in Rascal is executed on the server. HTML is sent to the browser and the browser sends messages back to the server, where they are interpreted on the model, to construct the new view. 

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
        div("<m.count>");
        button(onClick(dec()), "-");
      });
    }

A few notes are in order here. A view in Elmer is a function from a model (in this case, of type `Model`) to `void`. Views defined in this style call HTML generating functions defined in the `gui::HTML` module, which are all `void` functions too. You can use the `render` function in `gui::Render` to turn a view and a model into an actual `Node` value, but typically you should never have to call this explicitly. Consider the `void` functions as "drawing" functions, painting HTML structure on an implicit canvas. This imperative style has the advantage that all regular control-flow constructs of Rascal can be used during view construction. 

The top element of the counter view consists of a single `div`. Within the `div` there'a `h2` header element, two `button`s and a `div` showing the current model value. Notice how `void` closures are used to express nesting.
The `button` elements receive attributes to setup event-handling. In this case, the `onClick` attribute wraps an `Msg` value to indicate that this message must be sent if the button is clicked. The main render loop will forward this message to `update` to obtain a new model value, which in turn is used to create the updated view.

Now that we've defined all required components of a simple Elmer app, how do we tie it all together? This is where the `app` function comes in: it takes an initial model, a view function, an update function, and two locations capturing the host+port configuration and the path to serve static assets from, respectively. Here's the definition of the counter app: 

    App[Model] counterApp() 
      = app(init(), view, update, 
            |http://localhost:9197|, |project://elmer/src/examples|); 

The returned value of type `App[Model]` is a tuple containing function to start and stop the application, like so:

    counter = counterApp();
    counter.serve(); // start the application
    counter.stop(); // shut it down

And that's it! After calling `.serve()`, you can use the counter app at `http://localhost:9197`.

### Nesting Components by Mapping

Components encapsulate their own models and sets of messages. In order to nest components inside one another, parent components must route incoming message to the originating child component. This is where "mapping" comes in.

As an example, let's consider an app that contains the counter app twice. Clicking increment or decrement on either of the counters should not affect the other. Here's how mapping solves this problem.

    import examples::Counter;
    import gui::HTML;
    
    // combine two counter models
    alias ModelTwice = tuple[Model counter1, Model counter2];
    
    // extend Msg
    data Msg = counter1(Msg msg) | counter2(Msg m);
    
    // update
    ModelTwice updateTwice(counter1(Msg msg), ModelTwice m) = update(msg, m.counter1);
    ModelTwice updateTwice(counter2(Msg msg), ModelTwice m) = update(msg, m.counter2);
    
    // define the view
    void viewTwice(ModelTwice model) {
      div(() {
        mapping.view(model.counter1, view);
        mapping.view(model.counter2, view);
      });
    }

The important bit here is that the `view` function of the counter app is embedded twice, via the special `mapping.view` function (exported by `gui::HTML`). It takes as its first argument a function of type `Msg(Msg)` (i.e., a message transformer), and a view (of type `void(&T)`) as its second argument. In this case we provide the `counter1` and `counter2` constructors as message transformers. The function `mapping.view` now ensures that whenever a message is received that originates from the first counter it is wrapped in `counter1`. For instance, `inc()` will be wrapped as `counter1(inc())` and passed to `updateTwice` who will root it to `update` on `m.counter1`. Same for `counter2`.      

### Subscriptions

TBD

### Guide to the modules


- App: contains the top-level `app` function and `App[&T]` data type.

- HTML: defines all HTML5 elements and attributes as convenient functions. All element functions (such as `div`, `h2`, etc.) accept a variable sequence of `value`s (i.e. they are "vararg" functions). All values can be attributes (as, e.g., produced by `onClick`, `class` etc.). The last value (if any) can also be either a block (of type `void()`), a `Node`, or a plain Rascal value. In the latter case, it's converted to a string and rendered as an HTML text node.  

- SVG: same as HTML but for SVG. 

- Render: defines the rendering logic to convert "views" to HTML `Node`s. Only needed if you define your own events, attributes or elements, or if you need to call `render` explicitly. 

- Decode: contains the logic of representing decoders (functions that interpret event ocurrences into messages), in such a way that they can be sent to and received from the browser. Import this if you use subscriptions, if you need *mapping* (see above), or if you're defining your own decoders or subscriptions. 

- Diff & Patch: internal modules for diffing and patching `Node`. You should never have to import this module. 






