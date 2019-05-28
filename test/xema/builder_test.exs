defmodule Xema.BuilderTest do
  use ExUnit.Case, async: true

  doctest Xema.Builder

  import Xema.Builder

  describe "xema/2" do
    test "raise an error when Xema.Builder is just imported" do
      message = "Use `use Xema` to to use the `xema/2` macro."

      assert_raise RuntimeError, message, fn ->
        defmodule Foo do
          import Xema.Builder

          xema :foo, do: integer()
        end
      end
    end
  end

  describe "any function" do
    test "with a simple schema" do
      schema = Xema.new(any())

      assert schema == Xema.new(:any)
    end
  end

  describe "strux function" do
    test "with a simple schema" do
      schema = Xema.new(strux(URI, properties: %{fragment: :string}))

      raw = Xema.new({:struct, module: URI, properties: %{fragment: :string}})

      assert schema == raw
    end
  end

  describe "map function" do
    test "with a simple schema" do
      schema = Xema.new(map())

      assert schema == Xema.new(:map)
    end

    test "with a bigger schema" do
      builder =
        Xema.new(
          map(
            properties: %{
              num: integer(),
              name: string(min_length: 4)
            },
            additional_properties: false
          )
        )

      raw =
        Xema.new(
          {:map,
           [
             properties: %{
               name: {:string, [min_length: 4]},
               num: :integer
             },
             additional_properties: false
           ]}
        )

      assert builder == raw
    end
  end

  describe "ref function" do
    test "with a simple schema" do
      builder =
        Xema.new(
          any(
            properties: %{
              foo: ref("#/definitions/bar")
            },
            definitions: %{
              bar: ref("#/definitions/pos"),
              pos: integer(minimum: 0)
            }
          )
        )

      raw =
        Xema.new(
          properties: %{
            foo: {:ref, "#/definitions/bar"}
          },
          definitions: %{
            bar: {:ref, "#/definitions/pos"},
            pos: {:integer, minimum: 0}
          }
        )

      assert builder == raw
    end

    test "with a tree schema" do
      builder =
        Xema.new(
          map(
            id: "http://localhost:1234/tree",
            description: "tree of nodes",
            properties: %{
              meta: string(),
              nodes: list(items: ref("node"))
            },
            required: [:meta, :nodes],
            definitions: %{
              node:
                map(
                  id: "http://localhost:1234/node",
                  description: "node",
                  properties: %{
                    value: number(),
                    subtree: ref("tree")
                  },
                  required: [:value]
                )
            }
          )
        )

      raw =
        Xema.new({
          :map,
          id: "http://localhost:1234/tree",
          description: "tree of nodes",
          properties: %{
            meta: :string,
            nodes: {:list, items: {:ref, "node"}}
          },
          required: [:meta, :nodes],
          definitions: %{
            node:
              {:map,
               id: "http://localhost:1234/node",
               description: "node",
               properties: %{
                 value: :number,
                 subtree: {:ref, "tree"}
               },
               required: [:value]}
          }
        })

      assert builder == raw
    end
  end
end
