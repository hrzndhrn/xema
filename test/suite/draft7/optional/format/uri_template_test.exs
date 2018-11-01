defmodule Draft7.Optional.Format.UriTemplateTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "format: uri-template" do
    setup do
      %{schema: Xema.new(format: :uri_template)}
    end

    test "a valid uri-template", %{schema: schema} do
      data = "http://example.com/dictionary/{term:1}/{term}"
      assert valid?(schema, data)
    end

    test "an invalid uri-template", %{schema: schema} do
      data = "http://example.com/dictionary/{term:1}/{term"
      refute valid?(schema, data)
    end

    test "a valid uri-template without variables", %{schema: schema} do
      data = "http://example.com/dictionary"
      assert valid?(schema, data)
    end

    test "a valid relative uri-template", %{schema: schema} do
      data = "dictionary/{term:1}/{term}"
      assert valid?(schema, data)
    end
  end
end
