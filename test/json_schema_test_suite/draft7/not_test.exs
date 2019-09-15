defmodule JsonSchemaTestSuite.Draft7.Not do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "not" do
    setup do
      %{schema: Xema.from_json_schema(%{"not" => %{"type" => "integer"}})}
    end

    test "allowed", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "disallowed", %{schema: schema} do
      refute valid?(schema, 1)
    end
  end

  describe "not multiple types" do
    setup do
      %{schema: Xema.from_json_schema(%{"not" => %{"type" => ["integer", "boolean"]}})}
    end

    test "valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "mismatch", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "other mismatch", %{schema: schema} do
      refute valid?(schema, true)
    end
  end

  describe "not more complex schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "not" => %{"properties" => %{"foo" => %{"type" => "string"}}, "type" => "object"}
          })
      }
    end

    test "match", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "other match", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "mismatch", %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar"})
    end
  end

  describe "forbidden property" do
    setup do
      %{schema: Xema.from_json_schema(%{"properties" => %{"foo" => %{"not" => %{}}}})}
    end

    test "property present", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "property absent", %{schema: schema} do
      assert valid?(schema, %{"bar" => 1, "baz" => 2})
    end
  end

  describe "not with boolean schema true" do
    setup do
      %{schema: Xema.from_json_schema(%{"not" => true})}
    end

    test "any value is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "not with boolean schema false" do
    setup do
      %{schema: Xema.from_json_schema(%{"not" => false})}
    end

    test "any value is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end
end
