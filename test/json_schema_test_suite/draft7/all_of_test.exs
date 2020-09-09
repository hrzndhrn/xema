defmodule JsonSchemaTestSuite.Draft7.AllOfTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|allOf| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "allOf" => [
                %{"properties" => %{"bar" => %{"type" => "integer"}}, "required" => ["bar"]},
                %{"properties" => %{"foo" => %{"type" => "string"}}, "required" => ["foo"]}
              ]
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|allOf|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => "baz"})
    end

    test ~s|mismatch second|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "baz"})
    end

    test ~s|mismatch first|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test ~s|wrong type|, %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => "baz"})
    end
  end

  describe ~s|allOf with base schema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "allOf" => [
                %{"properties" => %{"foo" => %{"type" => "string"}}, "required" => ["foo"]},
                %{"properties" => %{"baz" => %{"type" => "null"}}, "required" => ["baz"]}
              ],
              "properties" => %{"bar" => %{"type" => "integer"}},
              "required" => ["bar"]
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "baz" => nil, "foo" => "quux"})
    end

    test ~s|mismatch base schema|, %{schema: schema} do
      refute valid?(schema, %{"baz" => nil, "foo" => "quux"})
    end

    test ~s|mismatch first allOf|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "baz" => nil})
    end

    test ~s|mismatch second allOf|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => "quux"})
    end

    test ~s|mismatch both|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end
  end

  describe ~s|allOf simple types| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{"maximum" => 30}, %{"minimum" => 20}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid|, %{schema: schema} do
      assert valid?(schema, 25)
    end

    test ~s|mismatch one|, %{schema: schema} do
      refute valid?(schema, 35)
    end
  end

  describe ~s|allOf with boolean schemas, all true| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [true, true]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|any value is valid|, %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end

  describe ~s|allOf with boolean schemas, some false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [true, false]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|any value is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe ~s|allOf with boolean schemas, all false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [false, false]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|any value is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe ~s|allOf with one empty schema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|any data is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end
  end

  describe ~s|allOf with two empty schemas| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{}, %{}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|any data is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end
  end

  describe ~s|allOf with the first empty schema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{}, %{"type" => "number"}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|number is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|string is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe ~s|allOf with the last empty schema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{"type" => "number"}, %{}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|number is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|string is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe ~s|nested allOf, to check validation semantics| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{"allOf" => [%{"type" => "null"}]}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|null is valid|, %{schema: schema} do
      assert valid?(schema, nil)
    end

    test ~s|anything non-null is invalid|, %{schema: schema} do
      refute valid?(schema, 123)
    end
  end

  describe ~s|allOf combined with anyOf, oneOf| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "allOf" => [%{"multipleOf" => 2}],
              "anyOf" => [%{"multipleOf" => 3}],
              "oneOf" => [%{"multipleOf" => 5}]
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|allOf: false, anyOf: false, oneOf: false|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|allOf: false, anyOf: false, oneOf: true|, %{schema: schema} do
      refute valid?(schema, 5)
    end

    test ~s|allOf: false, anyOf: true, oneOf: false|, %{schema: schema} do
      refute valid?(schema, 3)
    end

    test ~s|allOf: false, anyOf: true, oneOf: true|, %{schema: schema} do
      refute valid?(schema, 15)
    end

    test ~s|allOf: true, anyOf: false, oneOf: false|, %{schema: schema} do
      refute valid?(schema, 2)
    end

    test ~s|allOf: true, anyOf: false, oneOf: true|, %{schema: schema} do
      refute valid?(schema, 10)
    end

    test ~s|allOf: true, anyOf: true, oneOf: false|, %{schema: schema} do
      refute valid?(schema, 6)
    end

    test ~s|allOf: true, anyOf: true, oneOf: true|, %{schema: schema} do
      assert valid?(schema, 30)
    end
  end
end
