defmodule Bench do
  def fun do
    schema =
      Xema.new(
        {:map,
         definitions: %{
           neg: {:integer, maximum: 0},
           pos: {:integer, minimum: 0}
         },
         properties: %{
           neg: {:ref, "#/definitions/neg"},
           pos: {:ref, "#/definitions/pos"}
         }}
      )

    data = %{neg: -5, pos: 6}

    fn -> true = Xema.valid?(schema, data) end
  end

  def run do
    Benchee.run(
      %{"ref" => fun()},
      parallel: 4,
      save: [path: "bench/tmp/ref.benchee", tag: "master"],
      print: [fast_warning: false],
      # load: "bench/tmp/ref.benchee",
      formatters: [
        Benchee.Formatters.Console
      ]
    )
  end
end

Bench.run()
