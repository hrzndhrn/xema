defmodule JsonSchemaTestSuite.Draft7.Enum do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "simple enum validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"enum" => [1, 2, 3]})}
    end

    test "one of the enum is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "something else is invalid", %{schema: schema} do
      refute valid?(schema, 4)
    end
  end

  describe "heterogeneous enum validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"enum" => [6, "foo", [], true, %{"foo" => 12}]})}
    end

    test "one of the enum is valid", %{schema: schema} do
      assert valid?(schema, [])
    end

    test "something else is invalid", %{schema: schema} do
      refute valid?(schema, nil)
    end

    test "objects are deep compared", %{schema: schema} do
      refute valid?(schema, %{"foo" => false})
    end
  end

  describe "enums in properties" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "properties" => %{"bar" => %{"enum" => ["bar"]}, "foo" => %{"enum" => ["foo"]}},
            "required" => ["bar"],
            "type" => "object"
          })
      }
    end

    test "both properties are valid", %{schema: schema} do
      assert valid?(schema, %{"bar" => "bar", "foo" => "foo"})
    end

    test "missing optional property is valid", %{schema: schema} do
      assert valid?(schema, %{"bar" => "bar"})
    end

    test "missing required property is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => "foo"})
    end

    test "missing all properties is invalid", %{schema: schema} do
      refute valid?(schema, %{})
    end
  end

  describe "enum with escaped characters" do
    setup do
      %{schema: Xema.from_json_schema(%{"enum" => ["foo\nbar", "foo\rbar"]})}
    end

    test "member 1 is valid", %{schema: schema} do
      assert valid?(schema, "foo\nbar")
    end

    test "member 2 is valid", %{schema: schema} do
      assert valid?(schema, "foo\rbar")
    end

    test "another string is invalid", %{schema: schema} do
      refute valid?(schema, "abc")
    end
  end

  describe "enum with false does not match 0" do
    setup do
      %{schema: Xema.from_json_schema(%{"enum" => [false]})}
    end

    test "false is valid", %{schema: schema} do
      assert valid?(schema, false)
    end

    test "integer zero is invalid", %{schema: schema} do
      refute valid?(schema, 0)
    end

    test "float zero is invalid", %{schema: schema} do
      refute valid?(schema, 0.0)
    end
  end

  describe "enum with true does not match 1" do
    setup do
      %{schema: Xema.from_json_schema(%{"enum" => [true]})}
    end

    test "true is valid", %{schema: schema} do
      assert valid?(schema, true)
    end

    test "integer one is invalid", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "float one is invalid", %{schema: schema} do
      refute valid?(schema, 1.0)
    end
  end

  describe "enum with 0 does not match false" do
    setup do
      %{schema: Xema.from_json_schema(%{"enum" => [0]})}
    end

    test "false is invalid", %{schema: schema} do
      refute valid?(schema, false)
    end

    test "integer zero is valid", %{schema: schema} do
      assert valid?(schema, 0)
    end

    test "float zero is valid", %{schema: schema} do
      assert valid?(schema, 0.0)
    end
  end

  describe "enum with 1 does not match true" do
    setup do
      %{schema: Xema.from_json_schema(%{"enum" => [1]})}
    end

    test "true is invalid", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "integer one is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "float one is valid", %{schema: schema} do
      assert valid?(schema, 1.0)
    end
  end
end
