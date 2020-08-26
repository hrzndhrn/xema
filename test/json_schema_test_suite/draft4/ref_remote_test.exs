defmodule JsonSchemaTestSuite.Draft4.RefRemoteTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "remote ref" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://localhost:1234/integer.json"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test "remote ref valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "remote ref invalid", %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe "fragment within remote ref" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://localhost:1234/subSchemas.json#/integer"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test "remote fragment valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "remote fragment invalid", %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe "ref within remote ref" do
    setup do
      :refToInteger

      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://localhost:1234/subSchemas.json#/refToInteger"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test "ref within ref valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "ref within ref invalid", %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe "base URI change" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "id" => "http://localhost:1234/",
              "items" => %{"id" => "folder/", "items" => %{"$ref" => "folderInteger.json"}}
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test "base URI change ref valid", %{schema: schema} do
      assert valid?(schema, [[1]])
    end

    test "base URI change ref invalid", %{schema: schema} do
      refute valid?(schema, [["a"]])
    end
  end

  describe "base URI change - change folder" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "definitions" => %{
                "baz" => %{
                  "id" => "folder/",
                  "items" => %{"$ref" => "folderInteger.json"},
                  "type" => "array"
                }
              },
              "id" => "http://localhost:1234/scope_change_defs1.json",
              "properties" => %{"list" => %{"$ref" => "#/definitions/baz"}},
              "type" => "object"
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test "number is valid", %{schema: schema} do
      assert valid?(schema, %{"list" => [1]})
    end

    test "string is invalid", %{schema: schema} do
      refute valid?(schema, %{"list" => ["a"]})
    end
  end

  describe "base URI change - change folder in subschema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "definitions" => %{
                "baz" => %{
                  "definitions" => %{
                    "bar" => %{"items" => %{"$ref" => "folderInteger.json"}, "type" => "array"}
                  },
                  "id" => "folder/"
                }
              },
              "id" => "http://localhost:1234/scope_change_defs2.json",
              "properties" => %{"list" => %{"$ref" => "#/definitions/baz/definitions/bar"}},
              "type" => "object"
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test "number is valid", %{schema: schema} do
      assert valid?(schema, %{"list" => [1]})
    end

    test "string is invalid", %{schema: schema} do
      refute valid?(schema, %{"list" => ["a"]})
    end
  end

  describe "root ref in remote ref" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "id" => "http://localhost:1234/object",
              "properties" => %{"name" => %{"$ref" => "name.json#/definitions/orNull"}},
              "type" => "object"
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test "string is valid", %{schema: schema} do
      assert valid?(schema, %{"name" => "foo"})
    end

    test "null is valid", %{schema: schema} do
      assert valid?(schema, %{"name" => nil})
    end

    test "object is invalid", %{schema: schema} do
      refute valid?(schema, %{"name" => %{"name" => nil}})
    end
  end
end
