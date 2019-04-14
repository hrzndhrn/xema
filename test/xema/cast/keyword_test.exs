defmodule Xema.Cast.KeywordTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  alias Xema.CastError

  @set [:atom, "str", 1.1, 1, [4], {:tuple}]

  #
  # Xema.cast/2
  #

  describe "cast/2 with a minimal keyword schema" do
    setup do
      %{
        schema: Xema.new(:keyword)
      }
    end

    test "from an empty list", %{schema: schema} do
      data = []
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a keyword list", %{schema: schema} do
      data = [foo: 42]
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{foo: 42}
      expected = [foo: 42]
      assert validate(schema, data) == {:error, %{type: :keyword, value: data}}
      assert cast(schema, data) == {:ok, expected}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"foo" => 42}
      expected = [foo: 42]
      assert cast(schema, data) == {:ok, expected}
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 55}
      expected = {:error, CastError.exception(%{key: "xyz", path: [], to: :keyword})}

      assert cast(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :keyword, value: data})}

        assert cast(schema, data) == expected
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast(schema, ~r/.*/)
      end)
    end
  end

  describe "cast/2 with a keyword schema" do
    setup do
      %{schema: Xema.new({:keyword, properties: %{str: :string, num: :integer}})}
    end

    test "from an empty list", %{schema: schema} do
      data = []
      assert cast(schema, data) == {:ok, data}
    end

    @tag :only
    test "from a keyword list", %{schema: schema} do
      data = [foo: 42, str: "foo"]
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a keyword list with castable values", %{schema: schema} do
      assert cast(schema, str: 5, num: "6") == {:ok, [str: "5", num: 6]}
    end

    test "from a map with string keys", %{schema: schema} do
      assert {:ok, cast} = cast(schema, %{"foo" => 42, "str" => 6, "num" => "4"})
      assert Keyword.equal?(cast, foo: 42, str: "6", num: 4)
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 55}
      expected = {:error, CastError.exception(%{key: "xyz", path: [], to: :keyword})}

      assert cast(schema, data) == expected
    end

    test "from a map with atom keys", %{schema: schema} do
      assert {:ok, cast} = cast(schema, %{foo: 42, str: 6, num: "4"})
      assert Keyword.equal?(cast, foo: 42, str: "6", num: 4)
    end
  end

  describe "cast/2 with a nested keyword schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             properties: %{
               foo: {
                 :keyword,
                 properties: %{str: :string, num: :integer}
               }
             }}
          )
      }
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, foo: [str: 5, num: "7"]) == {:ok, [foo: [str: "5", num: 7]]}
    end

    test "from a keyword list with an invalid value", %{schema: schema} do
      data = [foo: [str: 5, num: "x"]]
      expected = {:error, CastError.exception(%{path: [:foo, :num], to: :integer, value: "x"})}

      assert cast(schema, data) == expected
    end

    test "from a map with string keys", %{schema: schema} do
      assert cast(schema, %{"foo" => %{"str" => 6, "num" => "8"}}) ==
               {:ok, [foo: [str: "6", num: 8]]}
    end

    test "from a map with string keys and an invalid value", %{schema: schema} do
      data = %{"foo" => %{"str" => 6, "num" => "z"}}
      expected = {:error, CastError.exception(%{path: [:foo, :num], to: :integer, value: "z"})}

      assert cast(schema, data) == expected
    end

    test "from a map with string keys and an unknown atom", %{schema: schema} do
      data = %{"foo" => %{"str" => 6, "xyz" => "z"}}
      expected = {:error, CastError.exception(%{path: [:foo], to: :keyword, key: "xyz"})}

      assert cast(schema, data) == expected
    end

    test "from a map with atom keys", %{schema: schema} do
      assert cast(schema, %{"foo" => %{str: 16, num: "18"}}) ==
               {:ok, [foo: [str: "16", num: 18]]}
    end

    test "from a map with atom keys and an invalid value", %{schema: schema} do
      data = %{"foo" => %{"str" => 6, "num" => "z"}}
      expected = {:error, CastError.exception(%{path: [:foo, :num], to: :integer, value: "z"})}

      assert cast(schema, data) == expected
    end
  end

  #
  # Xema.cast/2
  #

  describe "cast!/2 with a minimal keyword schema" do
    setup do
      %{
        schema: Xema.new(:keyword)
      }
    end

    test "from an empty list", %{schema: schema} do
      data = []
      assert cast!(schema, data) == data
    end

    test "from a keyword list", %{schema: schema} do
      data = [foo: 42]
      assert cast!(schema, data) == data
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{foo: 42}
      expected = [foo: 42]
      assert cast!(schema, data) == expected
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"foo" => 42}
      expected = [foo: 42]
      assert cast!(schema, data) == expected
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 55}
      msg = ~s|cannot cast "xyz" to :keyword key, the atom is unknown|

      assert_raise CastError, msg, fn -> cast!(schema, data) end
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :keyword"
        assert_raise CastError, msg, fn -> cast!(schema, data) end
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end
  end

  describe "cast!/2 with a keyword schema" do
    setup do
      %{
        schema: Xema.new({:keyword, properties: %{str: :string, num: :integer}})
      }
    end

    test "from an empty list", %{schema: schema} do
      data = []
      assert cast!(schema, data) == data
    end

    test "from a keyword list", %{schema: schema} do
      data = [foo: 42, str: "foo"]
      assert cast!(schema, data) == data
    end

    test "from a keyword list with castable values", %{schema: schema} do
      assert cast!(schema, str: 5, num: "6") == [str: "5", num: 6]
    end

    test "from a map with string keys", %{schema: schema} do
      assert cast = cast!(schema, %{"foo" => 42, "str" => 6, "num" => "4"})
      assert Keyword.equal?(cast, foo: 42, str: "6", num: 4)
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 55}
      msg = ~s|cannot cast "xyz" to :keyword key, the atom is unknown|

      assert_raise CastError, msg, fn -> cast!(schema, data) end
    end

    test "from a map with atom keys", %{schema: schema} do
      assert cast = cast!(schema, %{foo: 42, str: 6, num: "4"})
      assert Keyword.equal?(cast, foo: 42, str: "6", num: 4)
    end
  end

  describe "cast!/2 with a nested keyword schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             properties: %{
               foo: {
                 :keyword,
                 properties: %{str: :string, num: :integer}
               }
             }}
          )
      }
    end

    test "from a keyword list", %{schema: schema} do
      assert cast!(schema, foo: [str: 5, num: "7"]) == [foo: [str: "5", num: 7]]
    end

    test "from a keyword list with an invalid value", %{schema: schema} do
      data = [foo: [str: 5, num: "x"]]
      msg = ~s|cannot cast "x" to :integer at [:foo, :num]|

      assert_raise CastError, msg, fn -> cast!(schema, data) end
    end

    test "from a map with string keys", %{schema: schema} do
      assert cast!(schema, %{"foo" => %{"str" => 6, "num" => "8"}}) == [foo: [str: "6", num: 8]]
    end

    test "from a map with string keys and an invalid value", %{schema: schema} do
      data = %{"foo" => %{"str" => 6, "num" => "z"}}
      msg = ~s|cannot cast "z" to :integer at [:foo, :num]|

      assert_raise CastError, msg, fn -> cast!(schema, data) end
    end

    test "from a map with string keys and an unknown atom", %{schema: schema} do
      data = %{"foo" => %{"str" => 6, "xyz" => "z"}}
      msg = ~s|cannot cast "xyz" to :keyword key at [:foo], the atom is unknown|

      assert_raise CastError, msg, fn -> cast!(schema, data) end
    end

    test "from a map with atom keys", %{schema: schema} do
      assert cast!(schema, %{"foo" => %{str: 16, num: "18"}}) == [foo: [str: "16", num: 18]]
    end

    test "from a map with atom keys and an invalid value", %{schema: schema} do
      data = %{"foo" => %{"str" => 6, "num" => "z"}}
      msg = ~s|cannot cast "z" to :integer at [:foo, :num]|

      assert_raise CastError, msg, fn -> cast!(schema, data) end
    end
  end
end
