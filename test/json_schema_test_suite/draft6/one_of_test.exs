defmodule JsonSchemaTestSuite.Draft6.OneOf do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "oneOf" do
    setup do
      %{schema: Xema.from_json_schema(%{"oneOf" => [%{"type" => "integer"}, %{"minimum" => 2}]})}
    end

    test "first oneOf valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "second oneOf valid", %{schema: schema} do
      assert valid?(schema, 2.5)
    end

    test "both oneOf valid", %{schema: schema} do
      refute valid?(schema, 3)
    end

    test "neither oneOf valid", %{schema: schema} do
      refute valid?(schema, 1.5)
    end
  end

  describe "oneOf with base schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "oneOf" => [%{"minLength" => 2}, %{"maxLength" => 4}],
            "type" => "string"
          })
      }
    end

    test "mismatch base schema", %{schema: schema} do
      refute valid?(schema, 3)
    end

    test "one oneOf valid", %{schema: schema} do
      assert valid?(schema, "foobar")
    end

    test "both oneOf valid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "oneOf with boolean schemas, all true" do
    setup do
      %{schema: Xema.from_json_schema(%{"oneOf" => [true, true, true]})}
    end

    test "any value is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "oneOf with boolean schemas, one true" do
    setup do
      %{schema: Xema.from_json_schema(%{"oneOf" => [true, false, false]})}
    end

    test "any value is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end

  describe "oneOf with boolean schemas, more than one true" do
    setup do
      %{schema: Xema.from_json_schema(%{"oneOf" => [true, true, false]})}
    end

    test "any value is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "oneOf with boolean schemas, all false" do
    setup do
      %{schema: Xema.from_json_schema(%{"oneOf" => [false, false, false]})}
    end

    test "any value is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "oneOf complex types" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "oneOf" => [
              %{"properties" => %{"bar" => %{"type" => "integer"}}, "required" => ["bar"]},
              %{"properties" => %{"foo" => %{"type" => "string"}}, "required" => ["foo"]}
            ]
          })
      }
    end

    test "first oneOf valid (complex)", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2})
    end

    test "second oneOf valid (complex)", %{schema: schema} do
      assert valid?(schema, %{"foo" => "baz"})
    end

    test "both oneOf valid (complex)", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => "baz"})
    end

    test "neither oneOf valid (complex)", %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => 2})
    end
  end

  describe "oneOf with empty schema" do
    setup do
      %{schema: Xema.from_json_schema(%{"oneOf" => [%{"type" => "number"}, %{}]})}
    end

    test "one valid - valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "both valid - invalid", %{schema: schema} do
      refute valid?(schema, 123)
    end
  end

  describe "oneOf with required" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "oneOf" => [%{"required" => ["foo", "bar"]}, %{"required" => ["foo", "baz"]}],
            "type" => "object"
          })
      }
    end

    test "both invalid - invalid", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test "first valid - valid", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "second valid - valid", %{schema: schema} do
      assert valid?(schema, %{"baz" => 3, "foo" => 1})
    end

    test "both valid - invalid", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "baz" => 3, "foo" => 1})
    end
  end
end