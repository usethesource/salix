@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::tests::EventDiscarding

import salix::App;
import salix::HTML;
import salix::Node;

import String;

alias Model = tuple[str txt, bool deleted];

App[str] theApp() = app(init, view, update, |http://localhost:7000/salix/tests/index.html|, |project://salix/src|);

Model init() = <"0", false>;

data Msg
  = updateTxt(str s)
  | updateTxt2(str s)
  | goBack(str s)
  ;
  
Model update(updateTxt(str s), Model _) 
  = <s, size(s) > 10>;

Model update(updateTxt2(str s), Model _) 
  = <s, size(s) > 10>;

Model update(goBack(str s), Model m) 
  = <toInt(s) <= 50 ? s : m.txt, size(s) > 10>;
  
void view(Model m) {
  div(() {
    h3("Self-imploding text field");
    div(() {
      text(0);
      input(\type("text"), \value(m.txt), !m.deleted ? onInput(updateTxt2) : null());
    });
    if (!m.deleted) {
      div(() {
        text(1);
        input(\type("text"), \value(m.txt), onInput(updateTxt));
      });
    }
    
    div(() {
      if (toInt(m.txt) > 50) {
        input(\type("range"), \value(m.txt), min("0"), max("100"), onInput(goBack));
      }
      else {
        input(\type("range"), \value(m.txt), min("0"), max("100"), onInput(updateTxt));
      }
    });
    
  });
}