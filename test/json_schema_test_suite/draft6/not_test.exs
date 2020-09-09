defmodule JsonSchemaTestSuite.Draft6.NotTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|not| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"not" => %{"type" => "integer"}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|allowed|, %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test ~s|disallowed|, %{schema: schema} do
      refute valid?(schema, 1)
    end
  end

  describe ~s|not multiple types| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"not" => %{"type" => ["integer", "boolean"]}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|valid|, %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test ~s|mismatch|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|other mismatch|, %{schema: schema} do
      refute valid?(schema, true)
    end
  end

  describe ~s|not more complex schema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"not" => %{"properties" => %{"foo" => %{"type" => "string"}}, "type" => "object"}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|match|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|other match|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|mismatch|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar"})
    end
  end

  describe ~s|forbidden property| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"foo" => %{"not" => %{}}}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|property present|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|property absent|, %{schema: schema} do
      assert valid?(schema, %{"bar" => 1, "baz" => 2})
    end
  end

  describe ~s|not with boolean schema true| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"not" => true},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|any value is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe ~s|not with boolean schema false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"not" => false},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|any value is valid|, %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end
end
