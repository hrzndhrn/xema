defmodule JsonSchemaTestSuite.Draft4.AnyOf do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "anyOf" do
    setup do
      %{schema: Xema.from_json_schema(%{"anyOf" => [%{"type" => "integer"}, %{"minimum" => 2}]})}
    end

    test "first anyOf valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "second anyOf valid", %{schema: schema} do
      assert valid?(schema, 2.5)
    end

    test "both anyOf valid", %{schema: schema} do
      assert valid?(schema, 3)
    end

    test "neither anyOf valid", %{schema: schema} do
      refute valid?(schema, 1.5)
    end
  end

  describe "anyOf with base schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "anyOf" => [%{"maxLength" => 2}, %{"minLength" => 4}],
            "type" => "string"
          })
      }
    end

    test "mismatch base schema", %{schema: schema} do
      refute valid?(schema, 3)
    end

    test "one anyOf valid", %{schema: schema} do
      assert valid?(schema, "foobar")
    end

    test "both anyOf invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "anyOf complex types" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "anyOf" => [
              %{"properties" => %{"bar" => %{"type" => "integer"}}, "required" => ["bar"]},
              %{"properties" => %{"foo" => %{"type" => "string"}}, "required" => ["foo"]}
            ]
          })
      }
    end

    test "first anyOf valid (complex)", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2})
    end

    test "second anyOf valid (complex)", %{schema: schema} do
      assert valid?(schema, %{"foo" => "baz"})
    end

    test "both anyOf valid (complex)", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => "baz"})
    end

    test "neither anyOf valid (complex)", %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => 2})
    end
  end

  describe "anyOf with one empty schema" do
    setup do
      %{schema: Xema.from_json_schema(%{"anyOf" => [%{"type" => "number"}, %{}]})}
    end

    test "string is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "number is valid", %{schema: schema} do
      assert valid?(schema, 123)
    end
  end

  describe "nested anyOf, to check validation semantics" do
    setup do
      %{schema: Xema.from_json_schema(%{"anyOf" => [%{"anyOf" => [%{"type" => "null"}]}]})}
    end

    test "null is valid", %{schema: schema} do
      assert valid?(schema, nil)
    end

    test "anything non-null is invalid", %{schema: schema} do
      refute valid?(schema, 123)
    end
  end
end
