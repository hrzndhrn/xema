locals_without_parens = [
  xema: 2
]

[
  inputs: ["mix.exs", "{config,lib,test,bench}/**/*.{ex,exs}"],
  line_length: 80,
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
