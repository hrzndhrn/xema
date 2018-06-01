# Usage

* [Type any](#any)
* [Type nil](#nil)
* [Type boolean](#boolean)
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
* [Type map](#map)
  * [Keys](#keys)
  * [Properties](#properties)
  * [Required Properties](#required_properties)
  * [Additional Properties](#additional_properties)
  * [Pattern Properties](#pattern_properties)
  * [Size](#map_size)
* [Multiples Types](#multi)
* [Allow Additional Types](#allow)
* [Enumerations](#enum)
* [Negate Schema](#not)
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
%Xema{content: %Xema.Schema{type: :any}}
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
%Xema{content: %Xema.Schema{type: :nil}}
iex> Xema.validate schema, nil
:ok
iex> Xema.validate schema, 0
{:error, %{type: :nil, value: 0}}
```

## <a id="boolean"></a> Type boolean

The boolean type matches only `true` and `false`.
```Elixir
iex> schema = Xema.new :boolean
%Xema{content: %Xema.Schema{type: :boolean}}
iex> Xema.validate schema, true
:ok
iex> Xema.is_valid? schema, false
true
iex> Xema.validate schema, 0
{:error, %{type: :boolean, value: 0}}
iex> Xema.is_valid? schema, nil
false
```

## <a id="string"></a> Type string

`JSON Schema Draft: 4/6/7`

The string type is used for strings.

```elixir
iex> schema = Xema.new :string
%Xema{content: %Xema.Schema{type: :string}}
iex> Xema.validate schema, "José"
:ok
iex> Xema.validate schema, 42
{:error, %{type: :string, value: 42}}
iex> Xema.is_valid? schema, "José"
true
iex> Xema.is_valid? schema, 42
false
```

### <a id="length"></a> Length

The length of a string can be constrained using the `min_length` and `max_length`
keywords. For both keywords, the value must be a non-negative number.

```elixir
iex> schema = Xema.new :string, min_length: 2, max_length: 3
%Xema{content:
  %Xema.Schema{min_length: 2, max_length: 3, type: :string}
}
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
iex> schema = Xema.new :string, pattern: ~r/[0-9]-[A-B]+/
%Xema{content: %Xema.Schema{type: :string, pattern: ~r/[0-9]-[A-B]+/}}
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
iex> schema = Xema.new :string, format: :date_time
%Xema{content: %Xema.Schema{type: :string, format: :date_time}}
iex> Xema.is_valid? schema, "today"
false
iex> Xema.is_valid? schema, "1963-06-19T08:30:06.283185Z"
true
```

* `:email` validation as defined by [RFC 5322](https://tools.ietf.org/html/rfc5322)
```Elixir
iex> :string
...> |> Xema.new(format: :email)
...> |> Xema.is_valid?("marion.mustermann@otto.net")
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
%Xema{content: %Xema.Schema{type: :number}}
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
%Xema{content: %Xema.Schema{type: :integer}}
iex> Xema.validate schema, 42
:ok
iex> Xema.validate schema, 21.5
{:error, %{type: :integer, value: 21.5}}
```

The `float` type is used for floating point numbers.
```Elixir
iex> schema = Xema.new :float
%Xema{content: %Xema.Schema{type: :float}}
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
iex> schema = Xema.new :number, multiple_of: 2
%Xema{content: %Xema.Schema{type: :number, multiple_of: 2}}
iex> Xema.validate schema, 8
:ok
iex> Xema.validate schema, 7
{:error, %{value: 7, multiple_of: 2}}
iex> Xema.is_valid? schema, 8.0
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
iex> schema = Xema.new :float,
...> minimum: 1.2, maximum: 1.4, exclusive_maximum: true
%Xema{content: %Xema.Schema{
  type: :float,
  minimum: 1.2,
  maximum: 1.4,
  exclusive_maximum: true
}}
iex> Xema.validate schema, 1.1
{:error, %{value: 1.1, minimum: 1.2}}
iex> Xema.validate schema, 1.2
:ok
iex> Xema.is_valid? schema, 1.3
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
iex> schema = Xema.new :float, minimum: 1.2, exclusive_maximum: 1.4
%Xema{content: %Xema.Schema{
  type: :float,
  minimum: 1.2,
  exclusive_maximum: 1.4
}}
iex> Xema.validate schema, 1.1
{:error, %{value: 1.1, minimum: 1.2}}
iex> Xema.validate schema, 1.2
:ok
iex> Xema.is_valid? schema, 1.3
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
%Xema{content: %Xema.Schema{type: :list}}
iex> Xema.is_valid? schema, [1, "two", 3.0]
true
iex> Xema.validate schema, 9
{:error, %{type: :list, value: 9}}
```

### <a id="items"></a> Items
The `items` keyword will be used to validate all items of a list to a single
schema.

```Elixir
iex> schema = Xema.new :list, items: :string
%Xema{content: %Xema.Schema{
  type: :list,
  items: %Xema.Schema{type: :string}
}}
iex> Xema.is_valid? schema, ["a", "b", "abc"]
true
iex> Xema.validate schema, ["a", 1]
{:error, [{1, %{type: :string, value: 1}}]}
```

The next example shows how to add keywords to the items schema.

```Elixir
iex> schema = Xema.new :list, items: {:integer, minimum: 1, maximum: 10}
%Xema{content: %Xema.Schema{
  type: :list,
  items: %Xema.Schema{type: :integer, minimum: 1, maximum: 10}
}}
iex> Xema.validate schema, [1, 2, 3]
:ok
iex> Xema.validate schema, [3, 2, 1, 0]
{:error, [{3, %{value: 0, minimum: 1}}]}
```

`items` can also be used to give each item a specific schema.

```Elixir
iex> schema = Xema.new :list,
...>   items: [:integer, {:string, min_length: 5}]
%Xema{content: %Xema.Schema{
  type: :list,
  items: [
    %Xema.Schema{type: :integer},
    %Xema.Schema{type: :string, min_length: 5}
  ]
}}
iex> Xema.is_valid? schema, [1, "hello"]
true
iex> Xema.validate schema, [1, "five"]
{
  :error,
  [{1, %{value: "five", min_length: 5}}]
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
iex> schema = Xema.new :list,
...>   items: [:integer, {:string, min_length: 5}],
...>   additional_items: false
%Xema{content: %Xema.Schema{
  type: :list,
  items: [
    %Xema.Schema{type: :integer},
    %Xema.Schema{type: :string, min_length: 5}
  ],
  additional_items: false
}}
# It’s okay to not provide all of the items:
iex> Xema.validate schema, [1]
:ok
# But, since additionalItems is false, we can’t provide extra items:
iex> Xema.validate schema, [1, "hello", "foo"]
{:error, [{2, %{additional_items: false}}]}
iex> Xema.validate schema, [1, "hello", "foo", "bar"]
{:error, [
  {2, %{additional_items: false}},
  {3, %{additional_items: false}}
]}
```

The keyword can also contain a schema to specify the type of additional items.
```Elixir
iex> schema = Xema.new :list,
...>   items: [:integer, {:string, min_length: 3}],
...>   additional_items: :integer
%Xema{content: %Xema.Schema{
  type: :list,
  items: [
    %Xema.Schema{type: :integer},
    %Xema.Schema{type: :string, min_length: 3}
  ],
  additional_items: %Xema.Schema{type: :integer}
}}
iex> Xema.is_valid? schema, [1, "two", 3, 4]
true
iex> Xema.validate schema, [1, "two", 3, "four"]
{:error, [{3, %{type: :integer, value: "four"}}]}
```

### <a id="list_length"></a> Length

The length of the array can be specified using the `min_items` and `max_items`
keywords. The value of each keyword must be a non-negative number.

```Elixir
iex> schema = Xema.new :list, min_items: 2, max_items: 3
%Xema{content: %Xema.Schema{min_items: 2, max_items: 3, type: :list}}
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
iex> schema = Xema.new :list, unique_items: true
%Xema{content: %Xema.Schema{type: :list, unique_items: true}}
iex> Xema.is_valid? schema, [1, 2, 3]
true
iex> Xema.validate schema, [1, 2, 3, 2, 1]
{:error, %{value: [1, 2, 3, 2, 1], unique_items: true}}
```

## <a id="map"></a> Type map

Whenever you need a key-value store, maps are the “go to” data structure in
Elixir. Each of these pairs is conventionally referred to as a “property”.

```Elixir
iex> schema = Xema.new :map
%Xema{content: %Xema.Schema{type: :map}}
iex> Xema.is_valid? schema, %{"foo" => "bar"}
true
iex> Xema.validate schema, "bar"
{:error, %{type: :map, value: "bar"}}
# Using non-strings as keys are also valid:
iex> Xema.is_valid? schema, %{foo: "bar"}
true
iex> Xema.is_valid? schema, %{1 => "bar"}
true
```

### <a id="keys"></a> Keys

The keyword `keys` can restrict the keys to atoms or strings.

Atoms as keys:
```Elixir
iex> schema = Xema.new :map, keys: :atoms
%Xema{content: %Xema.Schema{type: :map, keys: :atoms}}
iex> Xema.is_valid? schema, %{"foo" => "bar"}
false
iex> Xema.is_valid? schema, %{foo: "bar"}
true
iex> Xema.is_valid? schema, %{1 => "bar"}
false
```

Strings as keys:
```Elixir
iex> schema = Xema.new :map, keys: :strings
%Xema{content: %Xema.Schema{type: :map, keys: :strings}}
iex> Xema.is_valid? schema, %{"foo" => "bar"}
true
iex> Xema.is_valid? schema, %{foo: "bar"}
false
iex> Xema.is_valid? schema, %{1 => "bar"}
false
```

### <a id="properties"></a> Properties

The properties on a map are defined using the `properties` keyword. The value
of properties is a map, where each key is the name of a property and each
value is a schema used to validate that property.

```Elixir
iex> schema = Xema.new :map,
...>   properties: %{
...>     a: :integer,
...>     b: {:string, min_length: 5}
...>   }
%Xema{content: %Xema.Schema{
  type: :map,
  properties: %{
    a: %Xema.Schema{type: :integer},
    b: %Xema.Schema{type: :string, min_length: 5}
  }
}}
iex> Xema.is_valid? schema, %{a: 5, b: "hello"}
true
iex> Xema.validate schema, %{a: 5, b: "ups"}
{:error, %{properties: %{
  b: %{
    value: "ups",
    min_length: 5
  }
}}}
# Additinonal properties are allowed by default:
iex> Xema.is_valid? schema, %{a: 5, b: "hello", add: :prop}
true
```

### <a id="required_properties"></a> Required Properties

By default, the properties defined by the properties keyword are not required.
However, one can provide a list of `required` properties using the required
keyword.

```Elixir
iex> schema = Xema.new :map, properties: %{foo: :string}, required: [:foo]
%Xema{
  content: %Xema.Schema{
    type: :map,
    properties: %{
      foo: %Xema.Schema{type: :string}
    },
    required: MapSet.new([:foo])
  }
}
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
iex> schema = Xema.new :map,
...>   properties: %{foo: :string},
...>   required: [:foo],
...>   additional_properties: false
%Xema{
  content: %Xema.Schema{
    type: :map,
    properties: %{foo: %Xema.Schema{type: :string}},
    required: MapSet.new([:foo]),
    additional_properties: false
  }
}
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
iex> schema = Xema.new :map,
...>   properties: %{foo: :string},
...>   additional_properties: :integer
%Xema{
  content: %Xema.Schema{
    type: :map,
    properties: %{foo: %Xema.Schema{type: :string}},
    additional_properties: %Xema.Schema{type: :integer}
  }
}
iex> Xema.is_valid? schema, %{foo: "foo", add: 1}
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
iex> schema = Xema.new :map,
...> additional_properties: false,
...> pattern_properties: %{
...>   ~r/^s_/ => :string,
...>   ~r/^i_/ => :integer
...> }
%Xema{content: %Xema.Schema{
  type: :map,
  additional_properties: false,
  pattern_properties: %{
    ~r/^s_/ => %Xema.Schema{type: :string},
    ~r/^i_/ => %Xema.Schema{type: :integer}
  }
}}
iex> Xema.is_valid? schema, %{"s_0" => "foo", "i_1" => 6}
true
iex> Xema.is_valid? schema, %{s_0: "foo", i_1: 6}
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
iex> schema = Xema.new :map,
...>   min_properties: 2,
...>   max_properties: 3
%Xema{content: %Xema.Schema{
  type: :map,
  min_properties: 2,
  max_properties: 3
}}
iex> Xema.is_valid? schema, %{a: 1, b: 2}
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
iex> schema = Xema.new :map,
...>   properties: %{
...>     a: :number,
...>     b: :number,
...>     c: :number
...>   },
...>   dependencies: %{
...>     b: [:c]
...>   }
%Xema{content: %Xema.Schema{
  type: :map,
  properties: %{
    a: %Xema.Schema{type: :number},
    b: %Xema.Schema{type: :number},
    c: %Xema.Schema{type: :number}
  },
  dependencies: %{b: [:c]}
}}
iex> Xema.is_valid? schema, %{a: 5}
true
iex> Xema.is_valid? schema, %{c: 9}
true
iex> Xema.is_valid? schema, %{b: 1}
false
iex> Xema.is_valid? schema, %{b: 1, c: 7}
true
```

## <a id="multi"></a> Multiples Types

`JSON Schema Draft: 4/6/7`

It is also possible to check if a value matches one of the multiple types.

```Elixir
iex> schema = Xema.new [:string, nil], min_length: 1
%Xema{content: %Xema.Schema{
  type: [:string, nil], min_length: 1
}}
iex> Xema.is_valid? schema, "foo"
true
iex> Xema.is_valid? schema, nil
true
iex> Xema.is_valid? schema, ""
false
```

## <a id="allow"></a> Allow Additional Types

`JSON Schema Draft: -`

The keyword `allow` adds an extra type to the schema validation.

```Elixir
iex> schema = Xema.new :string, min_length: 1, allow: nil
%Xema{content: %Xema.Schema{
  type: [:string, nil], min_length: 1
}}
iex> Xema.is_valid? schema, "foo"
true
iex> Xema.is_valid? schema, nil
true
iex> Xema.is_valid? schema, ""
false
```

## <a id="enum"></a> Enumerations

The `enum` keyword is used to restrict a value to a fixed set of values. It must
be an array with at least one element, where each element is unique.

```Elixir
iex> schema = Xema.new :any, enum: [1, "foo", :bar]
%Xema{content: %Xema.Schema{enum: [1, "foo", :bar], type: :any}}
iex> Xema.is_valid? schema, :bar
true
iex> Xema.is_valid? schema, 42
false
```

## <a id="not"></a> Negate Schema

The keyword `not` negates a schema.

```Elixir
iex> schema = Xema.new :not, {:integer, minimum: 0}
%Xema{
  content: %Xema.Schema{
    type: :any,
    not: %Xema.Schema{type: :integer, minimum: 0}
  }
}
iex> Xema.is_valid? schema, 10
false
iex> Xema.is_valid? schema, -10
true
```

## <a id="combine"></a> Combine Schemas

The keywords `all_of`, `any_of`, and `one_of` combines schemas.

With `all_of` all schemas have to match.
```Elixir
iex> all = Xema.new :all_of, [
...>   {:integer, multiple_of: 2},
...>   {:integer, multiple_of: 3}
...> ]
%Xema{content: %Xema.Schema{
  type: :any, all_of: [
    %Xema.Schema{type: :integer, multiple_of: 2},
    %Xema.Schema{type: :integer, multiple_of: 3}
  ]
}}
iex> 0..9 |> Enum.map(&Xema.is_valid?(all, &1)) |> Enum.with_index()
[true: 0, false: 1, false: 2, false: 3, false: 4,
 false: 5, true: 6, false: 7, false: 8, false: 9]
```

With `any_of` any schema have to match.

```Elixir
iex> any = Xema.new :any_of, [
...>   {:integer, multiple_of: 2},
...>   {:integer, multiple_of: 3}
...> ]
%Xema{content: %Xema.Schema{
  type: :any, any_of: [
    %Xema.Schema{type: :integer, multiple_of: 2},
    %Xema.Schema{type: :integer, multiple_of: 3}
  ]
}}
iex> 0..9 |> Enum.map(&Xema.is_valid?(any, &1)) |> Enum.with_index()
[true: 0, false: 1, true: 2, true: 3, true: 4,
 false: 5, true: 6, false: 7, true: 8, true: 9]
```

With `one_of` exactly on schema have to match.

```Elixir
iex> one = Xema.new :one_of, [
...>   {:integer, multiple_of: 2},
...>   {:integer, multiple_of: 3}
...> ]
%Xema{content: %Xema.Schema{
  type: :any, one_of: [
    %Xema.Schema{type: :integer, multiple_of: 2},
    %Xema.Schema{type: :integer, multiple_of: 3}
  ]
}}
iex> 0..9 |> Enum.map(&Xema.is_valid?(one, &1)) |> Enum.with_index()
[false: 0, false: 1, true: 2, true: 3, true: 4,
 false: 5, false: 6, false: 7, true: 8, true: 9]
```

## <a id="structuring"></a> Structuring a schema

This section will present some options to structuring and reuse schemas.

### <a id="def-ref"></a> `definitions` and `ref`

To reuse a schema put it under the keyword `definitions`. Later on, the schema
can be referenced with the keyword `ref`.

```Elixir
iex> schema = Xema.new :map,
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
...>
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
iex> positive = Xema.new :integer, minimum: 1
...> negative = Xema.new :integer, maximum: -1
...> schema = Xema.new :map,
...>   properties: %{
...>     a: positive,
...>     b: positive,
...>     c: negative
...>   }
...>
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
iex> schema = Xema.new :map,
...>   id: "http://localhost:1234",
...>   properties: %{
...>     name: {:ref, "name.exon#/definitions/or_nil"},
...>     str: {:ref, "name.exon"}
...>   }
...>
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
      name: %{any_of: [%{type: nil}, %{type: :string}], value: 66}
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

  @spec get(binary) :: {:ok, map} | {:error, any}
  def get(uri) do
    with {:ok, response} <- get_response(uri), do: eval(response, uri)
  end

  defp get_response(uri) do
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
    error -> {:error, %{error | file: uri}}
  end
end
```

The function `get/1` will be called by `Xema` and expects a `binary`. In the
example in the section
"[Structuring schemas in multiple files](#multiple-files)" `get/1` gets the
`binary` `"http://localhost:1234/name.exon"`.

**Note!** This resolver use `Code.eval_string/1` and eval is always evil.

> **Warning:** string can be any Elixir code and will be executed with the same
> privileges as the Erlang VM: this means that such code could compromise the
> machine (for example by executing system commands). Don’t use `eval_string/3`
> with untrusted input (such as strings coming from the network).
> -- Elixir API
