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
      assert_raise_cast_error(schema, data, %{key: "xyz"})
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        assert_raise_cast_error(schema, data)
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
      assert_raise_cast_error(schema, data, %{key: "xyz"})
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
      assert_raise_cast_error(
        schema,
        [foo: [str: 5, num: "x"]],
        %{path: [:foo, :num], value: "x", to: :integer}
      )
    end

    test "from a map with string keys", %{schema: schema} do
      assert cast!(schema, %{"foo" => %{"str" => 6, "num" => "8"}}) == [foo: [str: "6", num: 8]]
    end

    @tag :only
    test "from a map with string keys and an invalid value", %{schema: schema} do
      assert_raise_cast_error(
        schema,
        %{"foo" => %{"str" => 6, "num" => "z"}},
        %{path: [:foo, :num], value: "z", to: :integer}
      )
    end

    test "from a map with string keys and an unknown atom", %{schema: schema} do
      assert_raise_cast_error(schema, %{"foo" => %{"str" => 6, "xyz" => "z"}}, %{
        path: [:foo],
        key: "xyz"
      })
    end

    test "from a map with atom keys", %{schema: schema} do
      assert cast!(schema, %{"foo" => %{str: 16, num: "18"}}) == [foo: [str: "16", num: 18]]
    end

    test "from a map with atom keys and an invalid value", %{schema: schema} do
      assert_raise_cast_error(
        schema,
        %{"foo" => %{"str" => 6, "num" => "z"}},
        %{path: [:foo, :num], value: "z", to: :integer}
      )
    end
  end

  defp assert_raise_cast_error(schema, value, opts \\ %{}) do
    msg = error_msg(value, opts)
    assert_raise CastError, msg, fn -> cast!(schema, value) end
  end

  defp error_msg(_, %{path: path, key: key}) do
    "cannot cast #{inspect(key)} to :keyword key at #{inspect(path)}, the atom is unknown"
  end

  defp error_msg(_, %{key: key}) do
    "cannot cast #{inspect(key)} to :keyword key, the atom is unknown"
  end

  defp error_msg(_, %{to: to, path: path, value: value}) do
    "cannot cast #{inspect(value)} to #{inspect(to)} at #{inspect(path)}"
  end

  defp error_msg(value, _) do
    "cannot cast #{inspect(value)} to :keyword"
  end
end
