defmodule JsonSchemaTestSuite.Draft6.Optional.Format.UriReferenceTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of URI References| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "uri-reference"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|a valid URI|, %{schema: schema} do
      assert valid?(schema, "http://foo.bar/?baz=qux#quux")
    end

    test ~s|a valid protocol-relative URI Reference|, %{schema: schema} do
      assert valid?(schema, "//foo.bar/?baz=qux#quux")
    end

    test ~s|a valid relative URI Reference|, %{schema: schema} do
      assert valid?(schema, "/abc")
    end

    test ~s|an invalid URI Reference|, %{schema: schema} do
      refute valid?(schema, "\\\\WINDOWS\\fileshare")
    end

    test ~s|a valid URI Reference|, %{schema: schema} do
      assert valid?(schema, "abc")
    end

    test ~s|a valid URI fragment|, %{schema: schema} do
      assert valid?(schema, "#fragment")
    end

    test ~s|an invalid URI fragment|, %{schema: schema} do
      refute valid?(schema, "#frag\\ment")
    end
  end
end
