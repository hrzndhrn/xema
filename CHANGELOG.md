# Changelog

## 0.9.0 dev

+ Add option `multi` to use multiple schema modules: `use Xeam, multi: true`.

## 0.8.0 2019/03/10

+ Inline references in schemas by default. Increased performance of reference
  handling by 30%.
+ Rename `defxema` to `xema` and refactor macros.
+ Add custom `validator`.
+ Add examples page.
+ Add `@default true`.

## 0.7.0 2019/02/10

+ Increase `ref` performance.
+ Fix option `:resolver` in `Xema.new/2`.
+ Refactor `ref` handling,
+ Rename `resolver` to `loader`.
+ Remove deprecated function `Xema.is_valid/2`.
+ Reduce public API docs.
+ Add `Xema.Builder` and `use Xema`.

## 0.6.3 2019/01/15

+ Ignore unknown formatters.

## 0.6.2 2019/01/13

+ Change regex for email validation (~7x faster).
+ Add `:resolver` option to `Xema.new`.
+ Speed up string validator.

## 0.6.1 2019/01/06

Update docs.

## 0.6.0 2018/12/29

+ Fixed and updated some specs.
+ Remote check for references is moved to the `behaviour`.
+ Key types in the schema are now matters for validation. See
  [Usage - Key types](https://hexdocs.pm/xema/usage.html#key_types)

## 0.5.0 2018/12/25

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
  ```elixir
  # < 0.5.0
  Xema.new(:integer, minimum: 0)
  # >= 0.5.0
  Xema.new({:integer, minimum: 0})
  ```
+ Add Xema.validate!/2
