defmodule JsonSchemaTestSuite.Draft6.MinItems do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "minItems validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"minItems" => 1})}
    end

    test "longer is valid", %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test "exact length is valid", %{schema: schema} do
      assert valid?(schema, [1])
    end

    test "too short is invalid", %{schema: schema} do
      refute valid?(schema, [])
    end

    test "ignores non-arrays", %{schema: schema} do
      assert valid?(schema, "")
    end
  end
end
