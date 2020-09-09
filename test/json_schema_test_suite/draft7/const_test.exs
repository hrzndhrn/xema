defmodule JsonSchemaTestSuite.Draft7.ConstTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|const validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => 2},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|same value is valid|, %{schema: schema} do
      assert valid?(schema, 2)
    end

    test ~s|another value is invalid|, %{schema: schema} do
      refute valid?(schema, 5)
    end

    test ~s|another type is invalid|, %{schema: schema} do
      refute valid?(schema, "a")
    end
  end

  describe ~s|const with object| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => %{"baz" => "bax", "foo" => "bar"}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|same object is valid|, %{schema: schema} do
      assert valid?(schema, %{"baz" => "bax", "foo" => "bar"})
    end

    test ~s|same object with different property order is valid|, %{schema: schema} do
      assert valid?(schema, %{"baz" => "bax", "foo" => "bar"})
    end

    test ~s|another object is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar"})
    end

    test ~s|another type is invalid|, %{schema: schema} do
      refute valid?(schema, [1, 2])
    end
  end

  describe ~s|const with array| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => [%{"foo" => "bar"}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|same array is valid|, %{schema: schema} do
      assert valid?(schema, [%{"foo" => "bar"}])
    end

    test ~s|another array item is invalid|, %{schema: schema} do
      refute valid?(schema, [2])
    end

    test ~s|array with additional items is invalid|, %{schema: schema} do
      refute valid?(schema, [1, 2, 3])
    end
  end

  describe ~s|const with null| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => nil},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|null is valid|, %{schema: schema} do
      assert valid?(schema, nil)
    end

    test ~s|not null is invalid|, %{schema: schema} do
      refute valid?(schema, 0)
    end
  end

  describe ~s|const with false does not match 0| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => false},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|false is valid|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|integer zero is invalid|, %{schema: schema} do
      refute valid?(schema, 0)
    end

    test ~s|float zero is invalid|, %{schema: schema} do
      refute valid?(schema, 0.0)
    end
  end

  describe ~s|const with true does not match 1| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => true},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|true is valid|, %{schema: schema} do
      assert valid?(schema, true)
    end

    test ~s|integer one is invalid|, %{schema: schema} do
      refute valid?(schema, 1)
    end

    test ~s|float one is invalid|, %{schema: schema} do
      refute valid?(schema, 1.0)
    end
  end

  describe ~s|const with [false] does not match [0]| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => [false]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|[false] is valid|, %{schema: schema} do
      assert valid?(schema, [false])
    end

    test ~s|[0] is invalid|, %{schema: schema} do
      refute valid?(schema, [0])
    end

    test ~s|[0.0] is invalid|, %{schema: schema} do
      refute valid?(schema, [0.0])
    end
  end

  describe ~s|const with [true] does not match [1]| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => [true]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|[true] is valid|, %{schema: schema} do
      assert valid?(schema, [true])
    end

    test ~s|[1] is invalid|, %{schema: schema} do
      refute valid?(schema, [1])
    end

    test ~s|[1.0] is invalid|, %{schema: schema} do
      refute valid?(schema, [1.0])
    end
  end

  describe ~s|const with {"a": false} does not match {"a": 0}| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => %{"a" => false}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|{"a": false} is valid|, %{schema: schema} do
      assert valid?(schema, %{"a" => false})
    end

    test ~s|{"a": 0} is invalid|, %{schema: schema} do
      refute valid?(schema, %{"a" => 0})
    end

    test ~s|{"a": 0.0} is invalid|, %{schema: schema} do
      refute valid?(schema, %{"a" => 0.0})
    end
  end

  describe ~s|const with {"a": true} does not match {"a": 1}| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => %{"a" => true}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|{"a": true} is valid|, %{schema: schema} do
      assert valid?(schema, %{"a" => true})
    end

    test ~s|{"a": 1} is invalid|, %{schema: schema} do
      refute valid?(schema, %{"a" => 1})
    end

    test ~s|{"a": 1.0} is invalid|, %{schema: schema} do
      refute valid?(schema, %{"a" => 1.0})
    end
  end

  describe ~s|const with 0 does not match other zero-like types| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => 0},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|false is invalid|, %{schema: schema} do
      refute valid?(schema, false)
    end

    test ~s|integer zero is valid|, %{schema: schema} do
      assert valid?(schema, 0)
    end

    test ~s|float zero is valid|, %{schema: schema} do
      assert valid?(schema, 0.0)
    end

    test ~s|empty object is invalid|, %{schema: schema} do
      refute valid?(schema, %{})
    end

    test ~s|empty array is invalid|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|empty string is invalid|, %{schema: schema} do
      refute valid?(schema, "")
    end
  end

  describe ~s|const with 1 does not match true| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => 1},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|true is invalid|, %{schema: schema} do
      refute valid?(schema, true)
    end

    test ~s|integer one is valid|, %{schema: schema} do
      assert valid?(schema, 1)
    end

    test ~s|float one is valid|, %{schema: schema} do
      assert valid?(schema, 1.0)
    end
  end

  describe ~s|const with -2.0 matches integer and float types| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => -2.0},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|integer -2 is valid|, %{schema: schema} do
      assert valid?(schema, -2)
    end

    test ~s|integer 2 is invalid|, %{schema: schema} do
      refute valid?(schema, 2)
    end

    test ~s|float -2.0 is valid|, %{schema: schema} do
      assert valid?(schema, -2.0)
    end

    test ~s|float 2.0 is invalid|, %{schema: schema} do
      refute valid?(schema, 2.0)
    end

    test ~s|float -2.00001 is invalid|, %{schema: schema} do
      refute valid?(schema, -2.00001)
    end
  end

  describe ~s|float and integers are equal up to 64-bit representation limits| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => 9_007_199_254_740_992},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|integer is valid|, %{schema: schema} do
      assert valid?(schema, 9_007_199_254_740_992)
    end

    test ~s|integer minus one is invalid|, %{schema: schema} do
      refute valid?(schema, 9_007_199_254_740_991)
    end

    test ~s|float is valid|, %{schema: schema} do
      assert valid?(schema, 9_007_199_254_740_992.0)
    end

    test ~s|float minus one is invalid|, %{schema: schema} do
      refute valid?(schema, 9_007_199_254_740_991.0)
    end
  end

  describe ~s|nul characters in strings| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"const" => <<104, 101, 108, 108, 111, 0, 116, 104, 101, 114, 101>>},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|match string with nul|, %{schema: schema} do
      assert valid?(schema, <<104, 101, 108, 108, 111, 0, 116, 104, 101, 114, 101>>)
    end

    test ~s|do not match string lacking nul|, %{schema: schema} do
      refute valid?(schema, "hellothere")
    end
  end
end
