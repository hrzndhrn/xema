defmodule Xema.MapzTest do
  use ExUnit.Case

  alias Xema.Mapz

  doctest Xema.Mapz

  test "get/2 raises RuntimeError for duplicated keys" do
    expected = "Map contains same key as string and atom (key: :a)."

    assert_raise RuntimeError, expected, fn ->
      Mapz.get(%{:a => 1, "a" => 2}, :a)
    end
  end
end
