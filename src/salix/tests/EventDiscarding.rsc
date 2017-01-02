module salix::tests::EventDiscarding

import salix::App;
import salix::HTML;

import String;

alias Model = tuple[str txt, bool deleted];

App[str] theApp() = app(<"some text", false>, view, update, |http://localhost:7000|, |project://salix/src|);

data Msg
  = updateTxt(str s)
  ;
  
Model update(updateTxt(str s), Model _) 
  = <s, size(s) > 10>;
  
void view(Model m) {
  div(() {
    h3("Self-imploding text field");
    if (!m.deleted) {
      input(\type("text"), \value(m.txt), onInput(updateTxt));
    }
  });
}