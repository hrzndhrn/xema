defmodule JsonSchemaTestSuite.Draft7.Optional.Format.Time do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of time strings" do
    setup do
      %{schema: Xema.from_json_schema(%{"format" => "time"})}
    end

    test "a valid time string", %{schema: schema} do
      assert valid?(schema, "08:30:06.283185Z")
    end

    test "an invalid time string", %{schema: schema} do
      refute valid?(schema, "08:30:06 PST")
    end

    test "only RFC3339 not all of ISO 8601 are valid", %{schema: schema} do
      refute valid?(schema, "01:01:01,1111")
    end
  end
end