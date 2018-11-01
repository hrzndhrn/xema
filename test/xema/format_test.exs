defmodule FormatTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  describe "validation of date-time strings" do
    setup do
      %{schema: Xema.new(format: :date_time)}
    end

    test "with an invalid day in date-time string", %{schema: schema} do
      data = "1990-02-31T15:59:60.123-08:00"

      assert validate(schema, data) ==
               {:error,
                %{format: :date_time, value: "1990-02-31T15:59:60.123-08:00"}}
    end
  end

  describe "validation of regex strings" do
    setup do
      %{schema: Xema.new(format: :regex)}
    end

    test "with a valid string", %{schema: schema} do
      assert validate(schema, "a.*b") == :ok
    end

    test "with an invalid string", %{schema: schema} do
      assert validate(schema, "a(.*b") ==
               {:error,
                %{format: :regex, reason: {'missing )', 5}, value: "a(.*b"}}
    end
  end
end
