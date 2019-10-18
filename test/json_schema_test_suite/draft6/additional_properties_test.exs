defmodule JsonSchemaTestSuite.Draft6.AdditionalPropertiesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "additionalProperties being false does not allow other properties" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalProperties" => false,
              "patternProperties" => %{"^v" => %{}},
              "properties" => %{"bar" => %{}, "foo" => %{}}
            },
            draft: "draft6"
          )
      }
    end

    test "no additional properties is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "an additional property is invalid", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => "boom"})
    end

    test "ignores arrays", %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test "ignores strings", %{schema: schema} do
      assert valid?(schema, "foobarbaz")
    end

    test "ignores other non-objects", %{schema: schema} do
      assert valid?(schema, 12)
    end

    test "patternProperties are not additional properties", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1, "vroom" => 2})
    end
  end

  describe "non-ASCII pattern with additionalProperties" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalProperties" => false, "patternProperties" => %{"^á" => %{}}},
            draft: "draft6"
          )
      }
    end

    test "matching the pattern is valid", %{schema: schema} do
      assert valid?(schema, %{"ármányos" => 2})
    end

    test "not matching the pattern is invalid", %{schema: schema} do
      refute valid?(schema, %{"élmény" => 2})
    end
  end

  describe "additionalProperties allows a schema which should validate" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalProperties" => %{"type" => "boolean"},
              "properties" => %{"bar" => %{}, "foo" => %{}}
            },
            draft: "draft6"
          )
      }
    end

    test "no additional properties is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "an additional valid property is valid", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => true})
    end

    test "an additional invalid property is invalid", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => 12})
    end
  end

  describe "additionalProperties can exist by itself" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalProperties" => %{"type" => "boolean"}},
            draft: "draft6"
          )
      }
    end

    test "an additional valid property is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => true})
    end

    test "an additional invalid property is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => 1})
    end
  end

  describe "additionalProperties are allowed by default" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"bar" => %{}, "foo" => %{}}},
            draft: "draft6"
          )
      }
    end

    test "additional properties are allowed", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => true})
    end
  end

  describe "additionalProperties should not look in applicators" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalProperties" => %{"type" => "boolean"},
              "allOf" => [%{"properties" => %{"foo" => %{}}}]
            },
            draft: "draft6"
          )
      }
    end

    test "properties defined in allOf are not allowed", %{schema: schema} do
      refute valid?(schema, %{"bar" => true, "foo" => 1})
    end
  end
end
