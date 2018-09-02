defmodule Draft7.Optional.Format.EmailTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "validation of e-mail addresses" do
    setup do
      %{schema: Xema.new(:format, :email)}
    end

    test "a valid e-mail address", %{schema: schema} do
      data = "joe.bloggs@example.com"
      assert is_valid?(schema, data)
    end

    test "an invalid e-mail address", %{schema: schema} do
      data = "2962"
      refute is_valid?(schema, data)
    end
  end
end
