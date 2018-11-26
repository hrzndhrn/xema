# Usage

* [Type any](#any)
* [Type nil](#nil)
* [Type boolean](#boolean)
* [Type atom](#atom)
* [Type string](#string)
  * [Length](#length)
  * [Regular Expression](#regex)
  * [Format](#fmt)
* [Types number, integer and float](#number)
  * [Multiples](#multi)
  * [Range](#range)
* [Type list](#list)
  * [Items](#items)
  * [Additional Items](#additional_items)
  * [Length](#list_length)
  * [Uniqueness](#unique)
* [Type tuple](#tuple)
* [Type map](#map)
  * [Keys](#keys)
  * [Properties](#properties)
  * [Required Properties](#required_properties)
  * [Additional Properties](#additional_properties)
  * [Pattern Properties](#pattern_properties)
  * [Size](#map_size)
* [Type struct](#struct)
* [Multiples Types](#multi_types)
* [Allow Additional Types](#allow)
* [Constants](#const)
* [Enumerations](#enum)
* [Negate Schema](#not)
* [If-Then-Else](#if_then_else)
* [Combine Schemas](#combine)
* [Structuring a schema](#structuring)
  * [`definitions` and `ref`](#def-ref)
  * [without `definitions` and `ref`](#without-def-ref)
  * [in multiple files](#multiple-files)
* [Configure a resolver](#resolver)


## <a id="any"></a> Type any

The schema any will accept any data.

```elixir
iex> schema = Xema.new :any
iex> Xema.validate schema, 42
:ok
iex> Xema.validate schema, "foo"
:ok
iex> Xema.validate schema, nil
:ok
```

## <a id="nil"></a> Type nil

The nil type matches only `nil`.

```elixir
iex> schema = Xema.new :nil
iex> Xema.validate schema, nil
:ok
iex> Xema.validate schema, 0
{:error, %{type: :nil, value: 0}}
```

## <a id="boolean"></a> Type boolean

The boolean type matches only `true` and `false`.
```Elixir
iex> schema = Xema.new :boolean
iex> Xema.validate schema, true
:ok
iex> Xema.valid? schema, false
true
iex> Xema.validate schema, 0
{:error, %{type: :boolean, value: 0}}
iex> Xema.valid? schema, nil
false
```

## <a id="atom"></a> Type atom

The atom type matches only atoms. Schemas of type atom match also the atoms
`true`, `false`, and `nil`.
```Elixir
iex> schema = Xema.new :atom
iex> Xema.validate schema, :foo
:ok
iex> Xema.valid? schema, "foo"
false
iex> Xema.validate schema, 0
{:error, %{type: :atom, value: 0}}
iex> Xema.valid? schema, nil
true
iex> Xema.valid? schema, false
true
```

## <a id="string"></a> Type string

`JSON Schema Draft: 4/6/7`

The string type is used for strings.

```elixir
iex> schema = Xema.new :string
iex> Xema.validate schema, "José"
:ok
iex> Xema.validate schema, 42
{:error, %{type: :string, value: 42}}
iex> Xema.valid? schema, "José"
true
iex> Xema.valid? schema, 42
false
```

### <a id="length"></a> Length

The length of a string can be constrained using the `min_length` and `max_length`
keywords. For both keywords, the value must be a non-negative number.

```elixir
iex> schema = Xema.new {:string, min_length: 2, max_length: 3}
iex> Xema.validate schema, "a"
{:error, %{value: "a", min_length: 2}}
iex> Xema.validate schema, "ab"
:ok
iex> Xema.validate schema, "abc"
:ok
iex> Xema.validate schema, "abcd"
{:error, %{value: "abcd", max_length: 3}}
```

### <a id="regex"></a> Regular Expression

The `pattern` keyword is used to restrict a string to a particular regular
expression.

```Elixir
iex> schema = Xema.new {:string, pattern: ~r/[0-9]-[A-B]+/}
iex> Xema.validate schema, "1-AB"
:ok
iex> Xema.validate schema, "foo"
{:error, %{value: "foo", pattern: ~r/[0-9]-[A-B]+/}}
```

The regular expression can also be a string.

```Elixir
iex> schema = Xema.new {:string, pattern: "[0-9]-[A-B]+"}
iex> Xema.validate schema, "1-AB"
:ok
iex> Xema.validate schema, "foo"
{:error, %{value: "foo", pattern: ~r/[0-9]-[A-B]+/}}
```

### <a id="fmt"></a> Format

`JSON Schema Draft: 4/6/7`

Basic semantic validation of strings.

* `:date_time` validation as defined by [RFC 3339](https://tools.ietf.org/html/rfc3339)
```Elixir
iex> schema = Xema.new {:string, format: :date_time}
iex> Xema.valid? schema, "today"
false
iex> Xema.valid? schema, "1963-06-19T08:30:06.283185Z"
true
```

* `:email` validation as defined by [RFC 5322](https://tools.ietf.org/html/rfc5322)
```Elixir
iex> {:string, format: :email}
...> |> Xema.new()
...> |> Xema.valid?("marion.mustermann@otto.net")
true
```

* `:host` checks if the `string` is an valid IPv4, IPv6, or hostname.
* `:hostname` validation as defined by [RFC 1034](https://tools.ietf.org/html/rfc1034)
* `:ipv4` validation as defined by [RFC 2673](https://tools.ietf.org/html/rfc2673)
* `:ipv6` validation as defined by [RFC 2373](https://tools.ietf.org/html/rfc2373)
* `:uri` validation as defindex by [RFC 3986](https://tools.ietf.org/html/rfc3986)
  * `:uri_fragment`
  * `:uri_path`
  * `:uri_query`
  * `:uri_userinfo`

`JSON Schema Draft: -/-/7`

* `:regex`checks if the `string` is a valid regular expression.

## <a id="number"></a> Types number, integer and float
There are three numeric types in Xema: `number`, `integer` and `float`. They
share the same validation keywords.

The `number` type is used for numbers.
```Elixir
iex> schema = Xema.new :number
iex> Xema.validate schema, 42
:ok
iex> Xema.validate schema, 21.5
:ok
iex> Xema.validate schema, "foo"
{:error, %{type: :number, value: "foo"}}
```

The `integer` type is used for integral numbers.
```Elixir
iex> schema = Xema.new :integer
iex> Xema.validate schema, 42
:ok
iex> Xema.validate schema, 21.5
{:error, %{type: :integer, value: 21.5}}
```

The `float` type is used for floating point numbers.
```Elixir
iex> schema = Xema.new :float
iex> Xema.validate schema, 42
{:error, %{type: :float, value: 42}}
iex> Xema.validate schema, 21.5
:ok
```

### <a id="multi"></a> Multiples

`JSON Schema Draft: 4/6/7`

Numbers can be restricted to a multiple of a given number, using the
`multiple_of` keyword. It may be set to any positive number.

```Elixir
iex> schema = Xema.new {:number, multiple_of: 2}
iex> Xema.validate schema, 8
:ok
iex> Xema.validate schema, 7
{:error, %{value: 7, multiple_of: 2}}
iex> Xema.valid? schema, 8.0
true
```

### <a id="range"></a> Range

`JSON Schema Draft: 4/-/-`

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
iex> schema = Xema.new {
...>   :float,
...>   minimum: 1.2, maximum: 1.4, exclusive_maximum: true
...> }
iex> Xema.validate schema, 1.1
{:error, %{value: 1.1, minimum: 1.2}}
iex> Xema.validate schema, 1.2
:ok
iex> Xema.valid? schema, 1.3
true
iex> Xema.validate schema, 1.4
{:error, %{value: 1.4, maximum: 1.4, exclusive_maximum: true}}
iex> Xema.validate schema, 1.5
{:error, %{value: 1.5, maximum: 1.4, exclusive_maximum: true}}
```

`JSON Schema Draft: 6/7`

The keywords `exclusive_maximum` and `exclusive_minimum` changed from a boolean
to a number. Wherever one of these would be `true` before, they have now the
value of the corresponding keyword `maximum` or `minimum`. The keyword
`maximum`/`minimum` can be removed.

```Elixir
iex> schema = Xema.new {:float, minimum: 1.2, exclusive_maximum: 1.4}
iex> Xema.validate schema, 1.1
{:error, %{value: 1.1, minimum: 1.2}}
iex> Xema.validate schema, 1.2
:ok
iex> Xema.valid? schema, 1.3
true
iex> Xema.validate schema, 1.4
{:error, %{value: 1.4, exclusive_maximum: 1.4}}
iex> Xema.validate schema, 1.5
{:error, %{value: 1.5, exclusive_maximum: 1.4}}
```

## <a id="list"></a> Type list

List are used for ordered elements, each element may be of a different type.

```Elixir
iex> schema = Xema.new :list
iex> Xema.valid? schema, [1, "two", 3.0]
true
iex> Xema.validate schema, 9
{:error, %{type: :list, value: 9}}
```

### <a id="items"></a> Items
The `items` keyword will be used to validate all items of a list to a single
schema.

```Elixir
iex> schema = Xema.new {:list, items: :string}
iex> Xema.valid? schema, ["a", "b", "abc"]
true
iex> Xema.validate schema, ["a", 1]
{:error, %{items: [{1, %{type: :string, value: 1}}]}}
```

The next example shows how to add keywords to the items schema.

```Elixir
iex> schema = Xema.new {:list, items: {:integer, minimum: 1, maximum: 10}}
iex> Xema.validate schema, [1, 2, 3]
:ok
iex> Xema.validate schema, [3, 2, 1, 0]
{:error, %{items: [{3, %{value: 0, minimum: 1}}]}}
```

`items` can also be used to give each item a specific schema.

```Elixir
iex> schema = Xema.new {
...>   :list,
...>   items: [:integer, {:string, min_length: 5}]
...> }
iex> Xema.valid? schema, [1, "hello"]
true
iex> Xema.validate schema, [1, "five"]
{
  :error,
  %{items: [{1, %{value: "five", min_length: 5}}]}
}
# It’s okay to not provide all of the items:
iex> Xema.validate schema, [1]
:ok
# And, by default, it’s also okay to add additional items to end:
iex> Xema.validate schema, [1, "hello", "foo"]
:ok
```

### <a id="additional_items"></a> Additional Items

The `additional_items` keyword controls whether it is valid to have additional
items in the array beyond what is defined in the schema.

```Elixir
iex> schema = Xema.new {
...>   :list,
...>   items: [:integer, {:string, min_length: 5}],
...>   additional_items: false
...> }
iex> Xema.validate schema, [1]
:ok
# It’s okay to not provide all of the items:
# But, since additionalItems is false, we can’t provide extra items:
iex> Xema.validate schema, [1, "hello", "foo"]
{:error, %{items: [{2, %{additional_items: false}}]}}
iex> Xema.validate schema, [1, "hello", "foo", "bar"]
{:error, %{items: [
  {2, %{additional_items: false}},
  {3, %{additional_items: false}}
]}}
```

The keyword can also contain a schema to specify the type of additional items.
```Elixir
iex> schema = Xema.new {
...>   :list,
...>   items: [:integer, {:string, min_length: 3}],
...>   additional_items: :integer
...> }
iex> Xema.valid? schema, [1, "two", 3, 4]
true
iex> Xema.validate schema, [1, "two", 3, "four"]
{:error, %{items: [{3, %{type: :integer, value: "four"}}]}}
```

### <a id="list_length"></a> Length

The length of the array can be specified using the `min_items` and `max_items`
keywords. The value of each keyword must be a non-negative number.

```Elixir
iex> schema = Xema.new {:list, min_items: 2, max_items: 3}
iex> Xema.validate schema, [1]
{:error, %{value: [1], min_items: 2}}
iex> Xema.validate schema, [1, 2]
:ok
iex> Xema.validate schema, [1, 2, 3]
:ok
iex> Xema.validate schema, [1, 2, 3, 4]
{:error, %{value: [1, 2, 3, 4], max_items: 3}}
```

### <a id="unique"></a> Uniqueness

A schema can ensure that each of the items in an array is unique.

```Elixir
iex> schema = Xema.new {:list, unique_items: true}
iex> Xema.valid? schema, [1, 2, 3]
true
iex> Xema.validate schema, [1, 2, 3, 2, 1]
{:error, %{value: [1, 2, 3, 2, 1], unique_items: true}}
```

## <a id="tuple"></a> Type tuple

Tuples are intended as fixed-size containers for multiple elements. The
validation of tuples is similar to lists.

```Elixir
iex> schema = Xema.new {:tuple, min_items: 2, max_items: 3}
iex> Xema.validate schema, {1}
{:error, %{value: {1}, min_items: 2}}
iex> Xema.validate schema, {1, 2}
:ok
iex> Xema.validate schema, {1, 2, 3}
:ok
iex> Xema.validate schema, {1, 2, 3, 4}
{:error, %{value: {1, 2, 3, 4}, max_items: 3}}
```

## <a id="map"></a> Type map

Whenever you need a key-value store, maps are the “go to” data structure in
Elixir. Each of these pairs is conventionally referred to as a “property”.

```Elixir
iex> schema = Xema.new :map
iex> Xema.valid? schema, %{"foo" => "bar"}
true
iex> Xema.validate schema, "bar"
{:error, %{type: :map, value: "bar"}}
# Using non-strings as keys are also valid:
iex> Xema.valid? schema, %{foo: "bar"}
true
iex> Xema.valid? schema, %{1 => "bar"}
true
```

### <a id="keys"></a> Keys

The keyword `keys` can restrict the keys to atoms or strings.

Atoms as keys:
```Elixir
iex> schema = Xema.new {:map, keys: :atoms}
iex> Xema.valid? schema, %{"foo" => "bar"}
false
iex> Xema.valid? schema, %{foo: "bar"}
true
iex> Xema.valid? schema, %{1 => "bar"}
false
```

Strings as keys:
```Elixir
iex> schema = Xema.new {:map, keys: :strings}
iex> Xema.valid? schema, %{"foo" => "bar"}
true
iex> Xema.valid? schema, %{foo: "bar"}
false
iex> Xema.valid? schema, %{1 => "bar"}
false
```

### <a id="properties"></a> Properties

The properties on a map are defined using the `properties` keyword. The value
of properties is a map, where each key is the name of a property and each
value is a schema used to validate that property.

```Elixir
iex> schema = Xema.new {:map,
...>   properties: %{
...>     a: :integer,
...>     b: {:string, min_length: 5}
...>   }
...> }
iex> Xema.valid? schema, %{a: 5, b: "hello"}
true
iex> Xema.validate schema, %{a: 5, b: "ups"}
{:error, %{properties: %{
  b: %{
    value: "ups",
    min_length: 5
  }
}}}
# Additinonal properties are allowed by default:
iex> Xema.valid? schema, %{a: 5, b: "hello", add: :prop}
true
```

### <a id="required_properties"></a> Required Properties

By default, the properties defined by the properties keyword are not required.
However, one can provide a list of `required` properties using the required
keyword.

```Elixir
iex> schema = Xema.new {:map, properties: %{foo: :string}, required: [:foo]}
iex> Xema.validate schema, %{foo: "bar"}
:ok
iex> Xema.validate schema, %{bar: "foo"}
{:error, %{required: [:foo]}}
```

### <a id="additional_properties"></a> Additional Properties

The `additional_properties` keyword is used to control the handling of extra
stuff, that is, properties whose names are not listed in the properties keyword.
By default any additional properties are allowed.

The `additional_properties` keyword may be either a boolean or an schema. If
`additional_properties` is a boolean and set to false, no additional properties
will be allowed.

```Elixir
iex> schema = Xema.new {:map,
...>   properties: %{foo: :string},
...>   required: [:foo],
...>   additional_properties: false
...> }
iex> Xema.validate schema, %{foo: "bar"}
:ok
iex> Xema.validate schema, %{foo: "bar", bar: "foo"}
{:error, %{properties: %{
  bar: %{additional_properties: false}
}}}
```

`additional_properties` can also contain a schema to specify the type of
additional properites.

```Elixir
iex> schema = Xema.new {
...>   :map,
...>   properties: %{foo: :string},
...>   additional_properties: :integer
...> }
iex> Xema.valid? schema, %{foo: "foo", add: 1}
true
iex> Xema.validate schema, %{foo: "foo", add: "one"}
{:error, %{
  add: %{type: :integer, value: "one"}
}}
```

### <a id="pattern_properties"></a> Pattern Properties

The keyword `pattern_properties` defined additional properties by regular
expressions.

```Elixir
iex> schema = Xema.new {
...>   :map,
...>   additional_properties: false,
...>   pattern_properties: %{
...>     ~r/^s_/ => :string,
...>     ~r/^i_/ => :integer
...>   }
...> }
iex> Xema.valid? schema, %{"s_0" => "foo", "i_1" => 6}
true
iex> Xema.valid? schema, %{s_0: "foo", i_1: 6}
true
iex> Xema.validate schema, %{s_0: "foo", f_1: 6.6}
{:error, %{properties: %{
  f_1: %{additional_properties: false}
}}}
```

### <a id="map_size"></a> Size

The number of properties on an object can be restricted using the
`min_properties` and `max_properties` keywords.

```Elixir
iex> schema = Xema.new {:map,
...>   min_properties: 2,
...>   max_properties: 3
...> }
iex> Xema.valid? schema, %{a: 1, b: 2}
true
iex> Xema.validate schema, %{}
{:error, %{min_properties: 2}}
iex> Xema.validate schema, %{a: 1, b: 2, c: 3, d: 4}
{:error, %{max_properties: 3}}
```

### <a id="dependencies"></a> Dependencies

The `dependencies` keyword allows the schema of the object to change based on
the presence of certain special properties.

```Elixir
iex> schema = Xema.new {
...>   :map,
...>   properties: %{
...>     a: :number,
...>     b: :number,
...>     c: :number
...>   },
...>   dependencies: %{
...>     b: [:c]
...>   }
...> }
iex> Xema.valid? schema, %{a: 5}
true
iex> Xema.valid? schema, %{c: 9}
true
iex> Xema.valid? schema, %{b: 1}
false
iex> Xema.valid? schema, %{b: 1, c: 7}
true
```

## <a id="struct"></a> Type struct

Structs can also be validated.

```Elixir
iex> schema = Xema.new :struct
iex> Xema.valid? schema, ~r/.*/
true
iex> Xema.valid? schema, %{}
false
```

### <a id="module"</a> Module

The `module` keyword allows specifing which struct is expected.

```Elixir
iex> schema = Xema.new {:struct, module: Regex}
iex> Xema.valid? schema, ~r/.*/
true
iex> Xema.valid? schema, URI.parse("")
false
```

## <a id="multi_types"></a> Multiples Types

`JSON Schema Draft: 4/6/7`

It is also possible to check if a value matches one of several types.

```Elixir
iex> schema = Xema.new {[:string, nil], min_length: 1}
iex> Xema.valid? schema, "foo"
true
iex> Xema.valid? schema, nil
true
iex> Xema.valid? schema, ""
false
```

## <a id="allow"></a> Allow Additional Types

`JSON Schema Draft: -`

The keyword `allow` adds an extra type to the schema validation.

```Elixir
iex> schema = Xema.new {:string, min_length: 1, allow: nil}
iex> Xema.valid? schema, "foo"
true
iex> Xema.valid? schema, nil
true
iex> Xema.valid? schema, ""
false
```

## <a id="const"></a> Constants

`JSON Schema Draft: -/6/7`

This keyword checks if a value is equals to the given `const`.

```Elixir
iex> schema = Xema.new(const: 4711)
iex> Xema.validate schema, 4711
:ok
iex> Xema.validate schema, 333
{:error, %{const: 4711, value: 333}}
```

## <a id="enum"></a> Enumerations

The `enum` keyword is used to restrict a value to a fixed set of values. It must
be an array with at least one element, where each element is unique.

```Elixir
iex> schema = Xema.new {:any, enum: [1, "foo", :bar]}
iex> Xema.valid? schema, :bar
true
iex> Xema.valid? schema, 42
false
```

## <a id="not"></a> Negate Schema

The keyword `not` negates a schema.

```Elixir
iex> schema = Xema.new(not: {:integer, minimum: 0})
iex> Xema.valid? schema, 10
false
iex> Xema.valid? schema, -10
true
```
## <a id="if_then_else"></a> If-Then-Else

The keywords `if`, `then`, `else` work together to implement conditional
application of a subschema based on the outcome of another subschema.

```Elixir
iex> schema =
...>   Xema.new(
...>     if: :list,
...>     then: [items: :integer, min_items: 2],
...>     else: :integer
...>   )
...>
...> Xema.valid?(schema, 3)
true
iex> Xema.valid?(schema, "3")
false
iex> Xema.valid?(schema, [1])
false
iex> Xema.valid?(schema, [1, 2])
true
```

## <a id="combine"></a> Combine Schemas

The keywords `all_of`, `any_of`, and `one_of` combines schemas.

With `all_of` all schemas have to match.
```Elixir
iex> all = Xema.new(all_of: [
...>   {:integer, multiple_of: 2},
...>   {:integer, multiple_of: 3}
...> ])
iex> 0..9 |> Enum.map(&Xema.valid?(all, &1)) |> Enum.with_index()
[true: 0, false: 1, false: 2, false: 3, false: 4,
 false: 5, true: 6, false: 7, false: 8, false: 9]
```

With `any_of` any schema have to match.

```Elixir
iex> any = Xema.new(any_of: [
...>   {:integer, multiple_of: 2},
...>   {:integer, multiple_of: 3}
...> ])
iex> 0..9 |> Enum.map(&Xema.valid?(any, &1)) |> Enum.with_index()
[true: 0, false: 1, true: 2, true: 3, true: 4,
 false: 5, true: 6, false: 7, true: 8, true: 9]
```

With `one_of` exactly on schema have to match.

```Elixir
iex> one = Xema.new(one_of: [
...>   {:integer, multiple_of: 2},
...>   {:integer, multiple_of: 3}
...> ])
iex> 0..9 |> Enum.map(&Xema.valid?(one, &1)) |> Enum.with_index()
[false: 0, false: 1, true: 2, true: 3, true: 4,
 false: 5, false: 6, false: 7, true: 8, true: 9]
```

## <a id="structuring"></a> Structuring a schema

This section will present some options to structuring and reuse schemas.

### <a id="def-ref"></a> `definitions` and `ref`

To reuse a schema put it under the keyword `definitions`. Later on, the schema
can be referenced with the keyword `ref`.

```Elixir
iex> schema = Xema.new {
...>   :map,
...>   definitions: %{
...>     positive: {:integer, minimum: 1},
...>     negative: {:integer, maximum: -1}
...>   },
...>   properties: %{
...>     a: {:ref, "#/definitions/positive"},
...>     b: {:ref, "#/definitions/positive"},
...>     c: {:ref, "#/definitions/negative"},
...>     # You can also reference any other schema.
...>     d: {:ref, "#/properties/c"}
...>   }
...> }
...> Xema.validate schema, %{a: 1, c: -1}
:ok
iex> Xema.validate schema, %{b: 1, c: 1}
{:error, %{properties: %{c: %{maximum: -1, value: 1}}}}
iex> Xema.validate schema, %{d: -1}
:ok
iex> Xema.validate schema, %{d: 1}
{:error, %{properties: %{d: %{maximum: -1, value: 1}}}}
```

### <a id="without-def-ref"></a> Without `definitions` and `ref`

It is also possible to use a schema in another schema, as in the following code.

```Elixir
iex> positive = Xema.new {:integer, minimum: 1}
...> negative = Xema.new {:integer, maximum: -1}
...> schema = Xema.new {
...>   :map,
...>   properties: %{
...>     a: positive,
...>     b: positive,
...>     c: negative
...>   }
...> }
...> Xema.validate schema, %{a: 1, b: 2, c: -3}
:ok
```

### <a id="multiple-files"></a> In multiple files

To structure schemas in multiple files you have to configure a resolver to laod
the files. The section "[Configure a resolver](#resolver)" described the
configuration and implementation of an resolver.

Let's assume you have the following file available at
https://localhost:1234/positive.exon.

```Elixir
{
  :string,
  definitions: %{
    or_nil: {:any_of, [:nil, {:ref, "#"}]}
  }
}
```

I admit this example is a little absurd.
But the URL could be also any other URL and with another resolver, the file
could be on your hard disk.

You can use the schema above as follow.

```Elixir
iex> schema = Xema.new {
...>   :map,
...>   id: "http://localhost:1234",
...>   properties: %{
...>     name: {:ref, "xema_name.exon#/definitions/or_nil"},
...>     str: {:ref, "xema_name.exon"}
...>   }
...> }
...> Xema.validate schema, %{str: "foo"}
:ok
iex> Xema.validate schema, %{str: nil}
{:error, %{properties: %{str: %{type: :string, value: nil}}}}
iex> Xema.validate schema, %{name: nil}
:ok
iex> Xema.validate schema, %{name: "Funny van Dannen"}
:ok
iex> Xema.validate schema, %{name: 66}
{:error,
  %{
    properties: %{
      name: %{any_of: [
        %{type: nil, value: 66},
        %{type: :string, value: 66}
      ],
      value: 66}
    }
  }
}
```


## <a id="resolver"></a> Configure a resolver

A resolver will be configured like this.

```Elixir
config :xema, resolver: My.Resolver
```

`My.Resolver` is a module which use the behaviour `Xema.Resolver`.

```Elixir
defmodule Test.Resolver do
  @moduledoc false

  @behaviour Xema.Resolver

  @spec fetch(binary) :: {:ok, map} | {:error, any}
  def fetch(uri) do
    with {:ok, response} <- get(uri), do: eval(response, uri)
  end

  defp get(uri) do
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Remote schema '#{uri}' not found."}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "code: #{code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp eval(str, uri) do
    {data, _} = Code.eval_string(str)
    {:ok, data}
  rescue
    error -> {:error, %{error | file: URI.to_string(uri)}}
  end
end
```

The function `get/1` will be called by `Xema` and expects a `binary`. In the
example in the section
"[Structuring schemas in multiple files](#multiple-files)" `get/1` gets the
`binary` `"http://localhost:1234/xema_name.exon"`.

**Note!** This resolver use `Code.eval_string/1` and eval is always evil.

> **Warning:** string can be any Elixir code and will be executed with the same
> privileges as the Erlang VM: this means that such code could compromise the
> machine (for example by executing system commands). Don’t use `eval_string/3`
> with untrusted input (such as strings coming from the network).
> -- Elixir API
