defmodule Draft7.Optional.Format.UriReferenceTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "validation of URI References" do
    setup do
      %{schema: Xema.new(:format, :uri_reference)}
    end

    test "a valid URI", %{schema: schema} do
      data = "http://foo.bar/?baz=qux#quux"
      assert is_valid?(schema, data)
    end

    test "a valid protocol-relative URI Reference", %{schema: schema} do
      data = "//foo.bar/?baz=qux#quux"
      assert is_valid?(schema, data)
    end

    test "a valid relative URI Reference", %{schema: schema} do
      data = "/abc"
      assert is_valid?(schema, data)
    end

    test "an invalid URI Reference", %{schema: schema} do
      data = "\\\\WINDOWS\\fileshare"
      refute is_valid?(schema, data)
    end

    test "a valid URI Reference", %{schema: schema} do
      data = "abc"
      assert is_valid?(schema, data)
    end

    test "a valid URI fragment", %{schema: schema} do
      data = "#fragment"
      assert is_valid?(schema, data)
    end

    test "an invalid URI fragment", %{schema: schema} do
      data = "#frag\\ment"
      refute is_valid?(schema, data)
    end
  end
end
