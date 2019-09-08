defmodule Xema.KeyValueTest do
  use ExUnit.Case

  alias Amex.KeyValue

  describe "cast/1" do
    test "with valid data" do
      assert KeyValue.cast(str: "Foo", num: 5) == {:ok, %{"str" => "Foo", "num" => 5}}
    end
  end

  describe "valid?" do
    assert KeyValue.valid?(%{"str" => "Foo", "num" => 5})
  end
end
