defmodule JsonSchemaTestSuite.Draft7.MaxPropertiesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|maxProperties validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"maxProperties" => 2},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|shorter is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|exact length is valid|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|too long is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "baz" => 3, "foo" => 1})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test ~s|ignores strings|, %{schema: schema} do
      assert valid?(schema, "foobar")
    end

    test ~s|ignores other non-objects|, %{schema: schema} do
      assert valid?(schema, 12)
    end
  end

  describe ~s|maxProperties = 0 means the object is empty| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"maxProperties" => 0},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|no properties is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|one property is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => 1})
    end
  end
end
