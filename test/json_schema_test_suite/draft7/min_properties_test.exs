defmodule JsonSchemaTestSuite.Draft7.MinProperties do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "minProperties validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"minProperties" => 1})}
    end

    test "longer is valid", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "exact length is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "too short is invalid", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "ignores arrays", %{schema: schema} do
      assert valid?(schema, [])
    end

    test "ignores strings", %{schema: schema} do
      assert valid?(schema, "")
    end

    test "ignores other non-objects", %{schema: schema} do
      assert valid?(schema, 12)
    end
  end
end