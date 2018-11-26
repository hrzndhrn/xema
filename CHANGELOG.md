# Changelog

## 0.5.1 - not released

+ Fixed and updated some specs.
+ Remote check for references is moved to the `behaviour`.

## 0.5.0

+ The function `Xema.is_valid?/2` is deprecated. Use `Xema.valid?/2` instead.
+ Add keyword `const`.
+ Add keywords `if`, `then`, `else`.
+ Add handling for none-keyword data.
+ Add annotation keywords
  + `examples`
  + `comment`
  + `contentEncoding`
  + `contentMediaType`contentMediaType
+ Add new `format` checks.
+ Add validatiors for `atom`, `keyword`, `tuple` and `struct`
+ Add schema validator to validate data give to `Xema.new/1`.
+ `Xema.new/2` becomes `Xema.new/1`.
  Migrate to 0.5.0:
  ```Elixir
  # < 0.5.0
  Xema.new(:integer, minimum: 0)
  # >= 0.5.0
  Xema.new({:integer, minimum: 0})
  ```
+ Add Xema.validate!/2
