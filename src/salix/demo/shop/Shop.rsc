@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::shop::Shop

import salix::HTML;
import salix::App;
import salix::Index;

import String;
import List;
import util::UUID;

// This app is based on: https://www.mendix.com/tech-blog/making-react-reactive-pursuit-high-performing-easily-maintainable-react-apps/

data Article
  = article(str name, real price, loc id, str newName = "", real newPrice = 0.0);
  
data Entry
  = entry(loc id, int amount);
  
alias Cart = list[Entry];

alias Model = tuple[
  list[Article] articles, 
  Cart cart,
  str newName,
  real newPrice
];

Model init() = <
  [Article::article("Funny Bunnies", 17.63, bunnyId),
   Article::article("Awesome React", 23.95, uuid()),
   Article::article("Second hand Netbook", 50.00, uuid())],
  [entry(bunnyId, 1)],
  "",
  0.0
>
  when loc bunnyId := uuid();

SalixApp[Model] shopApp(str id = "shopDemo") 
  = makeApp(id, init, withIndex("Shop", id, shopDemoView, css = ["/salix/demo/shop/test.css"]), update); 

App[Model] shopWebApp()
  = webApp(
      shopApp(), 
      |project://salix/src/salix/demo/shop/shop.html|, 
      |project://salix/src|
    ); 

data Msg
  = editName(int idx, str name)
  | editPrice(int idx, str price)
  | save(int idx)
  | addToCart(int idx)
  | removeFromCart(int idx)
  | newPrice(str price)
  | newName(str name)
  | newArticle()
  | updateSome() // TODO
  | createLots() // TODO
  ;


Msg(str) editName(int idx) = Msg(str s) { return editName(idx, s); };
Msg(str) editPrice(int idx) = Msg(str s) { return editPrice(idx, s); };

Article findArticle(loc id, Model m) = [ a | Article a <- m.articles, a.id == id][0];

Model update(Msg msg, Model m) {
  switch (msg) {
  
    case editName(int idx, str name):
      m.articles[idx].newName = name;
      
    case editPrice(int idx, str price):
      m.articles[idx].newPrice = toReal(price);
    
    case save(int idx): {
      m.articles[idx].price = m.articles[idx].newPrice;
      m.articles[idx].name = m.articles[idx].newName;
    }
    
    case addToCart(int idx): {
      Article a = m.articles[idx];
      if (int i <- [0..size(m.cart)], m.cart[i].id == a.id) {
        m.cart[i] = m.cart[i][amount = m.cart[i].amount + 1];
      }
      else {
	      m.cart += [entry(m.articles[idx].id, 1)];
	    }
    }
    
    case removeFromCart(int idx): {
      Entry e = m.cart[idx];
      if (e.amount == 1) {
        m.cart = delete(m.cart, idx); 
      }
      else {
        e.amount -= 1;
        m.cart[idx] = e;
      }
    }
    
    case newPrice(str price):
      m.newPrice = toReal(price);

    case newName(str name):
      m.newName = name;

    case newArticle(): 
      m.articles += [Article::article(m.newName, m.newPrice, uuid())];
  }
  
  return m;
} 


void shopDemoView(Model m) {
    div(id("header"), () {
      h1("Salix shopping cart demo");
    });  
    table(() {
     tbody(() {
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
        articleView(m.articles[i], i);
      }
    });
  });
}

void articleView(Article a, int i) {
  li(() {
    span(a.name);
    button(onClick(addToCart(i)), "\>\>");
    span(class("price"), "€ <a.price>"); 
  });
}

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