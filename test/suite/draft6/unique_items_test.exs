defmodule Suite.Draft6.UniqueItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "unique_items validation" do
    setup do
      %{schema: Xema.new(:unique_items, true)}
    end

    test "unique array of integers is valie", %{schema: schema} do
      data = [1, 2]

      assert is_valid?(schema, data)
    end
  end
end
