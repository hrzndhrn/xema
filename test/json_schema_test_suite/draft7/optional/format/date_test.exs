defmodule JsonSchemaTestSuite.Draft7.Optional.Format.Date do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of date strings" do
    setup do
      %{schema: Xema.from_json_schema(%{"format" => "date"})}
    end

    test "a valid date string", %{schema: schema} do
      assert valid?(schema, "1963-06-19")
    end

    test "an invalid date-time string", %{schema: schema} do
      refute valid?(schema, "06/19/1963")
    end

    test "only RFC3339 not all of ISO 8601 are valid", %{schema: schema} do
      refute valid?(schema, "2013-350")
    end
  end
end
