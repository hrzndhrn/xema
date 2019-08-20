# Examples

A bunch of `Xema` examples.

## Basic

A minimal example.

```elixir
iex> defmodule Example.Basic do
...>   use Xema, multi: true
...>
...>   xema :person do
...>     map(
...>       properties: %{
...>         first_name: :string,
...>         last_name: :string,
...>         age: {:integer, minimum: 0}
...>       }
...>     )
...>   end
...>
...>   @default true
...>   xema :foo, do: :string
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
iex> {:error, error} = Example.Basic.validate(
...>   :person,
...>   %{first_name: :james, last_name: "Brown", age: 42}
...> )
{:error, %Xema.ValidationError{
  reason: %{properties: %{first_name: %{type: :string, value: :james}}}
}}
iex> Exception.message(error)
"Expected :string, got :james, at [:first_name]."
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
...>   xema do
...>     keyword(
...>       properties: %{
...>         foo: atom(enum: [:bar, :baz]),
...>         limit: integer(minimum: 0),
...>         msg: :string
...>       },
...>       required: [:foo, :limit],
...>       additional_properties: false
...>     )
...>   end
...> end
iex>
iex> Example.Options.validate(foo: :bar, limit: 11, msg: "foo")
:ok
iex> {:error, error} = Example.Options.validate(foo: :foo, limit: 11)
{:error, %Xema.ValidationError{
  reason: %{properties: %{foo: %{enum: [:bar, :baz], value: :foo}}}
}}
iex> Exception.message(error)
"Value :foo is not defined in enum, at [:foo]."
iex> {:error, error} = Example.Options.validate(foo: :bar)
{:error, %Xema.ValidationError{
  reason: %{required: [:limit]}
}}
iex> Exception.message(error)
"Required properties are missing: [:limit]."
iex> {:error, error} = Example.Options.validate(foo: :bar, limit: 11, message: "foo")
{:error, %Xema.ValidationError{
  reason: %{properties: %{message: %{additional_properties: false}}}
}}
iex> Exception.message(error)
"Expected only defined properties, got key [:message]."
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
...>   xema :palindrome do
...>     string(validator: {Example.Palindrome, :check})
...>   end
...> end
...>
...> Example.PaliSchema.valid?(:palindrome, "racecar")
true
iex> Example.PaliSchema.valid?(:palindrome, "bike")
false
iex> {:error, error} = Example.PaliSchema.validate(:palindrome, "bike")
{:error, %Xema.ValidationError{
  reason: %{validator: :no_palindrome, value: "bike"}
}}
iex> Exception.message(error)
~s|Validator fails with :no_palindrome for value "bike".|
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
...>   xema :palindrome do
...>     string(validator: Example.PalindromeB)
...>   end
...> end
...>
...> Example.PaliSchemaB.valid?(:palindrome, "racecar")
true
iex> Example.PaliSchemaB.valid?(:palindrome, "bike")
false
iex> {:error, error} = Example.PaliSchemaB.validate(:palindrome, "bike")
{:error, %Xema.ValidationError{
  reason: %{validator: :no_palindrome, value: "bike"}
}}
iex> Exception.message(error)
~s|Validator fails with :no_palindrome for value "bike".|
```

The custom validator can also be a part of the schema module.

```elixir
iex> defmodule Example.Range do
...>   use Xema
...>
...>   xema :range do
...>     map(
...>       properties: %{
...>         from: integer(minimum: 0),
...>         to: integer(maximum: 100)
...>       },
...>       validator: &Example.Range.check/1
...>     )
...>   end
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
iex> {:error, error} = Example.Range.validate(:range, %{from: 66, to: 8})
{:error, %Xema.ValidationError{
  reason: %{validator: :from_greater_to, value: %{from: 66, to: 8}}
}}
iex> Exception.message(error)
"Validator fails with :from_greater_to for value %{from: 66, to: 8}."
iex> {:error, error} = Example.Range.validate(:range, %{from: 166, to: 118})
{:error, %Xema.ValidationError{
  reason: %{properties: %{to: %{maximum: 100, value: 118}}}
}}
iex> Exception.message(error)
"Value 118 exceeds maximum value of 100, at [:to]."
```

## Cast JSON

The following example cast data structure that is decoded by `Jason.decode!/1`.
For the encoding of `URI` a `Jason.Encoder` implementation is needed.

```elixir
defimpl Jason.Encoder, for: URI do
  def encode(uri, _opts) do
    ~s|"#{URI.to_string(uri)}"|
  end
end
```

This example shows how a complex data structure decoded by a JSON parser can be
converted in a form described by a schema.

```elixir
iex> defmodule CasterUri do
...>   @behaviour Xema.Caster
...>
...>   @impl true
...>   def cast(%URI{} = uri), do: {:ok, uri}
...>
...>   def cast(string) when is_binary(string), do: {:ok, URI.parse(string)}
...>
...>   def cast(_), do: :error
...> end
iex>
iex> defmodule UserSchema do
...>   use Xema
...>
...>   xema :user do
...>     map(
...>       keys: :atoms,
...>       properties: %{
...>         name: :string,
...>         birthday: strux(Date),
...>         favorites:
...>           map(
...>             keys: :atoms,
...>             properties: %{
...>               fruits: list(items: atom(enum: [:apple, :orange, :banana])),
...>               uris: list(items: strux(URI, caster: CasterUri))
...>             }
...>           )
...>       },
...>       additional_properties: false
...>     )
...>   end
...> end
iex>
iex> {:ok, json} =
...>   %{
...>     "name" => "Nick",
...>     "birthday" => ~D|2000-04-17|,
...>     "favorites" => %{
...>       "fruits" => ~w(apple banana),
...>       "uris" => ["https://elixir-lang.org/"]
...>     }
...>   }
...>   |> UserSchema.cast!()
...>   |> Jason.encode()
{:ok, "{\"birthday\":\"2000-04-17\",\"favorites\":{\"fruits\":[\"apple\",\"banana\"],\"uris\":[\"https://elixir-lang.org/\"]},\"name\":\"Nick\"}"}
iex>
iex> json |> Jason.decode!() |> UserSchema.cast!()
%{
  birthday: ~D[2000-04-17],
  favorites: %{
    fruits: [:apple, :banana],
    uris: [
      %URI{
        authority: "elixir-lang.org",
        fragment: nil,
        host: "elixir-lang.org",
        path: "/",
        port: 443,
        query: nil,
        scheme: "https",
        userinfo: nil
      }
    ]
  },
  name: "Nick"
}
```

## Struct

TODO: example

```elixir
```
