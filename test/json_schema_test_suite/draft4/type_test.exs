defmodule JsonSchemaTestSuite.Draft4.TypeTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|integer type matches integers| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => "integer"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|an integer is an integer|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|a float is not an integer|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|a string is not an integer|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|a string is still not an integer, even if it looks like one|, %{schema: schema} do
      refute valid?(schema, "1")
    end

    test ~s|an object is not an integer|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|an array is not an integer|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|a boolean is not an integer|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|null is not an integer|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|number type matches numbers| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => "number"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|an integer is a number|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|a float with zero fractional part is a number|, %{schema: schema} do
      assert valid?(schema, 1.0)
    end

    test ~s|a float is a number|, %{schema: schema} do
      assert valid?(schema, 1.1)
    end

    test ~s|a string is not a number|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|a string is still not a number, even if it looks like one|, %{schema: schema} do
      refute valid?(schema, "1")
    end

    test ~s|an object is not a number|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|an array is not a number|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|a boolean is not a number|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|null is not a number|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|string type matches strings| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => "string"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|1 is not a string|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|a float is not a string|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|a string is a string|, %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test ~s|a string is still a string, even if it looks like a number|, %{schema: schema} do
      assert valid?(schema, "1")
    end

    test ~s|an empty string is still a string|, %{schema: schema} do
      assert valid?(schema, "")
    end

    test ~s|an object is not a string|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|an array is not a string|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|a boolean is not a string|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|null is not a string|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|object type matches objects| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => "object"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|an integer is not an object|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|a float is not an object|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|a string is not an object|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|an object is an object|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|an array is not an object|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|a boolean is not an object|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|null is not an object|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|array type matches arrays| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => "array"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|an integer is not an array|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|a float is not an array|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|a string is not an array|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|an object is not an array|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|an array is an array|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|a boolean is not an array|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|null is not an array|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|boolean type matches booleans| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => "boolean"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|an integer is not a boolean|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|zero is not a boolean|, %{schema: schema} do
      refute valid?(schema, 0)
    end

    test ~s|a float is not a boolean|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|a string is not a boolean|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|an empty string is not a boolean|, %{schema: schema} do
      refute valid?(schema, "")
    end

    test ~s|an object is not a boolean|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|an array is not a boolean|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|true is a boolean|, %{schema: schema} do
      assert valid?(schema, true)
    end

    test ~s|false is a boolean|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|null is not a boolean|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|null type matches only the null object| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => "null"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|an integer is not null|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|a float is not null|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|zero is not null|, %{schema: schema} do
      refute valid?(schema, 0)
    end

    test ~s|a string is not null|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|an empty string is not null|, %{schema: schema} do
      refute valid?(schema, "")
    end

    test ~s|an object is not null|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|an array is not null|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|true is not null|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|false is not null|, %{schema: schema} do
      refute valid?(schema, false)
    end

    test ~s|null is null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|multiple types can be specified in an array| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => ["integer", "string"]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|an integer is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|a string is valid|, %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test ~s|a float is invalid|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|an object is invalid|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|an array is invalid|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|a boolean is invalid|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|null is invalid|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|type as array with one item| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => ["string"]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|string is valid|, %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test ~s|number is invalid|, %{schema: schema} do
      refute valid?(schema, 123)
    end
  end

  describe ~s|type: array or object| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => ["array", "object"]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|array is valid|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test ~s|object is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 123})
    end

    test ~s|number is invalid|, %{schema: schema} do
      refute valid?(schema, 123)
    end

    test ~s|string is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|null is invalid|, %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe ~s|type: array, object or null| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"type" => ["array", "object", "null"]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|array is valid|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test ~s|object is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 123})
    end

    test ~s|null is valid|, %{schema: schema} do
      assert valid?(schema, nil)
    end

    test ~s|number is invalid|, %{schema: schema} do
      refute valid?(schema, 123)
    end

    test ~s|string is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end
end
