defmodule JsonSchemaTestSuite.Draft4.MinPropertiesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|minProperties validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"minProperties" => 1},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|longer is valid|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|exact length is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|too short is invalid|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores strings|, %{schema: schema} do
      assert valid?(schema, "")
    end

    test ~s|ignores other non-objects|, %{schema: schema} do
      assert valid?(schema, 12)
    end
  end
end
