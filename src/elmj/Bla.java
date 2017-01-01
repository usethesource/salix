package elmj;

public class Bla {
	
	class Msg<Tag> {
		private Tag tag;
		private Object data;

		public Msg(Tag tag) {
			this(tag, null);
		}
		
		public Msg(Tag tag, Object data) {
			this.tag = tag;
			this.data = data;
		}
		
		@SuppressWarnings("unchecked")
		public <U> Msg<U> getArg() {
			return (Msg<U>)data;
		}
		
		public Integer getInt() {
			return (Integer)data;
		}
		
		public String getStr() {
			return (String)data;
		}
		
		Tag tag() {
			return tag;
		}
	}
	
	interface AModel<Tag> {
		AModel<Tag> update(Msg<Tag> m);
	}

	static class Model implements AModel<Model.Tag> {
		int count = 0;
		int delta = 1;

		public Model(int count, int delta) {
			this.count = count;
			this.delta = delta;
		}
		
		enum Tag {inc, dec, delta};
		
		@Override
		public Model update(Msg<Tag> m) {
			switch (m.tag()) {
			
			case inc:
				return new Model(count + delta, delta);
				
			case dec:
				return new Model(count - delta, delta);
			
			case delta:
				return new Model(count, Integer.parseInt(m.getStr()));
			
			}
			
			return this; // dunno, Java knows the switch is exhaustive...
		}

		
	}
	
	static class Model2 implements AModel<Model2.Tag>{
		Model m1;
		Model m2;
		
		public Model2(Model m1, Model m2) {
			this.m1 = m1;
			this.m2 = m2;
		}
		
		enum Tag { sub1, sub2 }

		@Override
		public Model2 update(Msg<Tag> m) {
			switch (m.tag()) {
			
			case sub1:
				return new Model2(m1.update(m.getArg()), m2);
			
			case sub2:
				return new Model2(m1, m2.update(m.getArg()));
			
			}
			
			return this;
		};
		
		
		
	}
	
	
}
