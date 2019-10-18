defmodule JsonSchemaTestSuite.Draft6.DependenciesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "dependencies" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"bar" => ["foo"]}},
            draft: "draft6"
          )
      }
    end

    test "neither", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "nondependant", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "with dependency", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "missing dependency", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test "ignores arrays", %{schema: schema} do
      assert valid?(schema, ["bar"])
    end

    test "ignores strings", %{schema: schema} do
      assert valid?(schema, "foobar")
    end

    test "ignores other non-objects", %{schema: schema} do
      assert valid?(schema, 12)
    end
  end

  describe "dependencies with empty array" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"bar" => []}},
            draft: "draft6"
          )
      }
    end

    test "empty object", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "object with one property", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2})
    end
  end

  describe "multiple dependencies" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"quux" => ["foo", "bar"]}},
            draft: "draft6"
          )
      }
    end

    test "neither", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "nondependants", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "with dependencies", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => 3})
    end

    test "missing dependency", %{schema: schema} do
      refute valid?(schema, %{"foo" => 1, "quux" => 2})
    end

    test "missing other dependency", %{schema: schema} do
      refute valid?(schema, %{"bar" => 1, "quux" => 2})
    end

    test "missing both dependencies", %{schema: schema} do
      refute valid?(schema, %{"quux" => 1})
    end
  end

  describe "multiple dependencies subschema" do
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
            draft: "draft6"
          )
      }
    end

    test "valid", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "no dependency", %{schema: schema} do
      assert valid?(schema, %{"foo" => "quux"})
    end

    test "wrong type", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => "quux"})
    end

    test "wrong type other", %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => 2})
    end

    test "wrong type both", %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => "quux"})
    end
  end

  describe "dependencies with boolean subschemas" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"bar" => false, "foo" => true}},
            draft: "draft6"
          )
      }
    end

    test "object with property having schema true is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "object with property having schema false is invalid", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test "object with both properties is invalid", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "empty object is valid", %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe "empty array of dependencies" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"dependencies" => %{"foo" => []}},
            draft: "draft6"
          )
      }
    end

    test "object with property is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "empty object is valid", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "non-object is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end
  end

  describe "dependencies with escaped characters" do
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
            draft: "draft6"
          )
      }
    end

    test "valid object 1", %{schema: schema} do
      assert valid?(schema, %{"foo\nbar" => 1, "foo\rbar" => 2})
    end

    test "valid object 2", %{schema: schema} do
      assert valid?(schema, %{"a" => 2, "b" => 3, "c" => 4, "foo\tbar" => 1})
    end

    test "valid object 3", %{schema: schema} do
      assert valid?(schema, %{"foo\"bar" => 2, "foo'bar" => 1})
    end

    test "invalid object 1", %{schema: schema} do
      refute valid?(schema, %{"foo" => 2, "foo\nbar" => 1})
    end

    test "invalid object 2", %{schema: schema} do
      refute valid?(schema, %{"a" => 2, "foo\tbar" => 1})
    end

    test "invalid object 3", %{schema: schema} do
      refute valid?(schema, %{"foo'bar" => 1})
    end

    test "invalid object 4", %{schema: schema} do
      refute valid?(schema, %{"foo\"bar" => 2})
    end
  end
end
