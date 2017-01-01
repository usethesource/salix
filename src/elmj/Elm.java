package elmj;

import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.function.Supplier;
import java.util.stream.Collectors;

import elmj.Elm.Model.MyMsg;
import elmj.Elm.TargetValue;

public class Elm {
	
	// I ask the nested one to map itself to the containing one
	// with func: BiFunction<Model2, Model, Model2>
	// the result should Mode<Model2> 
	interface Mappable<T> {
		<U> Mappable<U> map(Function<Msg<T>, Msg<U>> f);
	}
	
	static abstract class Node<T> implements Mappable<T> {
		@Override
		public abstract <U> Node<U> map(Function<Msg<T>, Msg<U>> f);
	}
	
	static abstract class Attribute<T> implements Mappable<T> {
		private String name;
		public Attribute(String name) {
			this.name = name;
		}
		
		public String getName() {
			return name;
		}
		
		@Override
		public abstract <U> Attribute<U> map(Function<Msg<T>, Msg<U>> f);
	}
	
	static class Attr<T> extends Attribute<T> {
		private String value;

		public Attr(String name, String value) {
			super(name);
			this.value = value;
		}

		@Override
		public <U> Attr<U> map(Function<Msg<T>, Msg<U>> f) {
			return new Attr<U>(getName(), value);
		}
	}
	
	static abstract class Decoder<T> implements Mappable<T> {
		@Override
		public abstract <U> Decoder<U> map(Function<Msg<T>, Msg<U>> f);
	}
	
	static class Succeed<T> extends Decoder<T> {
		private Class<Msg<T>> msg;

		public Succeed(Class<Msg<T>> msg) {
			this.msg = msg;
		}
		
		@Override
		public <U> Succeed<U> map(Function<Msg<T>, Msg<U>> f) {
			return new Succeed<U>(f.apply(msg));
		}
		
	}
	
	static class _TargetValue<T> extends Decoder<T> {
		private Class<TargetValue<T>> input;

		public _TargetValue(Class<TargetValue<T>> input) {
			this.input = input;
		}

		@Override
		public <U> _TargetValue<U> map(Function<Msg<T>, Msg<U>> f) {
			return new _TargetValue<U>(s -> f.apply(input.apply(s)));
		}
	}
	
	static class Event<T> extends Attribute<T> {
		private Decoder<T> decoder;

		public Event(String name, Decoder<T> dec) {
			super(name);
			this.decoder = dec;
		}

		@Override
		public <U> Event<U> map(Function<Msg<T>, Msg<U>> f) {
			return new Event<>(getName(), decoder.map(f));
		}
	}
	
	
	static class Element<T> extends Node<T> {
		private String name;
		private List<Node<T>> kids;
		private List<Attribute<T>> attrs;

		public Element(String name, List<Node<T>> kids, List<Attribute<T>> attrs) {
			this.name = name;
			this.kids = kids;
			this.attrs = attrs;
		}

		@Override
		public <U> Element<U> map(Function<Msg<T>, Msg<U>> f) {
			return new Element<U>(name, kids.stream().map(x -> x.map(f)).collect(Collectors.toList()), 
					attrs.stream().map(x -> x.map(f)).collect(Collectors.toList()));
		}
	}
	
	static class Text<T> extends Node<T> {

		private String contents;

		public Text(String contents) {
			this.contents = contents;
		}

		@Override
		public <U> Node<U> map(Function<Msg<T>, Msg<U>> f) {
			return new Text<>(contents);
		}
		
	}
	
	// First render: create html + assign ids for events
	// Then something happens, we get an event id
	// Render again, this time updating the model. 
	// so: view must be really generic
	//  Node<Model> view(Model m, Html<Node<Model>> h);
	//  Model view(Model m, Html<Model> h)
	//  so declare as
	//  <T> T view(Model, Html<T>) 
	//  call: view(aModel, new RenderHtml<Model>()); // construct Node<Model>
	//  2nd call: view(aModel, new UpdateHtml<Model>());
	/*
	 * but we must create new ones, when nesting. This is not good, so:
	 * interface HtmlAlg<T> {
	 *   T div(...);
	 * }
	 * 
	 * class RenderHtml<T> implements HtmlAlg<Node<T>> {
	 *   <U> Node<T> div(...)
	 * }
	 *
	 * bluh: need type cons poly
	 * 
	 * 
	 */
	
	interface HtmlAlg<T> {
		<U> T div(Object ...args);
	}
	
	class Render implements HtmlAlg<Node> {
		@Override
		public <U> Node<U> div(Object... args) {
			return null;
		}
	}
	
	interface Upd<T> {
		
	}
	
	class Bla {
		<T, U> U view(T model, HtmlAlg<U> h) {
			Node<?> x = view(model, new Render<T>());
			Upd<?> y = view(model, new Update<T>());
			return view(model, new Update<T>());
		}
	}
	
	class Update<T> implements HtmlAlg<Upd<?>> {

		@Override
		public <U> Upd<U> div(Object... args) {
			return null;
		}
		
	}
	
	interface Html {
		
		@SuppressWarnings({ "unchecked", "rawtypes" })
		default <T> Element<T> element(String name, Object[] args) {
			List<Node<T>> kids = new ArrayList<>();
			List<Attribute<T>> attrs = new ArrayList<>();
			for (int i = 0; i < args.length; i++) {
				Object arg = args[i];
				if (arg instanceof Node) {
					kids.add((Node<T>) arg);
				}
				if (arg instanceof List) {
					kids.addAll((List)arg);
				}
				else if (arg instanceof Attribute) {
					attrs.add((Attribute<T>) arg);
				}
				else {
					kids.add(new Text<T>(arg.toString()));
				}
			}
			return new Element<>(name, kids, attrs);
		}

		default <T> Element<T> h2(Object ...args) {
			return element("h2", args);
		}

		default <T> Element<T> div(Object ...args) {
			return element("div", args);
		}

		default <T> Element<T> button(Object ...args) {
			return element("button", args);
		}

		default <T> Element<T> input(Object ...args) {
			return element("input", args);
		}
		
		default <T> Attr<T> value(Object o) {
			return new Attr<>("value", o.toString());
		}

		default <T> Attr<T> type(Object o) {
			return new Attr<>("type", o.toString());
		}

		default <T> Event<T> onInput(Function<String, T> t) {
			return new Event<>("input", new _TargetValue<>(m));
		}
		
		default <T> Event<T> onClick(Supplier<T> t) {
			return new Event<>("click", new Handle<>(m));
		}
		
	}
	
	
	interface Msg<T>  {
		// a message transforms a model.
		T eval(T t);
	}
	
	interface TargetValue<T> {
		T eval(T t, String s);
	}
	
	interface View<T, M> extends Html {
		Node<M> view(T t, M m);
		
//		default <U> Node<U> map(BiFunction<U, T, U> f, T t) {
//			Msg<U> mu = (U u) -> f.apply(u, t);
//			return view(t).map((Msg<T> mt) -> mu);
//		}
	}
	
	
	interface Msgs { 
		default Msg<Model> inc() {
			return m -> new Model(m.count + m.delta, m.delta);
		}
		
		default Msg<Model> dec() {
			return m -> new Model(m.count - m.delta, m.delta);
		}
		
		default Msg<Model> delta(String s) {
			return m -> new Model(m.count, Integer.parseInt(s));
		}
	}
	
	static class Model {
		int count = 0;
		int delta = 1;

		public Model(int count, int delta) {
			this.count = count;
			this.delta = delta;
		}

		static Msg<Model> inc = m -> new Model(m.count + m.delta, m.delta);
		
		static Msg<Model> dec = m -> new Model(m.count - m.delta, m.delta);
		
		static Function<String, Msg<Model>> Delta = s -> m -> new Model(m.count, Integer.parseInt(s));
		
	}
	
	static class CounterView implements View<Model, Msgs> {

		
		@Override
		public Node<Msgs> view(Model t, Msgs msgs) {
			return div(
				h2("My first counter in Java"),
				button(onClick(msgs::inc)),
				div(t.count),
				button(onClick(msgs::dec)),
				input(value(t.delta), type("text"), onInput(msgs::delta))
			);
		}
		
	}
	
	static class Model2 {
		Model m1;
		Model m2;
		
		public Model2(Model m1, Model m2) {
			this.m1 = m1;
			this.m2 = m2;
		}
		
		
		
		static abstract class Msg {
			
		}
		
		class Sub1 extends Msg implements Function<Model2, Model2> {
			private MyMsg m;

			public Sub1(Model.MyMsg m) {
				this.m = m;
			}

			@Override
			public Model2 apply(Model2 t) {
				return new Model2(m.eval(t.m1), t.m2));
			}
		}
		static Model2 sub1(Model2 m, Model m1) {
			return new Model2(m1, m.m2);
		}

		static Model2 sub2(Model2 m, Model m2) {
			return new Model2(m.m1, m2);
		}

	}
	
	static class Counter2 implements View<Model2, Model2.Msg> {

		private final View<Model> view1;
		private final View<Model> view2;

		public Counter2(View<Model> view1, View<Model> view2) {
			this.view1 = view1;
			this.view2 = view2;
		}
		
		@Override
		public Node<Model2> view(Model2 t) {
			return div(
					view1.map(Model2::sub1, t.m1),
					view2.map(Model2::sub2, t.m2)
			);
		}
		
	}
	
	
	
	public static void main(String[] args) {
		Model m1 = new Model(0, 1);
		Model m2 = new Model(0, 1);
		CounterView v = new CounterView();
		Counter2 v2 = new Counter2(v, v);
		Model2 m = new Model2(m1, m2);
		Node<Model2> n = v2.view(m);
		
	}
	

}
