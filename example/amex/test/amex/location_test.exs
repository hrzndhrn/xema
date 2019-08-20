defmodule Xema.MapTest do
  use ExUnit.Case

  alias Amex.Location

  describe "cast/1" do
    test "with valid data" do
      assert Location.cast(city: "Berlin") == {:ok, %Location{city: "Berlin", country: nil}}
    end
  end
end
