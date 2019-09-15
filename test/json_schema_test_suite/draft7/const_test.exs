defmodule JsonSchemaTestSuite.Draft7.Const do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "const validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => 2})}
    end

    test "same value is valid", %{schema: schema} do
      assert valid?(schema, 2)
    end

    test "another value is invalid", %{schema: schema} do
      refute valid?(schema, 5)
    end

    test "another type is invalid", %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe "const with object" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => %{"baz" => "bax", "foo" => "bar"}})}
    end

    test "same object is valid", %{schema: schema} do
      assert valid?(schema, %{"baz" => "bax", "foo" => "bar"})
    end

    test "same object with different property order is valid", %{schema: schema} do
      assert valid?(schema, %{"baz" => "bax", "foo" => "bar"})
    end

    test "another object is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar"})
    end

    test "another type is invalid", %{schema: schema} do
      refute valid?(schema, [1, 2])
    end
  end

  describe "const with array" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => [%{"foo" => "bar"}]})}
    end

    test "same array is valid", %{schema: schema} do
      assert valid?(schema, [%{"foo" => "bar"}])
    end

    test "another array item is invalid", %{schema: schema} do
      refute valid?(schema, [2])
    end

    test "array with additional items is invalid", %{schema: schema} do
      refute valid?(schema, [1, 2, 3])
    end
  end

  describe "const with null" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => nil})}
    end

    test "null is valid", %{schema: schema} do
      assert valid?(schema, nil)
    end

    test "not null is invalid", %{schema: schema} do
      refute valid?(schema, 0)
    end
  end

  describe "const with false does not match 0" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => false})}
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

  describe "const with true does not match 1" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => true})}
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

  describe "const with 0 does not match false" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => 0})}
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

  describe "const with 1 does not match true" do
    setup do
      %{schema: Xema.from_json_schema(%{"const" => 1})}
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
