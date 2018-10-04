defmodule Draft6.RefTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "root pointer ref" do
    setup do
      %{
        schema:
          Xema.new(:any,
            additional_properties: false,
            properties: %{foo: {:ref, "#"}}
          )
      }
    end

    test "match", %{schema: schema} do
      data = %{foo: false}
      assert valid?(schema, data)
    end

    test "recursive match", %{schema: schema} do
      data = %{foo: %{foo: false}}
      assert valid?(schema, data)
    end

    test "mismatch", %{schema: schema} do
      data = %{bar: false}
      refute valid?(schema, data)
    end

    test "recursive mismatch", %{schema: schema} do
      data = %{foo: %{bar: false}}
      refute valid?(schema, data)
    end
  end

  describe "relative pointer ref to object" do
    setup do
      %{
        schema:
          Xema.new(:properties, %{
            bar: {:ref, "#/properties/foo"},
            foo: :integer
          })
      }
    end

    test "match", %{schema: schema} do
      data = %{bar: 3}
      assert valid?(schema, data)
    end

    test "mismatch", %{schema: schema} do
      data = %{bar: true}
      refute valid?(schema, data)
    end
  end

  describe "relative pointer ref to array" do
    setup do
      %{schema: Xema.new(:items, [:integer, {:ref, "#/items/0"}])}
    end

    test "match array", %{schema: schema} do
      data = [1, 2]
      assert valid?(schema, data)
    end

    test "mismatch array", %{schema: schema} do
      data = [1, "foo"]
      refute valid?(schema, data)
    end
  end

  describe "escaped pointer ref" do
    setup do
      %{
        schema:
          Xema.new(:any,
            properties: %{
              percent: {:ref, "#/percent%25field"},
              slash: {:ref, "#/slash~1field"},
              tilda: {:ref, "#/tilda~0field"}
            },
            "percent%field": :integer,
            "slash/field": :integer,
            "tilda~field": :integer
          )
      }
    end

    test "slash invalid", %{schema: schema} do
      data = %{slash: "aoeu"}
      refute valid?(schema, data)
    end

    test "tilda invalid", %{schema: schema} do
      data = %{tilda: "aoeu"}
      refute valid?(schema, data)
    end

    test "percent invalid", %{schema: schema} do
      data = %{percent: "aoeu"}
      refute valid?(schema, data)
    end

    test "slash valid", %{schema: schema} do
      data = %{slash: 123}
      assert valid?(schema, data)
    end

    test "tilda valid", %{schema: schema} do
      data = %{tilda: 123}
      assert valid?(schema, data)
    end

    test "percent valid", %{schema: schema} do
      data = %{percent: 123}
      assert valid?(schema, data)
    end
  end

  describe "nested refs" do
    setup do
      %{
        schema:
          Xema.new(:any,
            definitions: %{
              a: :integer,
              b: {:ref, "#/definitions/a"},
              c: {:ref, "#/definitions/b"}
            },
            ref: "#/definitions/c"
          )
      }
    end

    test "nested ref valid", %{schema: schema} do
      data = 5
      assert valid?(schema, data)
    end

    test "nested ref invalid", %{schema: schema} do
      data = "a"
      refute valid?(schema, data)
    end
  end

  describe "property named $ref that is not a reference" do
    setup do
      %{schema: Xema.new(:properties, %{"$ref": :string})}
    end

    test "property named $ref valid", %{schema: schema} do
      data = %{"$ref": "a"}
      assert valid?(schema, data)
    end

    test "property named $ref invalid", %{schema: schema} do
      data = %{"$ref": 2}
      refute valid?(schema, data)
    end
  end

  describe "$ref to boolean schema true" do
    setup do
      %{
        schema:
          Xema.new(:any, definitions: %{bool: true}, ref: "#/definitions/bool")
      }
    end

    test "any value is valid", %{schema: schema} do
      data = "foo"
      assert valid?(schema, data)
    end
  end

  describe "$ref to boolean schema false" do
    setup do
      %{
        schema:
          Xema.new(:any, definitions: %{bool: false}, ref: "#/definitions/bool")
      }
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end

  describe "Recursive references between schemas" do
    setup do
      %{
        schema:
          Xema.new(:map,
            definitions: %{
              node:
                {:map,
                 [
                   description: "node",
                   id: "http://localhost:1234/node",
                   properties: %{subtree: {:ref, "tree"}, value: :number},
                   required: ["value"]
                 ]}
            },
            description: "tree of nodes",
            id: "http://localhost:1234/tree",
            properties: %{
              meta: :string,
              nodes: {:list, [items: {:ref, "node"}]}
            },
            required: ["meta", "nodes"]
          )
      }
    end

    test "valid tree", %{schema: schema} do
      data = %{
        meta: "root",
        nodes: [
          %{
            subtree: %{meta: "child", nodes: [%{value: 1.1}, %{value: 1.2}]},
            value: 1
          },
          %{
            subtree: %{meta: "child", nodes: [%{value: 2.1}, %{value: 2.2}]},
            value: 2
          }
        ]
      }

      assert valid?(schema, data)
    end

    test "invalid tree", %{schema: schema} do
      data = %{
        meta: "root",
        nodes: [
          %{
            subtree: %{
              meta: "child",
              nodes: [%{value: "string is invalid"}, %{value: 1.2}]
            },
            value: 1
          },
          %{
            subtree: %{meta: "child", nodes: [%{value: 2.1}, %{value: 2.2}]},
            value: 2
          }
        ]
      }

      refute valid?(schema, data)
    end
  end
end
