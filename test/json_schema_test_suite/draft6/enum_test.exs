defmodule JsonSchemaTestSuite.Draft6.EnumTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|simple enum validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [1, 2, 3]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|one of the enum is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|something else is invalid|, %{schema: schema} do
      refute valid?(schema, 4)
    end
  end

  describe ~s|heterogeneous enum validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [6, "foo", [], true, %{"foo" => 12}]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|one of the enum is valid|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|something else is invalid|, %{schema: schema} do
      refute valid?(schema, nil)
    end

    test ~s|objects are deep compared|, %{schema: schema} do
      refute valid?(schema, %{"foo" => false})
    end

    test ~s|valid object matches|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 12})
    end

    test ~s|extra properties in object is invalid|, %{schema: schema} do
      refute valid?(schema, %{"boo" => 42, "foo" => 12})
    end
  end

  describe ~s|heterogeneous enum-with-null validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [6, nil]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|null is valid|, %{schema: schema} do
      assert valid?(schema, nil)
    end

    test ~s|number is valid|, %{schema: schema} do
      assert valid?(schema, 6)
    end

    test ~s|something else is invalid|, %{schema: schema} do
      refute valid?(schema, "test")
    end
  end

  describe ~s|enums in properties| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "properties" => %{"bar" => %{"enum" => ["bar"]}, "foo" => %{"enum" => ["foo"]}},
              "required" => ["bar"],
              "type" => "object"
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|both properties are valid|, %{schema: schema} do
      assert valid?(schema, %{"bar" => "bar", "foo" => "foo"})
    end

    test ~s|wrong foo value|, %{schema: schema} do
      refute valid?(schema, %{"bar" => "bar", "foo" => "foot"})
    end

    test ~s|wrong bar value|, %{schema: schema} do
      refute valid?(schema, %{"bar" => "bart", "foo" => "foo"})
    end

    test ~s|missing optional property is valid|, %{schema: schema} do
      assert valid?(schema, %{"bar" => "bar"})
    end

    test ~s|missing required property is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "foo"})
    end

    test ~s|missing all properties is invalid|, %{schema: schema} do
      refute valid?(schema, %{})
    end
  end

  describe ~s|enum with escaped characters| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => ["foo\nbar", "foo\rbar"]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|member 1 is valid|, %{schema: schema} do
      assert valid?(schema, "foo\nbar")
    end

    test ~s|member 2 is valid|, %{schema: schema} do
      assert valid?(schema, "foo\rbar")
    end

    test ~s|another string is invalid|, %{schema: schema} do
      refute valid?(schema, "abc")
    end
  end

  describe ~s|enum with false does not match 0| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [false]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|false is valid|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|integer zero is invalid|, %{schema: schema} do
      refute valid?(schema, 0)
    end

    test ~s|float zero is invalid|, %{schema: schema} do
      refute valid?(schema, 0.0)
    end
  end

  describe ~s|enum with true does not match 1| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [true]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|true is valid|, %{schema: schema} do
      assert valid?(schema, true)
    end

    test ~s|integer one is invalid|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|float one is invalid|, %{schema: schema} do
      refute valid?(schema, 1.0)
    end
  end

  describe ~s|enum with 0 does not match false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [0]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|false is invalid|, %{schema: schema} do
      refute valid?(schema, false)
    end

    test ~s|integer zero is valid|, %{schema: schema} do
      assert valid?(schema, 0)
    end

    test ~s|float zero is valid|, %{schema: schema} do
      assert valid?(schema, 0.0)
    end
  end

  describe ~s|enum with 1 does not match true| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [1]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|true is invalid|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|integer one is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|float one is valid|, %{schema: schema} do
      assert valid?(schema, 1.0)
    end
  end

  describe ~s|nul characters in strings| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"enum" => [<<104, 101, 108, 108, 111, 0, 116, 104, 101, 114, 101>>]},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|match string with nul|, %{schema: schema} do
      assert valid?(schema, <<104, 101, 108, 108, 111, 0, 116, 104, 101, 114, 101>>)
    end

    test ~s|do not match string lacking nul|, %{schema: schema} do
      refute valid?(schema, "hellothere")
    end
  end
end
