module lib::Widgets

import gui::HTML;

void radio(Msg msg, str name) {
  label(() {
    input(\type("radio"), onClick(msg));
    text(name);
  });
}
