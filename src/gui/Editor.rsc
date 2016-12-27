module gui::Editor


// CodeMirror token:  {start, end, string, type, state}

data Mode
  = mode(list[State] states, map[str, value] meta = ());
  
data State
  = state(str name, list[Rule] rules)
  ;
  
data Rule
  = rule(str regex, list[str] tokens, str next = "", bool indent=false, bool dedent=false)
  ;
  
Mode jsExample() = mode([  
  state("start", [
    rule("\"(?:[^\\]|\\.)*?(?:\"|$)", ["string"]),

    rule("(function)(\\s+)([a-z$][\\w$]*)", ["keyword", "", "variable-2"]),

    rule("(?:function|var|return|if|for|while|else|do|this)\\b", ["keyword"]),

    rule("true|false|null|undefined", ["atom"]),

    rule("0x[a-f\\d]+|[-+]?(?:\\.\\d+|\\d+\\.?\\d*)(?:e[-+]?\\d+)?", ["number"]),

    rule("//.*", ["comment"]),

    rule("/(?:[^\\\\]|\\\\.)*?/", ["variable-3"]),

    rule("/\\*", ["comment"], next = "comment"),

    rule("[-+/*=\<\>!]+", ["operator"]),

    rule("[\\{\\[\\(]", [], indent = true),

    rule("[\\)\\]\\)]", [], dedent = true),

    rule("[a-z$][\\w$]*", ["variable"])
  ]),
  state("comment", [
    rule(".*?\\*/", ["comment"], next = "start"),
    rule(".*", ["comment"])
  ])
 ], meta = ("dontIndentStates": ["comment"], "lineComment": "//")
);  
