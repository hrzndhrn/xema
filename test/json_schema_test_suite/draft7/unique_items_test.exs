defmodule JsonSchemaTestSuite.Draft7.UniqueItems do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "uniqueItems validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"uniqueItems" => true})}
    end

    test "unique array of integers is valid", %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test "non-unique array of integers is invalid", %{schema: schema} do
      refute valid?(schema, [1, 1])
    end

    test "numbers are unique if mathematically unequal", %{schema: schema} do
      refute valid?(schema, [1.0, 1.0, 1])
    end

    test "false is not equal to zero", %{schema: schema} do
      assert valid?(schema, [0, false])
    end

    test "true is not equal to one", %{schema: schema} do
      assert valid?(schema, [1, true])
    end

    test "unique array of objects is valid", %{schema: schema} do
      assert valid?(schema, [%{"foo" => "bar"}, %{"foo" => "baz"}])
    end

    test "non-unique array of objects is invalid", %{schema: schema} do
      refute valid?(schema, [%{"foo" => "bar"}, %{"foo" => "bar"}])
    end

    test "unique array of nested objects is valid", %{schema: schema} do
      assert valid?(schema, [
               %{"foo" => %{"bar" => %{"baz" => true}}},
               %{"foo" => %{"bar" => %{"baz" => false}}}
             ])
    end

    test "non-unique array of nested objects is invalid", %{schema: schema} do
      refute valid?(schema, [
               %{"foo" => %{"bar" => %{"baz" => true}}},
               %{"foo" => %{"bar" => %{"baz" => true}}}
             ])
    end

    test "unique array of arrays is valid", %{schema: schema} do
      assert valid?(schema, [["foo"], ["bar"]])
    end

    test "non-unique array of arrays is invalid", %{schema: schema} do
      refute valid?(schema, [["foo"], ["foo"]])
    end

    test "1 and true are unique", %{schema: schema} do
      assert valid?(schema, [1, true])
    end

    test "0 and false are unique", %{schema: schema} do
      assert valid?(schema, [0, false])
    end

    test "unique heterogeneous types are valid", %{schema: schema} do
      assert valid?(schema, [%{}, [1], true, nil, 1])
    end

    test "non-unique heterogeneous types are invalid", %{schema: schema} do
      refute valid?(schema, [%{}, [1], true, nil, %{}, 1])
    end
  end
end
