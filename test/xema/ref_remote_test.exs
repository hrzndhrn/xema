defmodule Xema.RefRemoteTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.SchemaError

  test "http server" do
    assert %{body: body} =
             HTTPoison.get!("http://localhost:1234/folder/folderInteger.exon")

    assert body == File.read!("test/support/remote/folder/folderInteger.exon")
  end

  describe "invalid exon" do
    test "compile error" do
      expected =
        "http://localhost:1234/compile-error.exon:3: " <>
          "undefined function invalid/0"

      assert_raise CompileError, expected, fn ->
        Xema.new(:ref, "http://localhost:1234/compile-error.exon")
      end
    end

    test "syntax error" do
      expected =
        "http://localhost:1234/syntax-error.exon:2: " <>
          "keyword argument must be followed by space after: a:"

      assert_raise SyntaxError, expected, fn ->
        Xema.new(:ref, "http://localhost:1234/syntax-error.exon")
      end
    end
  end

  describe "invalid remote ref" do
    test "404" do
      expected =
        "Remote schema 'http://localhost:1234/not-found.exon' not found."

      assert_raise SchemaError, expected, fn ->
        Xema.new(:ref, "http://localhost:1234/not-found.exon")
      end
    end
  end

  describe "remote ref" do
    setup do
      %{schema: Xema.new(:ref, "http://localhost:1234/integer.exon")}
    end

    test "validate/2 with a valid value", %{schema: schema} do
      # IO.inspect schema, limit: :infinity
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "1") == {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "schema with invalid ref" do
    setup do
      schema =
        :ref
        |> Xema.new("http://localhost:1234/integer.exon")
        |> Map.put(:ids, nil)

      %{schema: schema}
    end

    test "validate/2 with a valid value", %{schema: schema} do
      expected = "Reference 'http://localhost:1234/integer.exon' not found."

      assert_raise SchemaError, expected, fn ->
        validate(schema, 1)
      end
    end
  end

  describe "fragment within remote ref" do
    setup do
      %{
        schema:
          Xema.new(
            :ref,
            "http://localhost:1234/sub_schemas.exon#/definitions/int"
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "1") == {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "ref within remote ref" do
    setup do
      %{
        schema:
          Xema.new(
            :ref,
            "http://localhost:1234/sub_schemas.exon#/definitions/refToInt"
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "1") == {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "base URI change - change folder" do
    setup do
      %{
        schema:
          Xema.new(
            :map,
            id: "http://localhost:1234/scope_change_defs1.exon",
            properties: %{
              list: {:ref, "#/definitions/baz"}
            },
            definitions: %{
              baz: {:list, id: "folder/", items: {:ref, "folderInteger.exon"}}
            }
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, %{list: [1]}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, %{list: ["1"]}) ==
               {:error,
                %{properties: %{list: [{0, %{type: :integer, value: "1"}}]}}}
    end
  end

  describe "root ref in remote ref" do
    setup do
      %{
        schema:
          Xema.new(
            :map,
            id: "http://localhost:1234/object",
            properties: %{
              name: {:ref, "xema_name.exon#/definitions/or_nil"}
            }
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, %{name: "foo"}) == :ok
      assert validate(schema, %{name: nil}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, %{name: 1}) ==
               {:error,
                %{
                  properties: %{
                    name: %{any_of: [%{type: nil}, %{type: :string}], value: 1}
                  }
                }}
    end
  end

  describe "root ref in remote ref (id without path)" do
    setup do
      %{
        schema:
          Xema.new(
            :map,
            id: "http://localhost:1234",
            properties: %{
              name: {:ref, "xema_name.exon#/definitions/or_nil"}
            }
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, %{name: "foo"}) == :ok
      assert validate(schema, %{name: nil}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, %{name: 1}) ==
               {:error,
                %{
                  properties: %{
                    name: %{any_of: [%{type: nil}, %{type: :string}], value: 1}
                  }
                }}
    end
  end
end
