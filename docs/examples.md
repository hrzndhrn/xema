# Examples

A bunch of `Xema` examples.

## Basic

A minimal example.

```elixir
iex> defmodule Example.Basic do
...>   use Xema
...>
...>   xema :person,
...>        map(
...>          properties: %{
...>            first_name: :string,
...>            last_name: :string,
...>            age: {:integer, minimum: 0}
...>          }
...>        )
...>
...>   @default true
...>   xema :foo, :string
...> end
...>
...> Example.Basic.valid?(
...>   :person,
...>   %{first_name: "James", last_name: "Brown", age: 42}
...> )
true
...> Example.Basic.valid?(
...>   :person,
...>   %{first_name: :james, last_name: "Brown", age: 42}
...> )
false
...> Example.Basic.validate(
...>   :person,
...>   %{first_name: :james, last_name: "Brown", age: 42}
...> )
{:error, %{properties: %{first_name: %{type: :string, value: :james}}}}
...> Example.Basic.valid?("foo")
true
...> Example.Basic.valid?(:foo)
false
```

## Options

An example to check opts.

```elixir
iex> defmodule Example.Options do
...>   use Xema
...>
...>   @default true
...>   xema :opts,
...>        keyword(
...>          properties: %{
...>            foo: atom(enum: [:bar, :baz]),
...>            limit: integer(minimum: 0),
...>            msg: :string
...>          },
...>          required: [:foo, :limit],
...>          additional_properties: false
...>        )
...> end
...>
...> Example.Options.validate(foo: :bar, limit: 11, msg: "foo")
:ok
...> Example.Options.validate(foo: :foo, limit: 11)
{:error, %{properties: %{foo: %{enum: [:bar, :baz], value: :foo}}}}
...> Example.Options.validate(foo: :bar)
{:error, %{required: [:limit]}}
...> Example.Options.validate(foo: :bar, limit: 11, message: "foo")
{:error, %{properties: %{message: %{additional_properties: false}}}}
```

## Custom validator

This example shows the use of an custom validator that is given as an tuple
of module and function name.

```elixir
iex> defmodule Example.Palindrome do
...>   def check(str) do
...>     case str == String.reverse(str) do
...>       true -> :ok
...>       false -> {:error, :no_palindrome}
...>     end
...>   end
...> end
...>
...> defmodule Example.Schema do
...>   use Xema
...>
...>   xema :palindrome,
...>        string(validator: {Example.Palindrome, :check})
...> end
...>
...> Example.Schema.valid?(:palindrome, "racecar")
true
...> Example.Schema.valid?(:palindrome, "bike")
false
...> Example.Schema.validate(:palindrome, "bike")
{:error, %{validator: :no_palindrome, value: "bike"}}
```

The custom validator can also be a part of the schema module.

```elixir
iex> defmodule Example.Range do
...>   use Xema
...>
...>   xema :range,
...>        map(
...>          properties: %{
...>            from: integer(minimum: 0),
...>            to: integer(maximum: 100)
...>          },
...>          validator: &Example.Range.check/1
...>        )
...>
...>   def check(%{from: from, to: to}) do
...>     case from < to do
...>       true -> :ok
...>       false -> {:error, :from_greater_to}
...>     end
...>   end
...> end
...>
...> Example.Range.validate(:range, %{from: 6, to: 8})
:ok
...> Example.Range.validate(:range, %{from: 66, to: 8})
{:error, %{validator: :from_greater_to, value: %{from: 66, to: 8}}}
...> Example.Range.validate(:range, %{from: 166, to: 118})
{:error, %{properties: %{to: %{maximum: 100, value: 118}}}}
```
