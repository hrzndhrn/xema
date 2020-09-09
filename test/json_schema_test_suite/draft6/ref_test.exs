defmodule JsonSchemaTestSuite.Draft6.RefTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|root pointer ref| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalProperties" => false, "properties" => %{"foo" => %{"$ref" => "#"}}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|match|, %{schema: schema} do
      assert valid?(schema, %{"foo" => false})
    end

    test ~s|recursive match|, %{schema: schema} do
      assert valid?(schema, %{"foo" => %{"foo" => false}})
    end

    test ~s|mismatch|, %{schema: schema} do
      refute valid?(schema, %{"bar" => false})
    end

    test ~s|recursive mismatch|, %{schema: schema} do
      refute valid?(schema, %{"foo" => %{"bar" => false}})
    end
  end

  describe ~s|relative pointer ref to object| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "properties" => %{
                "bar" => %{"$ref" => "#/properties/foo"},
                "foo" => %{"type" => "integer"}
              }
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|match|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 3})
    end

    test ~s|mismatch|, %{schema: schema} do
      refute valid?(schema, %{"bar" => true})
    end
  end

  describe ~s|relative pointer ref to array| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => [%{"type" => "integer"}, %{"$ref" => "#/items/0"}]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|match array|, %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test ~s|mismatch array|, %{schema: schema} do
      refute valid?(schema, [1, "foo"])
    end
  end

  describe ~s|escaped pointer ref| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "definitions" => %{
                "percent%field" => %{"type" => "integer"},
                "slash/field" => %{"type" => "integer"},
                "tilde~field" => %{"type" => "integer"}
              },
              "properties" => %{
                "percent" => %{"$ref" => "#/definitions/percent%25field"},
                "slash" => %{"$ref" => "#/definitions/slash~1field"},
                "tilde" => %{"$ref" => "#/definitions/tilde~0field"}
              }
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|slash invalid|, %{schema: schema} do
      refute valid?(schema, %{"slash" => "aoeu"})
    end

    test ~s|tilde invalid|, %{schema: schema} do
      refute valid?(schema, %{"tilde" => "aoeu"})
    end

    test ~s|percent invalid|, %{schema: schema} do
      refute valid?(schema, %{"percent" => "aoeu"})
    end

    test ~s|slash valid|, %{schema: schema} do
      assert valid?(schema, %{"slash" => 123})
    end

    test ~s|tilde valid|, %{schema: schema} do
      assert valid?(schema, %{"tilde" => 123})
    end

    test ~s|percent valid|, %{schema: schema} do
      assert valid?(schema, %{"percent" => 123})
    end
  end

  describe ~s|nested refs| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "$ref" => "#/definitions/c",
              "definitions" => %{
                "a" => %{"type" => "integer"},
                "b" => %{"$ref" => "#/definitions/a"},
                "c" => %{"$ref" => "#/definitions/b"}
              }
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|nested ref valid|, %{schema: schema} do
      assert valid?(schema, 5)
    end

    test ~s|nested ref invalid|, %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe ~s|ref overrides any sibling keywords| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "definitions" => %{"reffed" => %{"type" => "array"}},
              "properties" => %{"foo" => %{"$ref" => "#/definitions/reffed", "maxItems" => 2}}
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|ref valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => []})
    end

    test ~s|ref valid, maxItems ignored|, %{schema: schema} do
      assert valid?(schema, %{"foo" => [1, 2, 3]})
    end

    test ~s|ref invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "string"})
    end
  end

  describe ~s|remote ref, containing refs itself| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://json-schema.org/draft-06/schema#"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|remote ref valid|, %{schema: schema} do
      assert valid?(schema, %{"minLength" => 1})
    end

    test ~s|remote ref invalid|, %{schema: schema} do
      refute valid?(schema, %{"minLength" => -1})
    end
  end

  describe ~s|property named $ref that is not a reference| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"$ref" => %{"type" => "string"}}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|property named $ref valid|, %{schema: schema} do
      assert valid?(schema, %{"$ref" => "a"})
    end

    test ~s|property named $ref invalid|, %{schema: schema} do
      refute valid?(schema, %{"$ref" => 2})
    end
  end

  describe ~s|property named $ref, containing an actual $ref| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "definitions" => %{"is-string" => %{"type" => "string"}},
              "properties" => %{"$ref" => %{"$ref" => "#/definitions/is-string"}}
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|property named $ref valid|, %{schema: schema} do
      assert valid?(schema, %{"$ref" => "a"})
    end

    test ~s|property named $ref invalid|, %{schema: schema} do
      refute valid?(schema, %{"$ref" => 2})
    end
  end

  describe ~s|$ref to boolean schema true| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "#/definitions/bool", "definitions" => %{"bool" => true}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|any value is valid|, %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end

  describe ~s|$ref to boolean schema false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "#/definitions/bool", "definitions" => %{"bool" => false}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|any value is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe ~s|Recursive references between schemas| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
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
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|valid tree|, %{schema: schema} do
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

    test ~s|invalid tree|, %{schema: schema} do
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

  describe ~s|refs with quote| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "definitions" => %{"foo\"bar" => %{"type" => "number"}},
              "properties" => %{"foo\"bar" => %{"$ref" => "#/definitions/foo%22bar"}}
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|object with numbers is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo\"bar" => 1})
    end

    test ~s|object with strings is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo\"bar" => "1"})
    end
  end

  describe ~s|Location-independent identifier| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "allOf" => [%{"$ref" => "#foo"}],
              "definitions" => %{"A" => %{"$id" => "#foo", "type" => "integer"}}
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|match|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|mismatch|, %{schema: schema} do
      refute valid?(schema, "a")
    end
  end
end
