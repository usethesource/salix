module salix::Index


import salix::Core;
import salix::HTML;
import salix::lib::Extension;
import String;


void(&T) withIndex(str myTitle, void(&T) view, list[Extension] exts = [], list[str] css = [], list[str] scripts = []) {
  return void(&T model) {
     index(myTitle, () {
       view(model);
     }, exts=exts, css=css, scripts=scripts);
  };
}


void index(str myTitle, void() block, list[Extension] exts = [], list[str] css = [], list[str] scripts = []) {
  html(() {
    head(() {
      title_(myTitle);
      
      for (Extension e <- exts) {
        for (Asset a <- e.assets) {
          switch (a) {
            case css(str c): link(\rel("stylesheet"), href(c));
            case js(str j): script(\type("text/javascript"), src(j));
            default: throw "Unknown asset: <a>";
          }
        }
      }
      
      for (str c <- css) {
        link(\rel("stylesheet"), href(c));
      }
      
      for (str s <- scripts + ["/salix/salix.js"]) {
        script(\type("text/javascript"), src(s));
      }
      
      str src = "const app = new Salix();\n";
      
      for (Extension e <- exts) {
        src += "register<capitalize(e.name)>(app);\n";
      }
      
      script(src + "document.addEventListener(\"DOMContentLoaded\", app.start);\n");
    });
    
    body(block);
  });
}

