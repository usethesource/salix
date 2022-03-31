module salix::util::Bootstrap

import lang::html5::DOM;


str bootstrap() = toString(_bootstrap());

private HTML5Node _bootstrap() = 
  html(
    head(
      script(\type("text/javascript"), src("/salix/salix.js")),
      script("document.addEventListener(\"DOMContentLoaded\", new Salix().start);")
    ),
    body()
  );
    