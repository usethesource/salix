module examples::statemachine::StateMachine

start syntax Controller = controller: Events events ResetEvents? resets Commands? commands State+ states;

syntax Events = @Foldable "events" Event* "end";
syntax ResetEvents = @Foldable "resetEvents" Id* "end"; 
syntax Commands = @Foldable "commands" Command* "end";

syntax Command = command: Id name Id token;
syntax Event = event: Id name Id token;

syntax State = @Foldable state: 
  "state" Id name Actions? 
    Transition* 
  "end";
syntax Actions = "actions" "{" Id+ "}";

syntax Transition 
  = transition: Id event "=\>" Id state 
  | transition: "after" Nat number Id event "=\>" Id state;

lexical Nat = [1-9][0-9]* !>> [0-9];

lexical Id = ([a-zA-Z][a-zA-Z0-9_]* !>> [a-zA-Z0-9_]) \ Reserved ;

keyword Reserved = "events" | "end" | "resetEvents" | "state" | "actions" | "after";

layout Standard 
  = WhitespaceOrComment* !>> [\ \t\n\f\r] !>> "//";
  
syntax WhitespaceOrComment 
  = whitespace: Whitespace
  | comment: Comment
  ; 

lexical Comment = @category="Comment" "//" ![\n\r]* $;

lexical Whitespace 
  = [\u0009-\u000D \u0020 \u0085 \u00A0 \u1680 \u180E \u2000-\u200A \u2028 \u2029 \u202F \u205F \u3000]
  ; 