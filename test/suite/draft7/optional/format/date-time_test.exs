defmodule Draft7.Optional.Format.Date - timeTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "validation of date-time strings" do
    setup do
      %{schema: Xema.new(:format, :date_time)}
    end

    test "a valid date-time string", %{schema: schema} do
      data = "1963-06-19T08:30:06.283185Z"
      assert is_valid?(schema, data)
    end

    test "a valid date-time string without second fraction", %{schema: schema} do
      data = "1963-06-19T08:30:06Z"
      assert is_valid?(schema, data)
    end

    test "a valid date-time string with plus offset", %{schema: schema} do
      data = "1937-01-01T12:00:27.87+00:20"
      assert is_valid?(schema, data)
    end

    test "a valid date-time string with minus offset", %{schema: schema} do
      data = "1990-12-31T15:59:50.123-08:00"
      assert is_valid?(schema, data)
    end

    test "a invalid day in date-time string", %{schema: schema} do
      data = "1990-02-31T15:59:60.123-08:00"
      refute is_valid?(schema, data)
    end

    test "an invalid offset in date-time string", %{schema: schema} do
      data = "1990-12-31T15:59:60-24:00"
      refute is_valid?(schema, data)
    end

    test "an invalid date-time string", %{schema: schema} do
      data = "06/19/1963 08:30:06 PST"
      refute is_valid?(schema, data)
    end

    test "case-insensitive T and Z", %{schema: schema} do
      data = "1963-06-19t08:30:06.283185z"
      assert is_valid?(schema, data)
    end

    test "only RFC3339 not all of ISO 8601 are valid", %{schema: schema} do
      data = "2013-350T01:01:01"
      refute is_valid?(schema, data)
    end
  end
end
