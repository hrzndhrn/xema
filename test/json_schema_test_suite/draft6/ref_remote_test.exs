defmodule JsonSchemaTestSuite.Draft6.RefRemoteTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|remote ref| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://localhost:1234/integer.json"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|remote ref valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|remote ref invalid|, %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe ~s|fragment within remote ref| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://localhost:1234/subSchemas.json#/integer"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|remote fragment valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|remote fragment invalid|, %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe ~s|ref within remote ref| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://localhost:1234/subSchemas.json#/refToInteger"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|ref within ref valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|ref within ref invalid|, %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe ~s|base URI change| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "$id" => "http://localhost:1234/",
              "items" => %{
                "$id" => "baseUriChange/",
                "items" => %{"$ref" => "folderInteger.json"}
              }
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|base URI change ref valid|, %{schema: schema} do
      assert valid?(schema, [[1]])
    end

    test ~s|base URI change ref invalid|, %{schema: schema} do
      refute valid?(schema, [["a"]])
    end
  end

  describe ~s|base URI change - change folder| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "$id" => "http://localhost:1234/scope_change_defs1.json",
              "definitions" => %{
                "baz" => %{
                  "$id" => "baseUriChangeFolder/",
                  "items" => %{"$ref" => "folderInteger.json"},
                  "type" => "array"
                }
              },
              "properties" => %{"list" => %{"$ref" => "#/definitions/baz"}},
              "type" => "object"
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|number is valid|, %{schema: schema} do
      assert valid?(schema, %{"list" => [1]})
    end

    test ~s|string is invalid|, %{schema: schema} do
      refute valid?(schema, %{"list" => ["a"]})
    end
  end

  describe ~s|base URI change - change folder in subschema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "$id" => "http://localhost:1234/scope_change_defs2.json",
              "definitions" => %{
                "baz" => %{
                  "$id" => "baseUriChangeFolderInSubschema/",
                  "definitions" => %{
                    "bar" => %{"items" => %{"$ref" => "folderInteger.json"}, "type" => "array"}
                  }
                }
              },
              "properties" => %{"list" => %{"$ref" => "#/definitions/baz/definitions/bar"}},
              "type" => "object"
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|number is valid|, %{schema: schema} do
      assert valid?(schema, %{"list" => [1]})
    end

    test ~s|string is invalid|, %{schema: schema} do
      refute valid?(schema, %{"list" => ["a"]})
    end
  end

  describe ~s|root ref in remote ref| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "$id" => "http://localhost:1234/object",
              "properties" => %{"name" => %{"$ref" => "name.json#/definitions/orNull"}},
              "type" => "object"
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|string is valid|, %{schema: schema} do
      assert valid?(schema, %{"name" => "foo"})
    end

    test ~s|null is valid|, %{schema: schema} do
      assert valid?(schema, %{"name" => nil})
    end

    test ~s|object is invalid|, %{schema: schema} do
      refute valid?(schema, %{"name" => %{"name" => nil}})
    end
  end
end
