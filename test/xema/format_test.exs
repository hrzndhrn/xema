defmodule FormatTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "validation of date-time strings" do
    setup do
      %{schema: Xema.new(format: :date_time)}
    end

    test "with an invalid day in date-time string", %{schema: schema} do
      data = "1990-02-31T15:59:60.123-08:00"

      message =
        ~s|String "1990-02-31T15:59:60.123-08:00" does not validate against format :date_time.|

      assert {
               :error,
               %ValidationError{
                 reason: %{format: :date_time, value: "1990-02-31T15:59:60.123-08:00"}
               } = error
             } = validate(schema, data)

      assert Exception.message(error) == message
    end
  end

  describe "validation of unknown format" do
    setup do
      %{schema: Xema.new(format: :whatever)}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "whatever floats your boat") == :ok
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
      assert {
               :error,
               %ValidationError{
                 reason: %{format: :regex, value: "a(.*b"}
               } = error
             } = validate(schema, "a(.*b")

      assert Exception.message(error) ==
               ~s|String "a(.*b" does not validate against format :regex.|
    end
  end
end
