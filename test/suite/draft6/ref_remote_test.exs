defmodule Draft6.RefRemoteTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "remote ref" do
    setup do
      %{schema: Xema.new(:ref, "http://localhost:1234/integer.exon")}
    end

    test "remote ref valid", %{schema: schema} do
      data = 1
      assert valid?(schema, data)
    end

    test "remote ref invalid", %{schema: schema} do
      data = "a"
      refute valid?(schema, data)
    end
  end

  describe "ref within remote ref" do
    setup do
      %{
        schema:
          Xema.new(:ref, "http://localhost:1234/subSchemas.exon#/refToInteger")
      }
    end

    test "ref within ref valid", %{schema: schema} do
      data = 1
      assert valid?(schema, data)
    end

    test "ref within ref invalid", %{schema: schema} do
      data = "a"
      refute valid?(schema, data)
    end
  end

  describe "base URI change" do
    setup do
      %{
        schema:
          Xema.new(:any,
            id: "http://localhost:1234/",
            items: {:any, [id: "folder/", items: {:ref, "folderInteger.exon"}]}
          )
      }
    end

    test "base URI change ref valid", %{schema: schema} do
      data = [[1]]
      assert valid?(schema, data)
    end

    test "base URI change ref invalid", %{schema: schema} do
      data = [["a"]]
      refute valid?(schema, data)
    end
  end

  describe "base URI change - change folder" do
    setup do
      %{
        schema:
          Xema.new(:map,
            definitions: %{
              baz: {:list, [id: "folder/", items: {:ref, "folderInteger.exon"}]}
            },
            id: "http://localhost:1234/scope_change_defs1.exon",
            properties: %{list: {:ref, "#/definitions/baz"}}
          )
      }
    end

    test "number is valid", %{schema: schema} do
      data = %{list: [1]}
      assert valid?(schema, data)
    end

    test "string is invalid", %{schema: schema} do
      data = %{list: ["a"]}
      refute valid?(schema, data)
    end
  end

  describe "base URI change - change folder in subschema" do
    setup do
      %{
        schema:
          Xema.new(:map,
            definitions: %{
              baz:
                {:any,
                 [
                   definitions: %{
                     bar: {:list, [items: {:ref, "folderInteger.exon"}]}
                   },
                   id: "folder/"
                 ]}
            },
            id: "http://localhost:1234/scope_change_defs2.exon",
            properties: %{list: {:ref, "#/definitions/baz/definitions/bar"}}
          )
      }
    end

    test "number is valid", %{schema: schema} do
      data = %{list: [1]}
      assert valid?(schema, data)
    end

    test "string is invalid", %{schema: schema} do
      data = %{list: ["a"]}
      refute valid?(schema, data)
    end
  end

  describe "root ref in remote ref" do
    setup do
      %{
        schema:
          Xema.new(:map,
            id: "http://localhost:1234/object",
            properties: %{name: {:ref, "name.exon#/definitions/orNull"}}
          )
      }
    end

    test "string is valid", %{schema: schema} do
      data = %{name: "foo"}
      assert valid?(schema, data)
    end

    test "null is valid", %{schema: schema} do
      data = %{name: nil}
      assert valid?(schema, data)
    end

    test "object is invalid", %{schema: schema} do
      data = %{name: %{name: nil}}
      refute valid?(schema, data)
    end
  end
end
