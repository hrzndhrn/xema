# Unsupported Features

## Keyword `default`

Xema don't support the keyword `default`.

## Unknown Properties

The following JSON-Schema is valid.

```JSON
{
  "int": {
    "type": "integer"
  },
  "properties": {
    "num": {
      "$ref": "#/int"
    }
  }
}
```

The equilant Xema schema will raise an error.

```Elixir
iex> Xema.new :any,
...>   int: :integer,
...>   properties: %{
...>     num: {:ref, "#/int"}
...>   }
** (Xema.SchemaError) :int is not a valid keyword.
```

The correct schema would be.

```Elixir
iex> schema = Xema.new :any,
...>   definitions: %{
...>     int: :integer,
...>   },
...>   properties: %{
...>     num: {:ref, "#/definitions/int"}
...>   }
...> Xema.is_valid? schema, %{num: 123}
true
```
