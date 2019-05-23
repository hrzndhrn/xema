# Cast

`Xema` provides the functions `Xema.cast/2` and `Xema.cast!/2` to convert data according to the
schema. The converted data will also be validated against the schema. The function `Xema.cast/2`
returns an error tuple with a `CastError` when the data cannot be converted.

```elixir
iex> schema = Xema.new({:integer, minimum: 1})
iex> Xema.cast(schema, "5")
{:ok, 5}
iex> Xema.cast(schema, "-5")
{:error, %Xema.ValidationError{
  reason: %{minimum: 1, value: -5}
}}
iex> {:error, error} = Xema.cast(schema, [])
{:error, %Xema.CastError{
  key: nil,
  path: [],
  to: :integer,
  value: []
}}
iex> Exception.message(error)
"cannot cast [] to :integer"
```

With `use Xema` the functions are also available.

```elixir
iex> defmodule Int do
...>   use Xema
...>
...>   xema :int, integer(minimum: 1)
...> end
iex>
iex> Int.cast("6")
{:ok, 6}
iex> Int.cast("-1")
{:error, %Xema.ValidationError{
  reason: %{minimum: 1, value: -1}
}}
```

## Maps

To convert map keys the schema has to specify the `keys` keyword.

```elixir
iex> defmodule MapSchema do
...>   use Xema
...>
...>   xema :schema,
...>        map(
...>          keys: :atoms,
...>          properties: %{
...>            pos: integer(minimum: 0),
...>            neg: integer(maximum: 0)
...>          }
...>        )
...> end
iex>
iex> MapSchema.cast(%{"pos" => "5", "neg" => "-5"})
{:ok, %{pos: 5, neg: -5}}
```

## Caster

To convert "special" structs a caster can be specified. A caster function has to return the
converted value in a tuple `{:ok, value}` or an `:error`.

```elixir
iex> defmodule UrisSchema do
...>   use Xema
...>
...>   def caster(string) when is_binary(string), do: {:ok, URI.parse(string)}
...>
...>   def caster(%URI{} = uri), do: {:ok, uri}
...>
...>   def caster(_), do: :error
...>
...>   xema :uris,
...>        map(
...>          keys: :atoms,
...>          properties: %{
...>            uris: list(
...>              items: strux(URI, caster: &UrisSchema.caster/1)
...>            )
...>          }
...>        )
...> end
iex> UrisSchema.cast(%{uris: ["https://hexdocs.pm/elixir/Kernel.html"]})
{:ok, %{uris: [URI.parse("https://hexdocs.pm/elixir/Kernel.html")]}}
```

The caster can also be a tuple of module and function name or an mfa tuple.

Using `Caster` behaviour is also supported.

```elixir
iex> defmodule UriCaster do
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
iex> defmodule UriSchema do
...>   use Xema
...>
...>   xema :uri,
...>        map(
...>          keys: :strings,
...>          properties: %{
...>            "uri" => strux(URI, caster: UriCaster)
...>          }
...>        )
...> end
iex>
iex> UriSchema.cast(%{uri: "https://elixir-lang.org/docs.html"})
{:ok, %{"uri" => URI.parse("https://elixir-lang.org/docs.html")}}
```
