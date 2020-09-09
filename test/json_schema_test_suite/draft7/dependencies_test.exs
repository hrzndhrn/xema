defmodule JsonSchemaTestSuite.Draft7.DependenciesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|dependencies| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"bar" => ["foo"]}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|neither|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|nondependant|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|with dependency|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|missing dependency|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, ["bar"])
    end

    test ~s|ignores strings|, %{schema: schema} do
      assert valid?(schema, "foobar")
    end

    test ~s|ignores other non-objects|, %{schema: schema} do
      assert valid?(schema, 12)
    end
  end

  describe ~s|dependencies with empty array| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"bar" => []}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|empty object|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|object with one property|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2})
    end

    test ~s|non-object is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end
  end

  describe ~s|multiple dependencies| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"quux" => ["foo", "bar"]}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|neither|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|nondependants|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|with dependencies|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => 3})
    end

    test ~s|missing dependency|, %{schema: schema} do
      refute valid?(schema, %{"foo" => 1, "quux" => 2})
    end

    test ~s|missing other dependency|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 1, "quux" => 2})
    end

    test ~s|missing both dependencies|, %{schema: schema} do
      refute valid?(schema, %{"quux" => 1})
    end
  end

  describe ~s|multiple dependencies subschema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "dependencies" => %{
                "bar" => %{
                  "properties" => %{
                    "bar" => %{"type" => "integer"},
                    "foo" => %{"type" => "integer"}
                  }
                }
              }
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|no dependency|, %{schema: schema} do
      assert valid?(schema, %{"foo" => "quux"})
    end

    test ~s|wrong type|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => "quux"})
    end

    test ~s|wrong type other|, %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => 2})
    end

    test ~s|wrong type both|, %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => "quux"})
    end
  end

  describe ~s|dependencies with boolean subschemas| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"bar" => false, "foo" => true}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|object with property having schema true is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|object with property having schema false is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test ~s|object with both properties is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|empty object is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe ~s|dependencies with escaped characters| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "dependencies" => %{
                "foo\tbar" => %{"minProperties" => 4},
                "foo\nbar" => ["foo\rbar"],
                "foo\"bar" => ["foo'bar"],
                "foo'bar" => %{"required" => ["foo\"bar"]}
              }
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid object 1|, %{schema: schema} do
      assert valid?(schema, %{"foo\nbar" => 1, "foo\rbar" => 2})
    end

    test ~s|valid object 2|, %{schema: schema} do
      assert valid?(schema, %{"a" => 2, "b" => 3, "c" => 4, "foo\tbar" => 1})
    end

    test ~s|valid object 3|, %{schema: schema} do
      assert valid?(schema, %{"foo\"bar" => 2, "foo'bar" => 1})
    end

    test ~s|invalid object 1|, %{schema: schema} do
      refute valid?(schema, %{"foo" => 2, "foo\nbar" => 1})
    end

    test ~s|invalid object 2|, %{schema: schema} do
      refute valid?(schema, %{"a" => 2, "foo\tbar" => 1})
    end

    test ~s|invalid object 3|, %{schema: schema} do
      refute valid?(schema, %{"foo'bar" => 1})
    end

    test ~s|invalid object 4|, %{schema: schema} do
      refute valid?(schema, %{"foo\"bar" => 2})
    end
  end
end
