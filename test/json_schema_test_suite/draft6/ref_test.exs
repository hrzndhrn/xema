defmodule JsonSchemaTestSuite.Draft6.Ref do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "root pointer ref" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "additionalProperties" => false,
            "properties" => %{"foo" => %{"$ref" => "#"}}
          })
      }
    end

    test "match", %{schema: schema} do
      assert valid?(schema, %{"foo" => false})
    end

    test "recursive match", %{schema: schema} do
      assert valid?(schema, %{"foo" => %{"foo" => false}})
    end

    test "mismatch", %{schema: schema} do
      refute valid?(schema, %{"bar" => false})
    end

    test "recursive mismatch", %{schema: schema} do
      refute valid?(schema, %{"foo" => %{"bar" => false}})
    end
  end

  describe "relative pointer ref to object" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "properties" => %{
              "bar" => %{"$ref" => "#/properties/foo"},
              "foo" => %{"type" => "integer"}
            }
          })
      }
    end

    test "match", %{schema: schema} do
      assert valid?(schema, %{"bar" => 3})
    end

    test "mismatch", %{schema: schema} do
      refute valid?(schema, %{"bar" => true})
    end
  end

  describe "relative pointer ref to array" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{"items" => [%{"type" => "integer"}, %{"$ref" => "#/items/0"}]})
      }
    end

    test "match array", %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test "mismatch array", %{schema: schema} do
      refute valid?(schema, [1, "foo"])
    end
  end

  describe "escaped pointer ref" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "percent%field" => %{"type" => "integer"},
            "properties" => %{
              "percent" => %{"$ref" => "#/percent%25field"},
              "slash" => %{"$ref" => "#/slash~1field"},
              "tilda" => %{"$ref" => "#/tilda~0field"}
            },
            "slash/field" => %{"type" => "integer"},
            "tilda~field" => %{"type" => "integer"}
          })
      }
    end

    test "slash invalid", %{schema: schema} do
      refute valid?(schema, %{"slash" => "aoeu"})
    end

    test "tilda invalid", %{schema: schema} do
      refute valid?(schema, %{"tilda" => "aoeu"})
    end

    test "percent invalid", %{schema: schema} do
      refute valid?(schema, %{"percent" => "aoeu"})
    end

    test "slash valid", %{schema: schema} do
      assert valid?(schema, %{"slash" => 123})
    end

    test "tilda valid", %{schema: schema} do
      assert valid?(schema, %{"tilda" => 123})
    end

    test "percent valid", %{schema: schema} do
      assert valid?(schema, %{"percent" => 123})
    end
  end

  describe "nested refs" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "$ref" => "#/definitions/c",
            "definitions" => %{
              "a" => %{"type" => "integer"},
              "b" => %{"$ref" => "#/definitions/a"},
              "c" => %{"$ref" => "#/definitions/b"}
            }
          })
      }
    end

    test "nested ref valid", %{schema: schema} do
      assert valid?(schema, 5)
    end

    test "nested ref invalid", %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe "ref overrides any sibling keywords" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "definitions" => %{"reffed" => %{"type" => "array"}},
            "properties" => %{"foo" => %{"$ref" => "#/definitions/reffed", "maxItems" => 2}}
          })
      }
    end

    test "ref valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => []})
    end

    test "ref valid, maxItems ignored", %{schema: schema} do
      assert valid?(schema, %{"foo" => [1, 2, 3]})
    end

    test "ref invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => "string"})
    end
  end

  describe "remote ref, containing refs itself" do
    setup do
      %{schema: Xema.from_json_schema(%{"$ref" => "http://json-schema.org/draft-06/schema#"})}
    end

    test "remote ref valid", %{schema: schema} do
      assert valid?(schema, %{"minLength" => 1})
    end

    test "remote ref invalid", %{schema: schema} do
      refute valid?(schema, %{"minLength" => -1})
    end
  end

  describe "property named $ref that is not a reference" do
    setup do
      %{schema: Xema.from_json_schema(%{"properties" => %{"$ref" => %{"type" => "string"}}})}
    end

    test "property named $ref valid", %{schema: schema} do
      assert valid?(schema, %{"$ref" => "a"})
    end

    test "property named $ref invalid", %{schema: schema} do
      refute valid?(schema, %{"$ref" => 2})
    end
  end

  describe "$ref to boolean schema true" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "$ref" => "#/definitions/bool",
            "definitions" => %{"bool" => true}
          })
      }
    end

    test "any value is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end

  describe "$ref to boolean schema false" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "$ref" => "#/definitions/bool",
            "definitions" => %{"bool" => false}
          })
      }
    end

    test "any value is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "Recursive references between schemas" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "$id" => "http://localhost:1234/tree",
            "definitions" => %{
              "node" => %{
                "$id" => "http://localhost:1234/node",
                "description" => "node",
                "properties" => %{
                  "subtree" => %{"$ref" => "tree"},
                  "value" => %{"type" => "number"}
                },
                "required" => ["value"],
                "type" => "object"
              }
            },
            "description" => "tree of nodes",
            "properties" => %{
              "meta" => %{"type" => "string"},
              "nodes" => %{"items" => %{"$ref" => "node"}, "type" => "array"}
            },
            "required" => ["meta", "nodes"],
            "type" => "object"
          })
      }
    end

    test "valid tree", %{schema: schema} do
      assert valid?(schema, %{
               "meta" => "root",
               "nodes" => [
                 %{
                   "subtree" => %{
                     "meta" => "child",
                     "nodes" => [%{"value" => 1.1}, %{"value" => 1.2}]
                   },
                   "value" => 1
                 },
                 %{
                   "subtree" => %{
                     "meta" => "child",
                     "nodes" => [%{"value" => 2.1}, %{"value" => 2.2}]
                   },
                   "value" => 2
                 }
               ]
             })
    end

    test "invalid tree", %{schema: schema} do
      refute valid?(schema, %{
               "meta" => "root",
               "nodes" => [
                 %{
                   "subtree" => %{
                     "meta" => "child",
                     "nodes" => [%{"value" => "string is invalid"}, %{"value" => 1.2}]
                   },
                   "value" => 1
                 },
                 %{
                   "subtree" => %{
                     "meta" => "child",
                     "nodes" => [%{"value" => 2.1}, %{"value" => 2.2}]
                   },
                   "value" => 2
                 }
               ]
             })
    end
  end

  describe "refs with quote" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "definitions" => %{"foo\"bar" => %{"type" => "number"}},
            "properties" => %{"foo\"bar" => %{"$ref" => "#/definitions/foo%22bar"}}
          })
      }
    end

    test "object with numbers is valid", %{schema: schema} do
      assert valid?(schema, %{"foo\"bar" => 1})
    end

    test "object with strings is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo\"bar" => "1"})
    end
  end

  describe "Location-independent identifier" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "allOf" => [%{"$ref" => "#foo"}],
            "definitions" => %{"A" => %{"$id" => "#foo", "type" => "integer"}}
          })
      }
    end

    test "match", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "mismatch", %{schema: schema} do
      refute valid?(schema, "a")
    end
  end
end
