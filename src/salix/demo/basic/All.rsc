@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}
@contributor{Jouke Stoel - stoel@cwi.nl - CWI}

module salix::demo::basic::All

import salix::App;

import salix::demo::basic::Celsius;
import salix::demo::basic::Counter;
import salix::demo::basic::CodeMirror;
import salix::demo::basic::Clock;
import salix::demo::basic::Random;
 
set[SalixApp[&T]] createBasicDemoApps() = {celsiusApp(id="celsiusApp"), 
                                           counterApp(id="counterApp"), 
                                           clockApp(id="clockApp"), 
                                           cmApp(id="codeMirrorExample"), 
                                           randomApp(id="randomApp")}; 
  
App[value] createBasicDemoWebApp() 
  = webApp(
      "allBasicDemos", 
      createBasicDemoApps(), 
      |project://salix/src/salix/demo/basic/all_demos.html|, 
      |project://salix/src|
    );