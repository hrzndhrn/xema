defmodule JsonSchemaTestSuite.Draft6.PropertyNames do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "propertyNames validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"propertyNames" => %{"maxLength" => 3}})}
    end

    test "all property names valid", %{schema: schema} do
      assert valid?(schema, %{"f" => %{}, "foo" => %{}})
    end

    test "some property names invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => %{}, "foobar" => %{}})
    end

    test "object without properties is valid", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "ignores arrays", %{schema: schema} do
      assert valid?(schema, [1, 2, 3, 4])
    end

    test "ignores strings", %{schema: schema} do
      assert valid?(schema, "foobar")
    end

    test "ignores other non-objects", %{schema: schema} do
      assert valid?(schema, 12)
    end
  end

  describe "propertyNames with boolean schema true" do
    setup do
      %{schema: Xema.from_json_schema(%{"propertyNames" => true})}
    end

    test "object with any properties is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "empty object is valid", %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe "propertyNames with boolean schema false" do
    setup do
      %{schema: Xema.from_json_schema(%{"propertyNames" => false})}
    end

    test "object with any properties is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => 1})
    end

    test "empty object is valid", %{schema: schema} do
      assert valid?(schema, %{})
    end
  end
end