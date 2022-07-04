# ------------------------------ case statement ------------------------------
num = 100

case num
when .even? # <= not supported
  puts "even"
when .odd?
  puts "odd"
end

x = {100, 101} # <= define a tuple not supported.

case {100, 101}
when {.even?, .odd?}
  puts "matched!"
end

# ------------------------------ variable declaration ------------------------------
# delare a variable type, use colon : , whitespace around is necessary.
num1 : Int8 = 1

# type can be a untagged union type. (use |, space around)

num2 : Int32 | Nil = 1 # => same as num2 : Int32?
p! typeof(num2) # =>  (Int32 | Nil)
num2 = nil

var1 = rand < 0.5 ? 42 : "Crystal"
p! typeof(var1)                     # => compile time type is (Int32 | String)
p! var1                             # => 42
p! var1.class                       # runtime type is Int32

# ------------------------------ enum  ------------------------------

enum Color
  Red        # 0
  Green      # 1
  Blue   = 5 # overwritten to 5
  Yellow     # 6 (5 + 1)

  def not_blue?
    self != Color::Blue
  end
end

Color::Red         # :: Color
Color::Green.value # => 1

Color::Red.red?       # => true
Color::Blue.red?      # => false
Color::Blue.not_blue? # => false

# ------------------------------ method ------------------------------

# parameter x is Int32, return type is String

def foo(x : Int32) : String
  x.to_s
end

foo 100

# foo "hello" # => Error

def foo(x : Int32.class)
  x.to_s
end

foo Int32 # => "Int32"
# foo String # => Error

# Positional parameters can always be matched by name.
# all parameter after the * must be named parameters.

def add_xy(x, *, y=10)
  x + y
end

add_xy 1, y: 2    # OK
add_xy y: 2, x: 3 # OK
p! add_xy 20      # OK
# add_xy 10, 20     # Error: wrong number of arguments for 'add_xy' (given 2, expected 1)

# parameters can have alias.

def increment(number, by value)
  number + value
end

increment(10, 10)           # OK
increment(10, by: 10)       # OK
# increment(10, value: 10)    # Error

# captured block(&block) must declare as Proc type.
# e.g. `Int32 -> String` is a type, same as Proc(Int32, String)
# Int32 is type of block parameter, String is return type.
# _ can be used to ignore return type if you don't care about it.

def wrap_foo(&block : (Int32, Int32) -> _)
  puts "Before foo"
  block.call(1, 2)
  puts "After foo"
end

# same as above, though, could not use _ here.
# def wrap_foo(&block : Proc(Int32, Int32, Nil))
#   ...
# end

wrap_foo do |i, j|
  puts i + j
end

# =>
# Before foo
# 3
# After foo

# You can create a proc object from a method use ->

def add(x, y)
  x + y
end

adder = ->add(Int32, Int32)
adder.call(1, 2) # => 3

# new keyword previous_def

def hello(a : String)
  puts "old hello #{a}"
end

def hello(a : String)
  previous_def(a)
  puts "new hello #{a}"
end

hello("hello")

# old hello hello
# new hello hello

# ------------------------------ class ------------------------------

class Person
  @age = 0   # <= this is instance variable, will initialize in every instance create.

  def initialize(@name : String)
  end
  # same as
  # def initialize(name : String)
  #   @name = name
  # end
end

# generatic is supported

class MyBox(T)
  def initialize(@value : T)
  end

  def value
    @value
  end
end

int_box = MyBox(Int32).new(1)
int_box.value # => 1 (Int32)

string_box = MyBox(String).new("hello")
string_box.value # => "hello" (String)

# both class and method can be abstract
abstract class Animal
  abstract def talk
  end  # <= indentation error here, because abstract def no end.

# `private` can be used with `class`, `module`, `lib`, `enum`, `alias` and constants:

class Foo
  private class Bar
  end

  private module Baz
          end  # <= indentation error

  Bar      # OK
  # Foo::Bar # Error
end

# Foo::Bar # Error

private lib LibPCRE
        end # <= indentation error

private enum NewColor
          Red        # <= indentation error
          Blue
        end

private A_INSTANCE = 100

# alias is keyword.
private alias Foo = Int32 -> String
foo = Foo.new { |x| x.to_s }
# same as Proc(Int32, String).new { |x| x.to_s }
p! foo.call(10) # => 10

# setter/getter/property was keyword (defined by macro)
class ClassA
  setter name # symbol as args support too.
  getter name
  property age
end

# self can be type, same as writing the type that will finally own that method,
# which, when modules are involved, becomes more useful.

class Person1
  def ==(other : self)
    other.name == name
  end

  def ==(other)
    false
  end
end

# ------------------------------ rescue on exception ------------------------------

class MyException < Exception
end

begin
  raise MyException.new("OH NO!")
rescue ex : MyException
  puts "Rescued MyException: #{ex.message}"
end

# ------------------------------ collection of elements ------------------------------

typeof([1, "hello", 'x']) # => Array(Int32 | String | Char))

x = [] of Int32 # => same as Array(Int32).new

# use can use typeof(???) as type directly.
y = [] of typeof([1, "hello", 'x'])
y = Array(Int32 | String | Char).new # same as above

ary1 = [1, 2, -1]

# ary1[3] # => Unhandled exception: Index out of bounds (IndexError)

# many methods and all type Crystal have a ? suffix counterpart，Array#[] is.
ary1[3]? # => nil

# & hack not same as ruby.
p! ary1.map &.abs # => [1, 2, 1]

# it support invoke method which has arguments.
# many symbol can be invoke as methods, e.g. :+   :-  :* :/ :%  etc ...
p! ary1.map &.*(2) # => [2, 4, -2]

# define a tuple, tuple/named tuple/struct is allocated on stack, immutable
t = {100, "hello"} # <= define a tuple literal
t1 = Tuple.new(Int32, String) # <= define a empty tuple

# create a empty Hash, Hash/Array/Class allocated on heap, mutable
h = {} of String => Int32
h1 = Hash(String, Int32).new # same as h
p! typeof(h) # => Hash(String, Int32)

# hash use hash rocket form.
h2 = {"one" => 1, "two" => 2}
# h2["three"] # => Unhandled exception: Missing hash key: "three" (KeyError)
p! h["three"]? # => nil

# named tuple use 1.9 new hash syntax
named_tuple1 = {one: 1, two: 2}

p! named_tuple1[:one] # => 1
p! named_tuple1["one"] # => 1
p! named_tuple1[:three]? # => nil


# ------------------------------ Others ------------------------------

# with keyword used to yield self to block. (ruby instance_eval)

class Foo11
  def one
    1
  end

  def yield_with_self
    with self yield
  end
end

Foo11.new.yield_with_self { one } # => 1

# define a macro use macro keyword
macro define_method(name, &block)
  def {{name.id}}
    {{block.body}}
  end
end

# run macro at compile time define a method at compile time.
define_method :greets do
  puts "Hi!"
end

greets # => "Hi!"

# macro are expanded on compile time
# {{...}} and {% ... %} are valid macro.

{{ 1 + 1 }}  # => genreate 2 and replace on compile time, like <%= ??? %> in ERB.

{% if env("TEST") %} # => like <% ??? %> in ERB.
  puts "We are in test mode"
{% end %}

{% begin %}
  {% count = 10 %} # => generate

  {% for i in (1..count) %}
    PI_{{i.id}} = Math::PI * {{i}}
  {% end %}
{% end %}
