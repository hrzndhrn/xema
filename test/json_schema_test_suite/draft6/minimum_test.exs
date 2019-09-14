defmodule JsonSchemaTestSuite.Draft6.Minimum do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "minimum validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"minimum" => 1.1})}
    end

    test "above the minimum is valid", %{schema: schema} do
      assert valid?(schema, 2.6)
    end

    test "boundary point is valid", %{schema: schema} do
      assert valid?(schema, 1.1)
    end

    test "below the minimum is invalid", %{schema: schema} do
      refute valid?(schema, 0.6)
    end

    test "ignores non-numbers", %{schema: schema} do
      assert valid?(schema, "x")
    end
  end

  describe "minimum validation with signed integer" do
    setup do
      %{schema: Xema.from_json_schema(%{"minimum" => -2})}
    end

    test "negative above the minimum is valid", %{schema: schema} do
      assert valid?(schema, -1)
    end

    test "positive above the minimum is valid", %{schema: schema} do
      assert valid?(schema, 0)
    end

    test "boundary point is valid", %{schema: schema} do
      assert valid?(schema, -2)
    end

    test "below the minimum is invalid", %{schema: schema} do
      refute valid?(schema, -3)
    end

    test "ignores non-numbers", %{schema: schema} do
      assert valid?(schema, "x")
    end
  end
end