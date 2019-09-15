defmodule JsonSchemaTestSuite.Draft6.Type do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "integer type matches integers" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "integer"})}
    end

    test "an integer is an integer", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "a float is not an integer", %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test "a string is not an integer", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "a string is still not an integer, even if it looks like one", %{schema: schema} do
      refute valid?(schema, "1")
    end

    test "an object is not an integer", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "an array is not an integer", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "a boolean is not an integer", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "null is not an integer", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "number type matches numbers" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "number"})}
    end

    test "an integer is a number", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "a float is a number", %{schema: schema} do
      assert valid?(schema, 1.1)
    end

    test "a string is not a number", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "a string is still not a number, even if it looks like one", %{schema: schema} do
      refute valid?(schema, "1")
    end

    test "an object is not a number", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "an array is not a number", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "a boolean is not a number", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "null is not a number", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "string type matches strings" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "string"})}
    end

    test "1 is not a string", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "a float is not a string", %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test "a string is a string", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "a string is still a string, even if it looks like a number", %{schema: schema} do
      assert valid?(schema, "1")
    end

    test "an empty string is still a string", %{schema: schema} do
      assert valid?(schema, "")
    end

    test "an object is not a string", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "an array is not a string", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "a boolean is not a string", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "null is not a string", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "object type matches objects" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "object"})}
    end

    test "an integer is not an object", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "a float is not an object", %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test "a string is not an object", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "an object is an object", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "an array is not an object", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "a boolean is not an object", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "null is not an object", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "array type matches arrays" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "array"})}
    end

    test "an integer is not an array", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "a float is not an array", %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test "a string is not an array", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "an object is not an array", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "an array is an array", %{schema: schema} do
      assert valid?(schema, [])
    end

    test "a boolean is not an array", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "null is not an array", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "boolean type matches booleans" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "boolean"})}
    end

    test "an integer is not a boolean", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "zero is not a boolean", %{schema: schema} do
      refute valid?(schema, 0)
    end

    test "a float is not a boolean", %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test "a string is not a boolean", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "an empty string is not a boolean", %{schema: schema} do
      refute valid?(schema, "")
    end

    test "an object is not a boolean", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "an array is not a boolean", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "true is a boolean", %{schema: schema} do
      assert valid?(schema, true)
    end

    test "false is a boolean", %{schema: schema} do
      assert valid?(schema, false)
    end

    test "null is not a boolean", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "null type matches only the null object" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "null"})}
    end

    test "an integer is not null", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "a float is not null", %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test "zero is not null", %{schema: schema} do
      refute valid?(schema, 0)
    end

    test "a string is not null", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "an empty string is not null", %{schema: schema} do
      refute valid?(schema, "")
    end

    test "an object is not null", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "an array is not null", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "true is not null", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "false is not null", %{schema: schema} do
      refute valid?(schema, false)
    end

    test "null is null", %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe "multiple types can be specified in an array" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => ["integer", "string"]})}
    end

    test "an integer is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "a string is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "a float is invalid", %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test "an object is invalid", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "an array is invalid", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "a boolean is invalid", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "null is invalid", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "type as array with one item" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => ["string"]})}
    end

    test "string is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "number is invalid", %{schema: schema} do
      refute valid?(schema, 123)
    end
  end

  describe "type: array or object" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => ["array", "object"]})}
    end

    test "array is valid", %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test "object is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 123})
    end

    test "number is invalid", %{schema: schema} do
      refute valid?(schema, 123)
    end

    test "string is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "null is invalid", %{schema: schema} do
      refute valid?(schema, nil)
    end
  end

  describe "type: array, object or null" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => ["array", "object", "null"]})}
    end

    test "array is valid", %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test "object is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 123})
    end

    test "null is valid", %{schema: schema} do
      assert valid?(schema, nil)
    end

    test "number is invalid", %{schema: schema} do
      refute valid?(schema, 123)
    end

    test "string is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end
end
