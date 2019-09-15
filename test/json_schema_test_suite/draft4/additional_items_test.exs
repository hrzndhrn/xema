defmodule JsonSchemaTestSuite.Draft4.AdditionalItems do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "additionalItems as schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{"additionalItems" => %{"type" => "integer"}, "items" => [%{}]})
      }
    end

    test "additional items match schema", %{schema: schema} do
      assert valid?(schema, [nil, 2, 3, 4])
    end

    test "additional items do not match schema", %{schema: schema} do
      refute valid?(schema, [nil, 2, 3, "foo"])
    end
  end

  describe "items is schema, no additionalItems" do
    setup do
      %{schema: Xema.from_json_schema(%{"additionalItems" => false, "items" => %{}})}
    end

    test "all items match schema", %{schema: schema} do
      assert valid?(schema, [1, 2, 3, 4, 5])
    end
  end

  describe "array of items with no additionalItems" do
    setup do
      %{schema: Xema.from_json_schema(%{"additionalItems" => false, "items" => [%{}, %{}, %{}]})}
    end

    test "fewer number of items present", %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test "equal number of items present", %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test "additional items are not permitted", %{schema: schema} do
      refute valid?(schema, [1, 2, 3, 4])
    end
  end

  describe "additionalItems as false without items" do
    setup do
      %{schema: Xema.from_json_schema(%{"additionalItems" => false})}
    end

    test "items defaults to empty schema so everything is valid", %{schema: schema} do
      assert valid?(schema, [1, 2, 3, 4, 5])
    end

    test "ignores non-arrays", %{schema: schema} do
      assert valid?(schema, %{"foo" => "bar"})
    end
  end

  describe "additionalItems are allowed by default" do
    setup do
      %{schema: Xema.from_json_schema(%{"items" => [%{"type" => "integer"}]})}
    end

    test "only the first item is validated", %{schema: schema} do
      assert valid?(schema, [1, "foo", false])
    end
  end
end
