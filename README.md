# Xema
[![Hex.pm: version](https://img.shields.io/hexpm/v/xema.svg?style=flat-square)](https://hex.pm/packages/xema)
[![GitHub: CI status](https://img.shields.io/github/actions/workflow/status/hrzndhrn/xema/ci.yml?branch=main&style=flat-square)](https://github.com/hrzndhrn/xema/actions)
[![Coveralls: coverage](https://img.shields.io/coveralls/github/hrzndhrn/xema?style=flat-square)](https://coveralls.io/github/hrzndhrn/xema)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://github.com/hrzndhrn/xema/blob/main/LICENSE.md)

Xema is a schema validator inspired by [JSON Schema](http://json-schema.org).
For now, Xema supports the features documented in draft 04, 06, and 07 of the
JSON-Schema specification.

Xema allows you to annotate and validate Elixir data structures.

If you search for a real JSON Schema validator give
[JsonXema](https://github.com/hrzndhrn/json_xema) a try.

Xema is in beta. If you try it and has an issue, report them.

## Installation

First, add `:xema` to your `mix.exs` dependencies:

```elixir
def deps do
  [{:xema, "~> 0.14"}]
end
```

Then, update your dependencies:

```shell
$ mix deps.get
```

## Docs

The docs contains a [Usage](https://hexdocs.pm/xema/usage.html) page with a
short and compact description to use `Xema`.

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) by running `mix docs`. The
generated docs can be found at
[https://hexdocs.pm/xema](https://hexdocs.pm/xema).

## Tests

The test in the directory `xema/test/json_schema_test_suite` are generated from the
[JSON-Schema-Test-Suite](https://github.com/json-schema-org/JSON-Schema-Test-Suite).

The test suite can be generated with `mix gen.test_suite`. The mix task expected
the suite in the root directory in the folder `JSON-Schema-Test-Suite`.

## References

The home of JSON Schema: http://json-schema.org/

Specification:

* Draft-04
  * [JSON Schema core](http://json-schema.org/draft-04/json-schema-core.html)
defines the basic foundation of JSON Schema
  * [JSON Schema Validation](http://json-schema.org/draft-04/json-schema-validation.html)
defines the validation keywords of JSON Schema
* Draft-06
  * [JSON Schema core](http://json-schema.org/draft-06/json-schema-core.html)
  * [JSON Schema Validation](http://json-schema.org/draft-06/json-schema-validation.html)
  * [JSON Schema Release Notes](http://json-schema.org/draft-06/json-schema-release-notes.html)
contains informations to migrate schemas.
* Draft-07
  * [JSON Schema core](http://json-schema.org/draft-07/json-schema-core.html)
  * [JSON Schema Validation](http://json-schema.org/draft-07/json-schema-validation.html)
  * [JSON Schema Release Notes](http://json-schema.org/draft-07/json-schema-release-notes.html)


[Understanding JSON Schema](https://spacetelescope.github.io/understanding-json-schema/index.html)
a great tutorial for JSON Schema authors and a template for the description of
Xema.
