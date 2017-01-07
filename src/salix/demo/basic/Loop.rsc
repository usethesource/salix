module salix::demo::basic::Loop

import salix::App;
import salix::Core;
import salix::HTML;

import String;
import List;

alias Model = tuple[int count, list[int] numbers];

WithCmd[Model] init() = withCmd(<100, []>, random(addNumber, 1, 100));

App[Model] loopApp()
  = app(init, view, update, |http://localhost:6001|, |project://salix/src|); 

data Msg
  = addNumber(int n)
  | updateCount(str x)
  ;

WithCmd[Model] update(Msg msg, Model m) {
  Cmd cmd = none();
  
  switch (msg) {
    case addNumber(int x): {
      if (size(m.numbers) < m.count) {
        m.numbers += [x];
        cmd = random(addNumber, 1, 100);
      }
    }
    
    case updateCount(str x): {
      m.count = toInt(x);
      m.numbers = m.numbers[0..m.count];
      cmd = random(addNumber, 1, 100);
    }
      
  }
  
  return withCmd(m, cmd);
}

void view(Model m) {
  div(() {
     text("Count: ");
     input(\type("text"), \value("<m.count>"), onInput(updateCount));
     for (int i <- [0..size(m.numbers)]) {
       p("<i>: <m.numbers[i]>");
     }
  });
}