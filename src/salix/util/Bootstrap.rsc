module salix::util::Bootstrap

import lang::html5::DOM;


/*
This function allows the browser to bootstrap into Salix.
Sending this as plain html, will cause an init request
which replaces the current root document element, with
whatever the user has programmed, using `index` from salix::Index
(or a custom variant thereof). It is needed because the Salix
event encoding cannot be represented as plain HTML.
*/

str bootstrap() = toString(_bootstrap());

private HTML5Node _bootstrap() = 
  html(
    head(
      script(\type("text/javascript"), src("/salix/salix.js")),
      script("document.addEventListener(\"DOMContentLoaded\", new Salix().start);")
    ),
    body()
  );
    