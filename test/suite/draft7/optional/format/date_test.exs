defmodule Draft7.Optional.Format.DateTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "validation of date strings" do
    setup do
      %{schema: Xema.new(format: :date)}
    end

    test "a valid date string", %{schema: schema} do
      data = "1963-06-19"
      assert valid?(schema, data)
    end

    test "an invalid date-time string", %{schema: schema} do
      data = "06/19/1963"
      refute valid?(schema, data)
    end

    test "only RFC3339 not all of ISO 8601 are valid", %{schema: schema} do
      data = "2013-350"
      refute valid?(schema, data)
    end
  end
end
