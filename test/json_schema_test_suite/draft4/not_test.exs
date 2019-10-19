defmodule JsonSchemaTestSuite.Draft4.NotTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "not" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"not" => %{"type" => "integer"}},
            draft: "draft4"
          )
      }
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
      %{
        schema:
          Xema.from_json_schema(
            %{"not" => %{"type" => ["integer", "boolean"]}},
            draft: "draft4"
          )
      }
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
          Xema.from_json_schema(
            %{"not" => %{"properties" => %{"foo" => %{"type" => "string"}}, "type" => "object"}},
            draft: "draft4"
          )
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
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"foo" => %{"not" => %{}}}},
            draft: "draft4"
          )
      }
    end

    test "property present", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test "property absent", %{schema: schema} do
      assert valid?(schema, %{"bar" => 1, "baz" => 2})
    end
  end
end
