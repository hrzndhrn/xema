# Xema

Xema is a schema validator inspired by [JSON Schema](http://json-schema.org).

Xema allows you to annotate and validate elixir data structures.

Xema is in early beta. If you try it and has an issue, report them.

## Installation

First, add Xema to your `mix.exs` dependencies:

```elixir
def deps do
  [{:xema, "~> 0.1"}]
end
```

Then, update your dependencies:

```Shell
$ mix deps.get
```

## Usage

Xema supported the following types to validate data structures.

* [Type any](#any)
* [Type nil](#nil)
* [Type boolean](#boolean)
* [Type string](#string)
  * [Length](#length)
  * [Regular Expression](#regex)
* [Types number, integer and float](#number)
  * [Multiples](multi)
  * [Range](range)

### <a name="any"></a> Type any

The schema any will accept any data.

```elixir
iex> import Xema
Xema
iex> schema = xema :any
%Xema{type: %Xema.Any{}}
iex> validate schema, 42
:ok
iex> validate schema, "foo"
:ok
iex> validate schema, nil
:ok
```

### <a name="nil"></a> Type nil

The nil type matches only `nil`.

```elixir
iex> import Xema
Xema
iex> schema = xema :nil
%Xema{type: %Xema.Nil{}}
iex> validate schema, nil
:ok
iex> validate schema, 0
{:error, %{reason: :wrong_type, type: :nil}}
```

### <a name="boolean"></a> Type boolean

The boolean type matches only `true` and `false`.
```Elixir
iex> import Xema
Xema
iex> schema = xema :boolean
%Xema{type: %Xema.Boolean{}}
iex> validate schema, true
:ok
iex> is_valid? schema, false
true
iex> validate schema, 0
{:error, %{reason: :wrong_type, type: :boolean}}
iex> is_valid? schema, nil
false
```

### <a name="string"></a> Type string

The string type is used for strings.

```elixir
iex> import Xema
Xema
iex> schema = xema :string
%Xema{type: %Xema.String{}}
iex> validate schema, "José"
:ok
iex> validate schema, 42
{:error, %{reason: :wrong_type, type: :string}}
iex> is_valid? schema, "José"
true
iex> is_valid? schema, 42
false
```

#### <a name="length"></a> Length

The length of a string can be constrained using the `min_length` and `max_length` keywords. For both keywords, the value must be a non-negative number.

```elixir
iex> import Xema
Xema
iex> schema = xema :string, min_length: 2, max_length: 3
%Xema{type: %Xema.String{min_length: 2, max_length: 3}}
iex> validate schema, "a"
{:error, %{reason: :too_short, min_length: 2}}
iex> validate schema, "ab"
:ok
iex> validate schema, "abc"
:ok
iex> validate schema, "abcd"
{:error, %{reason: :too_long, max_length: 3}}
```

#### <a name="regex"></a> Regular Expression

The `pattern` keyword is used to restrict a string to a particular regular expression.

```Elixir
iex> import Xema
Xema
iex> schema = xema :string, pattern: ~r/[0-9]-[A-B]+/
%Xema{type: %Xema.String{pattern: ~r/[0-9]-[A-B]+/}}
iex> validate schema, "1-AB"
:ok
iex> validate schema, "foo"
{:error, %{reason: :no_match, pattern: ~r/[0-9]-[A-B]+/}}
```

### <a name="number"></a> Types number, integer and float
There are three numeric types in Xema: `number`, `integer` and `float`. They
share the same validation keywords.

The `number` type is used for numbers.
```Elixir
iex> import Xema
Xema
iex> schema = xema :number
%Xema{type: %Xema.Number{}}
iex> validate schema, 42
:ok
iex> validate schema, 21.5
:ok
iex> validate schema, "foo"
{:error, %{reason: :wrong_type, type: :number}}
```

The `integer` type is used for integral numbers.
```Elixir
iex> import Xema
Xema
iex> schema = xema :integer
%Xema{type: %Xema.Integer{}}
iex> validate schema, 42
:ok
iex> validate schema, 21.5
{:error, %{reason: :wrong_type, type: :integer}}
```

The `float` type is used for floating point numbers.
```Elixir
iex> import Xema
Xema
iex> schema = xema :float
%Xema{type: %Xema.Float{}}
iex> validate schema, 42
{:error, %{reason: :wrong_type, type: :float}}
iex> validate schema, 21.5
:ok
```

#### <a name="multi"></a> Multiples
Numbers can be restricted to a multiple of a given number, using the
`multiple_of` keyword. It may be set to any positive number.

```Elixir
iex> import Xema
Xema
iex> schema = xema :number, multiple_of: 2
%Xema{type: %Xema.Number{multiple_of: 2}}
iex> validate schema, 8
:ok
iex> validate schema, 7
{:error, %{reason: :not_multiple, multiple_of: 2}}
iex> is_valid? schema, 8.0
true
```

#### <a name="range"></a> Range
Ranges of numbers are specified using a combination of the `minimum`, `maximum`,
`exclusive_minimum` and `exclusive_maximum` keywords.
* `minimum` specifies a minimum numeric value.
* `exclusive_minimum` is a boolean. When true, it indicates that the range
   excludes the minimum value, i.e., x > minx > min. When false (or not included),
   it indicates that the range includes the minimum value, i.e., x≥minx≥min.
* `maximum` specifies a maximum numeric value.
* `exclusive_maximum` is a boolean. When true, it indicates that the range
   excludes the maximum value, i.e., x < maxx < max. When false (or not
   included), it indicates that the range includes the maximum value, i.e., x ≤
   maxx ≤ max.

```Elixir
iex> import Xema
Xema
iex> schema = xema :float, minimum: 1.2, maximum: 1.4, exclusive_maximum: true
%Xema{type: %Xema.Float{minimum: 1.2, maximum: 1.4, exclusive_maximum: true}}
iex> validate schema, 1.1
{:error, %{reason: :too_small, minimum: 1.2}}
iex> validate schema, 1.2
:ok
iex> is_valid? schema, 1.3
true
iex> validate schema, 1.4
{:error, %{reason: :too_big, maximum: 1.4, exclusive_maximum: true}}
iex> validate schema, 1.5
{:error, %{reason: :too_big, maximum: 1.4}}
```

### List
List are used for ordered elements, each element may be of a different type.

#### Items
The `items` keyword will be used to validate all items of a list to a single
schema.

```Elixir
iex> import Xema
Xema
iex> schema = xema :list, items: :string
%Xema{type: %Xema.List{items: %Xema.String{}}}
iex> is_valid? schema, ["a", "b", "abc"]
true
iex> validate schema, ["a", 1]
{
  :error,
  %{reason: :invalid_item, at: 1, error: %{reason: :wrong_type, type: :string}}
}
```

The next example shows how to add keywords to the items schema.

```Elixir
iex> import Xema
Xema
iex> schema = xema :list, items: {:integer, minimum: 1, maximum: 10}
%Xema{type: %Xema.List{items: %Xema.Integer{minimum: 1, maximum: 10}}}
iex> validate schema, [1, 2, 3]
:ok
iex> validate schema, [3, 2, 1, 0]
{
  :error,
  %{reason: :invalid_item, at: 3, error: %{reason: :too_small, minimum: 1}}
}
```

`items` can also be used to give each item a specific schema.

```Elixir
iex> import Xema
Xema
iex> schema = xema :list,
...>   items: [:integer, {:string, min_length: 5}]
%Xema{type: %Xema.List{
  items: [%Xema.Integer{}, %Xema.String{min_length: 5}]
}}
iex> is_valid? schema, [1, "hello"]
true
iex> validate schema, [1, "five"]
{
  :error,
  %{reason: :invalid_item, at: 1, error: %{reason: :too_short, min_length: 5}}
}
# It’s okay to not provide all of the items:
iex> validate schema, [1]
{:ok}
# And, by default, it’s also okay to add additional items to end:
iex> validate schema, [1, "hello", "foo"]
{:ok}
```

## References

The home of JSON Schema: http://json-schema.org/

Specification:

* [JSON Schema core](http://json-schema.org/latest/json-schema-core.html)
defines the basic foundation of JSON Schema
* [JSON Schema Validation](http://json-schema.org/latest/json-schema-validation.html)
defines the validation keywords of JSON Schema


[Understanding JSON Schema](https://spacetelescope.github.io/understanding-json-schema/index.html)
a great tutorial for JSON Schema authors and a template for the description of
Xema.
