module examples::Shop

import gui::HTML;
import gui::App;
import String;
import List;
import IO;


data Article
  = article(str name, real price, int id, str newName = "", real newPrice = 0.0);
  
data Entry
  = entry(int id, int amount);
  
alias Cart = list[Entry];

alias Model = tuple[
  list[Article] articles, 
  Cart cart,
  str newName,
  real newPrice
];

Model init() = <
  [Article::article("Funny Bunnies", 17.63, nextId()),
    Article::article("Awesome React", 23.95, nextId()),
    Article::article("Second hand Netbook", 50.00, nextId())],
  [entry(0, 1)],
  "",
  0.0
>;

App[Model] shopApp() 
  = app(init(), shopDemoView, update, |http://localhost:9170|, |project://elmer/src/examples|);

data Msg
  = editName(int idx, str name)
  | editPrice(int idx, str price)
  | save(int idx)
  | addToCart(int idx)
  | removeFromCart(int idx)
  | newPrice(str price)
  | newName(str name)
  | newArticle()
  | updateSome()
  | createLots()
  ;

int _id = -1;
int nextId() { return _id += 1; }

Msg(str) editName(int idx) = Msg(str s) { return editName(idx, s); };
Msg(str) editPrice(int idx) = Msg(str s) { return editPrice(idx, s); };

Article findArticle(int id, Model m) = [ a | Article a <- m.articles, a.id == id][0];

Model update(editName(int idx, str name), Model m) {
  m.articles[idx].newName = name;
  return m;
}
Model update(editPrice(int idx, str price), Model m) {
  m.articles[idx].newPrice = toReal(price);
  return m;
}

Model update(save(int idx), Model m) {
  m.articles[idx].price = m.articles[idx].newPrice;
  m.articles[idx].name = m.articles[idx].newName;
  return m;
}
  
Model update(addToCart(int idx), Model m) {
  Article a = m.articles[idx];
  for (int i <- [0..size(m.cart)]) {
    if (m.cart[i].id == a.id) {
      m.cart[i] = m.cart[i][amount = m.cart[i].amount + 1];
      return m;
    }
  }
  return m[cart = m.cart + [entry(m.articles[idx].id, 1)]];
} 
 

Model update(removeFromCart(int idx), Model m) {
  Entry e = m.cart[idx];
  if (e.amount == 1) {
    return m[cart = delete(m.cart, idx)]; 
  }
  m.cart[idx] = e[amount=e.amount - 1];
  return m;
}

Model update(newPrice(str price), Model m)
  = m[newPrice = toReal(price)];

Model update(newName(str name), Model m)
  = m[newName = name];
  
Model update(newArticle(), Model m) 
  = m[articles = m.articles + [Article::article(m.newName, m.newPrice, nextId())]]; 

Model update(updateSome(), Model m) = m;
Model update(createLots(), Model m) = m;



void shopDemoView(Model m) {
  table(() {
    tr(() {
      td(colspan(2), () {
        button(onClick(updateSome()), "update some items");
        button(onClick(createLots()), "create a lot of items");
      });
    });
    tr(() {
      td(() {
        h2("Available items");
        articlesView(m);
      });
      td(() {
        h2("Your shopping cart");
        cartView(m);
      });
    });
  });
}

void articlesView(Model m) {
  div(() {
    p("Article name ");
    input(\type("text"), \value(m.newName), onInput(newName));
    p("Price (a number) ");
    input(\type("text"), \value("<m.newPrice>"), onInput(newPrice));
    button(onClick(newArticle()), "new article");
    ul(() {
      for (int i <- [0..size(m.articles)]) {
        articleView(m, m.articles[i], i);
      }
    });
  });
}

void articleView(Model m, Article a, int i) {
  li(() {
    span(a.name);
    button(onClick(addToCart(i)), "\>\>");
    //p("Article name ");
    //input(\type("text"), \value(a.newName), onInput(editName(i)));
    //p("Price (a number) ");
    //input(\type("text"), \value("<a.newPrice>"), onInput(editPrice(i)));
    //button(onClick(save(i)), "update");
    span(class("price"), "€ <a.price>"); 
  });
}

//Article find(int id, Model m) = [ art | Article art <- m.articles, art.id == m.cart[i].id ][0];

void cartView(Model m) {
 div(() {
   ul(() {
     for (int i <- [0..size(m.cart)]) {
       li(() {
         button(onClick(removeFromCart(i)), "\<\<");
         span(findArticle(m.cart[i].id, m).name);
         span(class("price"), "<m.cart[i].amount>x"); 
       });
     }
   });
   real total = ( 0.0 | it + e.amount * findArticle(e.id, m).price | Entry e <- m.cart);
   span("Total: € <total>");
 });
}