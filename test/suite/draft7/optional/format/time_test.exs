defmodule Draft7.Optional.Format.TimeTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "validation of time strings" do
    setup do
      %{schema: Xema.new(format: :time)}
    end

    test "a valid time string", %{schema: schema} do
      data = "08:30:06.283185Z"
      assert valid?(schema, data)
    end

    test "an invalid time string", %{schema: schema} do
      data = "08:30:06 PST"
      refute valid?(schema, data)
    end

    test "only RFC3339 not all of ISO 8601 are valid", %{schema: schema} do
      data = "01:01:01,1111"
      refute valid?(schema, data)
    end
  end
end
