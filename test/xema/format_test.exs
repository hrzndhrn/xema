defmodule FormatTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  describe "validation of date-time strings" do
    setup do
      %{schema: Xema.new(:format, :date_time)}
    end

    test "a invalid day in date-time string", %{schema: schema} do
      data = "1990-02-31T15:59:60.123-08:00"

      assert validate(schema, data) ==
               {:error,
                %{format: :date_time, value: "1990-02-31T15:59:60.123-08:00"}}
    end
  end
end
