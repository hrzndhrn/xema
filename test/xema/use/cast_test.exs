defmodule Xema.Use.CastTest do
  use ExUnit.Case, async: true

  describe "struct with nested DateTime" do
    # Issue: https://github.com/hrzndhrn/xema/issues/157

    defmodule Bar do
      use Xema

      defstruct [:time]

      xema do
        strux(
          module: Bar,
          properties: %{time: strux(DateTime)}
        )
      end
    end

    test "cast!/1 from a map with atom keys" do
      {:ok, datetime, 0} = DateTime.from_iso8601("1984-03-04 13:37:00.000000Z")

      assert Bar.cast!(%{time: "1984-03-04 13:37:00.000000Z"}) ==
        %Bar{time: datetime}
    end

    test "cast!/1 from a map with string keys" do
      {:ok, datetime, 0} = DateTime.from_iso8601("1984-03-04 13:37:00.000000Z")

      assert Bar.cast!(%{"time" => "1984-03-04 13:37:00.000000Z"}) ==
        %Bar{time: datetime}
    end
  end
end
