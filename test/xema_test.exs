defmodule XemaTest do

  use ExUnit.Case, async: true

  alias Xema
  import Xema, only: [is_valid?: 2]

  test "any schema" do
    schema = Xema.create()
    assert is_valid?(schema, "foo")
    assert is_valid?(schema, 1)
    assert is_valid?(schema, %{bla: 1})
  end

  describe "string schema" do
    test "simple string schema" do
      schema = Xema.create(:string)
      assert is_valid?(schema, "foo")
      refute is_valid?(schema, 1)
    end
  end
end
