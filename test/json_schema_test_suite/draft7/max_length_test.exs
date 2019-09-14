defmodule JsonSchemaTestSuite.Draft7.MaxLength do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "maxLength validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"maxLength" => 2})}
    end

    test "shorter is valid", %{schema: schema} do
      assert valid?(schema, "f")
    end

    test "exact length is valid", %{schema: schema} do
      assert valid?(schema, "fo")
    end

    test "too long is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "ignores non-strings", %{schema: schema} do
      assert valid?(schema, 100)
    end

    test "two supplementary Unicode code points is long enough", %{schema: schema} do
      assert valid?(schema, "💩💩")
    end
  end
end