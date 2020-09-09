defmodule JsonSchemaTestSuite.Draft4.UniqueItemsTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|uniqueItems validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"uniqueItems" => true},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|unique array of integers is valid|, %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test ~s|non-unique array of integers is invalid|, %{schema: schema} do
      refute valid?(schema, [1, 1])
    end

    test ~s|numbers are unique if mathematically unequal|, %{schema: schema} do
      refute valid?(schema, [1.0, 1.0, 1])
    end

    test ~s|false is not equal to zero|, %{schema: schema} do
      assert valid?(schema, [0, false])
    end

    test ~s|true is not equal to one|, %{schema: schema} do
      assert valid?(schema, [1, true])
    end

    test ~s|unique array of objects is valid|, %{schema: schema} do
      assert valid?(schema, [%{"foo" => "bar"}, %{"foo" => "baz"}])
    end

    test ~s|non-unique array of objects is invalid|, %{schema: schema} do
      refute valid?(schema, [%{"foo" => "bar"}, %{"foo" => "bar"}])
    end

    test ~s|unique array of nested objects is valid|, %{schema: schema} do
      assert valid?(schema, [
               %{"foo" => %{"bar" => %{"baz" => true}}},
               %{"foo" => %{"bar" => %{"baz" => false}}}
             ])
    end

    test ~s|non-unique array of nested objects is invalid|, %{schema: schema} do
      refute valid?(schema, [
               %{"foo" => %{"bar" => %{"baz" => true}}},
               %{"foo" => %{"bar" => %{"baz" => true}}}
             ])
    end

    test ~s|unique array of arrays is valid|, %{schema: schema} do
      assert valid?(schema, [["foo"], ["bar"]])
    end

    test ~s|non-unique array of arrays is invalid|, %{schema: schema} do
      refute valid?(schema, [["foo"], ["foo"]])
    end

    test ~s|1 and true are unique|, %{schema: schema} do
      assert valid?(schema, [1, true])
    end

    test ~s|0 and false are unique|, %{schema: schema} do
      assert valid?(schema, [0, false])
    end

    test ~s|[1] and [true] are unique|, %{schema: schema} do
      assert valid?(schema, [[1], [true]])
    end

    test ~s|[0] and [false] are unique|, %{schema: schema} do
      assert valid?(schema, [[0], [false]])
    end

    test ~s|nested [1] and [true] are unique|, %{schema: schema} do
      assert valid?(schema, [[[1], "foo"], [[true], "foo"]])
    end

    test ~s|nested [0] and [false] are unique|, %{schema: schema} do
      assert valid?(schema, [[[0], "foo"], [[false], "foo"]])
    end

    test ~s|unique heterogeneous types are valid|, %{schema: schema} do
      assert valid?(schema, [%{}, [1], true, nil, 1, "{}"])
    end

    test ~s|non-unique heterogeneous types are invalid|, %{schema: schema} do
      refute valid?(schema, [%{}, [1], true, nil, %{}, 1])
    end

    test ~s|different objects are unique|, %{schema: schema} do
      assert valid?(schema, [%{"a" => 1, "b" => 2}, %{"a" => 2, "b" => 1}])
    end

    test ~s|objects are non-unique despite key order|, %{schema: schema} do
      refute valid?(schema, [%{"a" => 1, "b" => 2}, %{"a" => 1, "b" => 2}])
    end

    test ~s|{"a": false} and {"a": 0} are unique|, %{schema: schema} do
      assert valid?(schema, [%{"a" => false}, %{"a" => 0}])
    end

    test ~s|{"a": true} and {"a": 1} are unique|, %{schema: schema} do
      assert valid?(schema, [%{"a" => true}, %{"a" => 1}])
    end
  end

  describe ~s|uniqueItems with an array of items| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => [%{"type" => "boolean"}, %{"type" => "boolean"}], "uniqueItems" => true},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|[false, true] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [false, true])
    end

    test ~s|[true, false] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [true, false])
    end

    test ~s|[false, false] from items array is not valid|, %{schema: schema} do
      refute valid?(schema, [false, false])
    end

    test ~s|[true, true] from items array is not valid|, %{schema: schema} do
      refute valid?(schema, [true, true])
    end

    test ~s|unique array extended from [false, true] is valid|, %{schema: schema} do
      assert valid?(schema, [false, true, "foo", "bar"])
    end

    test ~s|unique array extended from [true, false] is valid|, %{schema: schema} do
      assert valid?(schema, [true, false, "foo", "bar"])
    end

    test ~s|non-unique array extended from [false, true] is not valid|, %{schema: schema} do
      refute valid?(schema, [false, true, "foo", "foo"])
    end

    test ~s|non-unique array extended from [true, false] is not valid|, %{schema: schema} do
      refute valid?(schema, [true, false, "foo", "foo"])
    end
  end

  describe ~s|uniqueItems with an array of items and additionalItems=false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalItems" => false,
              "items" => [%{"type" => "boolean"}, %{"type" => "boolean"}],
              "uniqueItems" => true
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|[false, true] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [false, true])
    end

    test ~s|[true, false] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [true, false])
    end

    test ~s|[false, false] from items array is not valid|, %{schema: schema} do
      refute valid?(schema, [false, false])
    end

    test ~s|[true, true] from items array is not valid|, %{schema: schema} do
      refute valid?(schema, [true, true])
    end

    test ~s|extra items are invalid even if unique|, %{schema: schema} do
      refute valid?(schema, [false, true, nil])
    end
  end

  describe ~s|uniqueItems=false validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"uniqueItems" => false},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|unique array of integers is valid|, %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test ~s|non-unique array of integers is valid|, %{schema: schema} do
      assert valid?(schema, [1, 1])
    end

    test ~s|numbers are unique if mathematically unequal|, %{schema: schema} do
      assert valid?(schema, [1.0, 1.0, 1])
    end

    test ~s|false is not equal to zero|, %{schema: schema} do
      assert valid?(schema, [0, false])
    end

    test ~s|true is not equal to one|, %{schema: schema} do
      assert valid?(schema, [1, true])
    end

    test ~s|unique array of objects is valid|, %{schema: schema} do
      assert valid?(schema, [%{"foo" => "bar"}, %{"foo" => "baz"}])
    end

    test ~s|non-unique array of objects is valid|, %{schema: schema} do
      assert valid?(schema, [%{"foo" => "bar"}, %{"foo" => "bar"}])
    end

    test ~s|unique array of nested objects is valid|, %{schema: schema} do
      assert valid?(schema, [
               %{"foo" => %{"bar" => %{"baz" => true}}},
               %{"foo" => %{"bar" => %{"baz" => false}}}
             ])
    end

    test ~s|non-unique array of nested objects is valid|, %{schema: schema} do
      assert valid?(schema, [
               %{"foo" => %{"bar" => %{"baz" => true}}},
               %{"foo" => %{"bar" => %{"baz" => true}}}
             ])
    end

    test ~s|unique array of arrays is valid|, %{schema: schema} do
      assert valid?(schema, [["foo"], ["bar"]])
    end

    test ~s|non-unique array of arrays is valid|, %{schema: schema} do
      assert valid?(schema, [["foo"], ["foo"]])
    end

    test ~s|1 and true are unique|, %{schema: schema} do
      assert valid?(schema, [1, true])
    end

    test ~s|0 and false are unique|, %{schema: schema} do
      assert valid?(schema, [0, false])
    end

    test ~s|unique heterogeneous types are valid|, %{schema: schema} do
      assert valid?(schema, [%{}, [1], true, nil, 1])
    end

    test ~s|non-unique heterogeneous types are valid|, %{schema: schema} do
      assert valid?(schema, [%{}, [1], true, nil, %{}, 1])
    end
  end

  describe ~s|uniqueItems=false with an array of items| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "items" => [%{"type" => "boolean"}, %{"type" => "boolean"}],
              "uniqueItems" => false
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|[false, true] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [false, true])
    end

    test ~s|[true, false] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [true, false])
    end

    test ~s|[false, false] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [false, false])
    end

    test ~s|[true, true] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [true, true])
    end

    test ~s|unique array extended from [false, true] is valid|, %{schema: schema} do
      assert valid?(schema, [false, true, "foo", "bar"])
    end

    test ~s|unique array extended from [true, false] is valid|, %{schema: schema} do
      assert valid?(schema, [true, false, "foo", "bar"])
    end

    test ~s|non-unique array extended from [false, true] is valid|, %{schema: schema} do
      assert valid?(schema, [false, true, "foo", "foo"])
    end

    test ~s|non-unique array extended from [true, false] is valid|, %{schema: schema} do
      assert valid?(schema, [true, false, "foo", "foo"])
    end
  end

  describe ~s|uniqueItems=false with an array of items and additionalItems=false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalItems" => false,
              "items" => [%{"type" => "boolean"}, %{"type" => "boolean"}],
              "uniqueItems" => false
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|[false, true] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [false, true])
    end

    test ~s|[true, false] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [true, false])
    end

    test ~s|[false, false] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [false, false])
    end

    test ~s|[true, true] from items array is valid|, %{schema: schema} do
      assert valid?(schema, [true, true])
    end

    test ~s|extra items are invalid even if unique|, %{schema: schema} do
      refute valid?(schema, [false, true, nil])
    end
  end
end
