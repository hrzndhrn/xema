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
        Xema.new({:ref, "http://localhost:1234/compile-error.exon"})
      end
    end

    test "syntax error" do
      expected =
        "http://localhost:1234/syntax-error.exon:2: " <>
          "keyword argument must be followed by space after: a:"

      assert_raise SyntaxError, expected, fn ->
        Xema.new({:ref, "http://localhost:1234/syntax-error.exon"})
      end
    end
  end

  describe "invalid remote ref" do
    test "404" do
      expected =
        "Remote schema 'http://localhost:1234/not-found.exon' not found."

      assert_raise SchemaError, expected, fn ->
        Xema.new({:ref, "http://localhost:1234/not-found.exon"})
      end
    end
  end

  describe "remote ref" do
    setup do
      %{schema: Xema.new({:ref, "http://localhost:1234/integer.exon"})}
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "1") == {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "file ref" do
    setup do
      %{schema: Xema.new({:ref, "integer.exon"}, resolver: Test.FileResolver)}
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "1") == {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "fragment within remote ref" do
    setup do
      %{
        schema:
          Xema.new({
            :ref,
            "http://localhost:1234/sub_schemas.exon#/definitions/int"
          })
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "1") == {:error, %{type: :integer, value: "1"}}
    end
  end

  describe "invalid fragment in remote ref" do
    @tag :only
    test "Xema.new/1 raise error" do
      msg = "Ref #/definitions/invalid not found."

      assert_raise SchemaError, msg, fn ->
        Xema.new({
          :ref,
          "http://localhost:1234/sub_schemas.exon#/definitions/invalid"
        })
      end
    end
  end

  describe "ref within remote ref" do
    setup do
      %{
        schema:
          Xema.new({
            :ref,
            "http://localhost:1234/sub_schemas.exon#/definitions/refToInt"
          })
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
          Xema.new({
            :map,
            id: "http://localhost:1234/scope_change_defs1.exon",
            properties: %{
              list: {:ref, "#/definitions/baz"}
            },
            definitions: %{
              baz: {:list, id: "folder/", items: {:ref, "folderInteger.exon"}}
            }
          })
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, %{list: [1]}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, %{list: ["1"]}) ==
               {:error,
                %{
                  properties: %{
                    list: %{items: [{0, %{type: :integer, value: "1"}}]}
                  }
                }}
    end
  end

  describe "root ref in remote ref" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            id: "http://localhost:1234/object",
            properties: %{
              name: {:ref, "xema_name.exon#/definitions/or_nil"}
            }
          })
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
                    name: %{
                      any_of: [
                        %{type: nil, value: 1},
                        %{type: :string, value: 1}
                      ],
                      value: 1
                    }
                  }
                }}
    end
  end

  describe "root ref in remote ref (id without path)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            id: "http://localhost:1234",
            properties: %{
              name: {:ref, "xema_name.exon#/definitions/or_nil"}
            }
          })
      }
    end

    test "check schema", %{schema: schema} do
      assert schema.refs["http://localhost:1234/xema_name.exon"] == %Xema{
               refs: %{
                 "#/definitions/or_nil" => %Xema.Schema{
                   any_of: [
                     %Xema.Schema{type: nil},
                     %Xema.Schema{ref: %Xema.Ref{pointer: "#"}}
                   ]
                 }
               },
               schema: %Xema.Schema{
                 definitions: %{
                   or_nil: %Xema.Schema{
                     any_of: [
                       %Xema.Schema{type: nil},
                       %Xema.Schema{ref: %Xema.Ref{pointer: "#"}}
                     ]
                   }
                 },
                 type: :string
               }
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
                    name: %{
                      any_of: [
                        %{type: nil, value: 1},
                        %{type: :string, value: 1}
                      ],
                      value: 1
                    }
                  }
                }}
    end
  end

  describe "remote ref in remote ref" do
    setup do
      %{schema: Xema.new({:ref, "http://localhost:1234/obj_int.exon"})}
    end

    test "validate/2 with a valid value", %{schema: schema} do
      IO.inspect(schema)
      assert validate(schema, %{int: 1}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, %{int: "1"}) ==
               {:error, %{properties: %{int: %{type: :integer, value: "1"}}}}
    end
  end
end
