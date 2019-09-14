defmodule JsonSchemaTestSuite.Draft6.Contains do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "contains keyword validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"contains" => %{"minimum" => 5}})}
    end

    test "array with item matching schema (5) is valid", %{schema: schema} do
      assert valid?(schema, [3, 4, 5])
    end

    test "array with item matching schema (6) is valid", %{schema: schema} do
      assert valid?(schema, [3, 4, 6])
    end

    test "array with two items matching schema (5, 6) is valid", %{schema: schema} do
      assert valid?(schema, [3, 4, 5, 6])
    end

    test "array without items matching schema is invalid", %{schema: schema} do
      refute valid?(schema, [2, 3, 4])
    end

    test "empty array is invalid", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "not array is valid", %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe "contains keyword with const keyword" do
    setup do
      %{schema: Xema.from_json_schema(%{"contains" => %{"const" => 5}})}
    end

    test "array with item 5 is valid", %{schema: schema} do
      assert valid?(schema, [3, 4, 5])
    end

    test "array with two items 5 is valid", %{schema: schema} do
      assert valid?(schema, [3, 4, 5, 5])
    end

    test "array without item 5 is invalid", %{schema: schema} do
      refute valid?(schema, [1, 2, 3, 4])
    end
  end

  describe "contains keyword with boolean schema true" do
    setup do
      %{schema: Xema.from_json_schema(%{"contains" => true})}
    end

    test "any non-empty array is valid", %{schema: schema} do
      assert valid?(schema, ["foo"])
    end

    test "empty array is invalid", %{schema: schema} do
      refute valid?(schema, [])
    end
  end

  describe "contains keyword with boolean schema false" do
    setup do
      %{schema: Xema.from_json_schema(%{"contains" => false})}
    end

    test "any non-empty array is invalid", %{schema: schema} do
      refute valid?(schema, ["foo"])
    end

    test "empty array is invalid", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "non-arrays are valid", %{schema: schema} do
      assert valid?(schema, "contains does not apply to strings")
    end
  end
end