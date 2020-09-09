defmodule JsonSchemaTestSuite.Draft6.BooleanSchemaTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|boolean schema 'true'| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            true,
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|number is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|string is valid|, %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test ~s|boolean true is valid|, %{schema: schema} do
      assert valid?(schema, true)
    end

    test ~s|boolean false is valid|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|null is valid|, %{schema: schema} do
      assert valid?(schema, nil)
    end

    test ~s|object is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => "bar"})
    end

    test ~s|empty object is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|array is valid|, %{schema: schema} do
      assert valid?(schema, ["foo"])
    end

    test ~s|empty array is valid|, %{schema: schema} do
      assert valid?(schema, [])
    end
  end

  describe ~s|boolean schema 'false'| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            false,
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|number is invalid|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|string is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|boolean true is invalid|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|boolean false is invalid|, %{schema: schema} do
      refute valid?(schema, false)
    end

    test ~s|null is invalid|, %{schema: schema} do
      refute valid?(schema, nil)
    end

    test ~s|object is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar"})
    end

    test ~s|empty object is invalid|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|array is invalid|, %{schema: schema} do
      refute valid?(schema, ["foo"])
    end

    test ~s|empty array is invalid|, %{schema: schema} do
      refute valid?(schema, [])
    end
  end
end
