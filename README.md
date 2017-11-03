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
* [Type string](#string)
  * [Length](#length)
  * [Regular Expression](#regex)
* [Types number, integer and float](#number)

### <a name="any"></a> Type any

The schema any will accept any data.

``` Elixir
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
