defmodule JsonSchemaTestSuite.Draft4.RequiredTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|required validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"bar" => %{}, "foo" => %{}}, "required" => ["foo"]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|present required property is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|non-present required property is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 1})
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

  describe ~s|required default validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"foo" => %{}}},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|not required by default|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe ~s|required with escaped characters| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "required" => [
                "foo\nbar",
                "foo\"bar",
                "foo\\bar",
                "foo\rbar",
                "foo\tbar",
                "foo\fbar"
              ]
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|object with all properties present is valid|, %{schema: schema} do
      assert valid?(schema, %{
               "foo\tbar" => 1,
               "foo\nbar" => 1,
               "foo\fbar" => 1,
               "foo\rbar" => 1,
               "foo\"bar" => 1,
               "foo\\bar" => 1
             })
    end

    test ~s|object with some properties missing is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo\nbar" => "1", "foo\"bar" => "1"})
    end
  end
end
