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
iex>
iex> Example.Basic.valid?(
...>   :person,
...>   %{first_name: "James", last_name: "Brown", age: 42}
...> )
true
...> Example.Basic.valid?(
...>   :person,
...>   %{first_name: :james, last_name: "Brown", age: 42}
...> )
false
iex> Example.Basic.validate(
...>   :person,
...>   %{first_name: :james, last_name: "Brown", age: 42}
...> )
{:error, %Xema.ValidationError{
  message: "Expected :string, got :james, at [:first_name].",
  reason: %{properties: %{first_name: %{type: :string, value: :james}}}
}}
iex> Example.Basic.valid?("foo")
true
iex> Example.Basic.valid?(:foo)
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
iex>
iex> Example.Options.validate(foo: :bar, limit: 11, msg: "foo")
:ok
iex> Example.Options.validate(foo: :foo, limit: 11)
{:error, %Xema.ValidationError{
  message: "Value :foo is not defined in enum, at [:foo].",
  reason: %{properties: %{foo: %{enum: [:bar, :baz], value: :foo}}}
}}
iex> Example.Options.validate(foo: :bar)
{:error, %Xema.ValidationError{
  message: "Required properties are missing: [:limit].",
  reason: %{required: [:limit]}
}}
iex> Example.Options.validate(foo: :bar, limit: 11, message: "foo")
{:error, %Xema.ValidationError{
  message: "Expected only defined properties, got key [:message].",
  reason: %{properties: %{message: %{additional_properties: false}}}
}}
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
iex>
iex> defmodule Example.PaliSchema do
...>   use Xema
...>
...>   xema :palindrome,
...>        string(validator: {Example.Palindrome, :check})
...> end
...>
...> Example.PaliSchema.valid?(:palindrome, "racecar")
true
iex> Example.PaliSchema.valid?(:palindrome, "bike")
false
iex> Example.PaliSchema.validate(:palindrome, "bike")
{:error, %Xema.ValidationError{
  message: ~s|Validator fails with :no_palindrome for value "bike".|,
  reason: %{validator: :no_palindrome, value: "bike"}
}}
```

A validator can also be specified as behaviour.

```elixir
iex> defmodule Example.PalindromeB do
...>   @behaviour Xema.Validator
...>
...>   @impl true
...>   def validate(str) do
...>     case str == String.reverse(str) do
...>       true -> :ok
...>       false -> {:error, :no_palindrome}
...>     end
...>   end
...> end
iex>
iex> defmodule Example.PaliSchemaB do
...>   use Xema
...>
...>   xema :palindrome,
...>        string(validator: Example.PalindromeB)
...> end
...>
...> Example.PaliSchemaB.valid?(:palindrome, "racecar")
true
iex> Example.PaliSchemaB.valid?(:palindrome, "bike")
false
iex> Example.PaliSchemaB.validate(:palindrome, "bike")
{:error, %Xema.ValidationError{
  message: ~s|Validator fails with :no_palindrome for value "bike".|,
  reason: %{validator: :no_palindrome, value: "bike"}
}}
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
iex>
iex>   def check(%{from: from, to: to}) do
...>     case from < to do
...>       true -> :ok
...>       false -> {:error, :from_greater_to}
...>     end
...>   end
...> end
...>
...> Example.Range.validate(:range, %{from: 6, to: 8})
:ok
iex> Example.Range.validate(:range, %{from: 66, to: 8})
{:error, %Xema.ValidationError{
  message: "Validator fails with :from_greater_to for value %{from: 66, to: 8}.",
  reason: %{validator: :from_greater_to, value: %{from: 66, to: 8}}
}}
iex> Example.Range.validate(:range, %{from: 166, to: 118})
{:error, %Xema.ValidationError{
  message: "Value 118 exceeds maximum value of 100, at [:to].",
  reason: %{properties: %{to: %{maximum: 100, value: 118}}}
}}
```
