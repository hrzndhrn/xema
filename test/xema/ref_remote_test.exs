defmodule Xema.RefRemoteTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  test "http server" do
    assert %{body: body} =
             HTTPoison.get!("http://localhost:1234/folder/folderInteger.exon")

    assert body == File.read!("test/support/remote/folder/folderInteger.exon")
  end

  describe "invalid exon" do
    @tag :syntax
    test "compile error" do
      expected =
        "http://localhost:1234/compile-error.exon:3: " <>
          "undefined function invalid/0"

      assert_raise CompileError, expected, fn ->
        Xema.new(:ref, "http://localhost:1234/compile-error.exon")
      end
    end

    @tag :syntax
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
      assert Xema.validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert Xema.validate(schema, "1") ==
               {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "fragment within remote ref" do
    setup do
      %{
        schema:
          Xema.new(
            :ref,
            "http://localhost:1234/subSchemas.exon#/definitions/int"
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert Xema.validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert Xema.validate(schema, "1") ==
               {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "ref within remote ref" do
    setup do
      %{
        schema:
          Xema.new(
            :ref,
            "http://localhost:1234/subSchemas.exon#/definitions/refToInt"
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert Xema.validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert Xema.validate(schema, "1") ==
               {:error, %{type: :integer, value: "1"}}
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

    @tag :only
    test "schema", %{schema: schema} do
      IO.inspect(schema)
    end
  end
end
