# Changelog

## 0.6.0 - not released

+ Fixed and updated some specs.
+ Remote check for references is moved to the `behaviour`.
+ Key types in the schema are now matters for validation. See
  [Usage - Key types](https://hexdocs.pm/xema/usage.html#key_types)

## 0.5.0

+ The function `Xema.is_valid?/2` is deprecated. Use `Xema.valid?/2` instead.
+ Added keyword `const`.
+ Added keywords `if`, `then`, `else`.
+ Added handling for none-keyword data.
+ Added annotation keywords
  + `examples`
  + `comment`
  + `contentEncoding`
  + `contentMediaType`contentMediaType
+ Added new `format` checks.
+ Added validatiors for `atom`, `keyword`, `tuple` and `struct`
+ Added schema validator to validate data give to `Xema.new/1`.
+ `Xema.new/2` becomes `Xema.new/1`.
  Migrate to 0.5.0:
  ```Elixir
  # < 0.5.0
  Xema.new(:integer, minimum: 0)
  # >= 0.5.0
  Xema.new({:integer, minimum: 0})
  ```
+ Added Xema.validate!/2
