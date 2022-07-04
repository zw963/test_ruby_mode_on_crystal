# All String in Crystal must use double quotes, it weird.
x = 'hello world' # => Error: unterminated char literal, use double quotes for strings

# all valid literal is:
%(hello ("world")) # => "hello (\"world\")"
%[hello ["world"]] # => "hello [\"world\"]"
%{hello {"world"}} # => "hello {\"world\"}"
%<hello <"world">> # => "hello <\"world\">"
%|hello "world"|   # => "hello \"world\""

# but ruby support other char as literal
puts %hello world # => Error: unknown token: '\u0001'
