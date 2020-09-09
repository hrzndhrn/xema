defmodule JsonSchemaTestSuite.Draft7.AdditionalPropertiesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|additionalProperties being false does not allow other properties| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalProperties" => false,
              "patternProperties" => %{"^v" => %{}},
              "properties" => %{"bar" => %{}, "foo" => %{}}
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|no additional properties is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|an additional property is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => "boom"})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test ~s|ignores strings|, %{schema: schema} do
      assert valid?(schema, "foobarbaz")
    end

    test ~s|ignores other non-objects|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|patternProperties are not additional properties|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1, "vroom" => 2})
    end
  end

  describe ~s|non-ASCII pattern with additionalProperties| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalProperties" => false, "patternProperties" => %{"^á" => %{}}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|matching the pattern is valid|, %{schema: schema} do
      assert valid?(schema, %{"ármányos" => 2})
    end

    test ~s|not matching the pattern is invalid|, %{schema: schema} do
      refute valid?(schema, %{"élmény" => 2})
    end
  end

  describe ~s|additionalProperties allows a schema which should validate| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalProperties" => %{"type" => "boolean"},
              "properties" => %{"bar" => %{}, "foo" => %{}}
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|no additional properties is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|an additional valid property is valid|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => true})
    end

    test ~s|an additional invalid property is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => 12})
    end
  end

  describe ~s|additionalProperties can exist by itself| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalProperties" => %{"type" => "boolean"}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|an additional valid property is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => true})
    end

    test ~s|an additional invalid property is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => 1})
    end
  end

  describe ~s|additionalProperties are allowed by default| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"bar" => %{}, "foo" => %{}}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|additional properties are allowed|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1, "quux" => true})
    end
  end

  describe ~s|additionalProperties should not look in applicators| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalProperties" => %{"type" => "boolean"},
              "allOf" => [%{"properties" => %{"foo" => %{}}}]
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|properties defined in allOf are not examined|, %{schema: schema} do
      refute valid?(schema, %{"bar" => true, "foo" => 1})
    end
  end
end
