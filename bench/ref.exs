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

    IO.puts("===")
    IO.inspect(schema, limit: :infinity)

    fn -> true = Xema.valid?(schema, data) end
  end

  def run do
    Benchee.run(
      %{"ref" => fun()},
      parallel: 4,
      print: [fast_warning: false],
      load: "bench/tmp/ref.benchee",
      formatters: [
        # &Benchee.Formatters.HTML.output/1,
        &Benchee.Formatters.Console.output/1
      ],
      formatter_options: [
        html: [
          file: Path.expand("output/bench.html", __DIR__)
        ]
      ]
    )
  end
end

Bench.run()
