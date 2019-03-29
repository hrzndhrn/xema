defmodule Xema.Cast.MapTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  alias Xema.CastError

  @set [1, 1.1, [42], {:tuple}, :atom]

  #
  # Xema.cast/2
  #

  describe "cast/2 with a minimal map schema" do
    setup do
      %{
        schema: Xema.new(:map)
      }
    end

    test "from an empty map", %{schema: schema} do
      data = %{}
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{bla: "foo"}
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"bla" => "foo"}
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, foo: 6) == {:ok, %{foo: 6}}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        assert cast(schema, data) ==
                 {:error, %{path: [], to: :map, value: data}}
      end)
    end
  end

  describe "cast/2 with a map schema and [keys: :atoms]" do
    setup do
      %{
        schema: Xema.new({:map, keys: :atoms})
      }
    end

    test "from a map with known atom", %{schema: schema} do
      _ = String.to_atom("zzz")
      assert cast(schema, %{"zzz" => "z"}) == {:ok, %{zzz: "z"}}
    end

    test "from a map with unknown atom", %{schema: schema} do
      assert cast(schema, %{"xyz" => "z"}) ==
               {:error, %{path: [], to: :map, key: "xyz"}}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, foo: 6) == {:ok, %{foo: 6}}
    end
  end

  describe "cast/2 with a map schema and [keys: :strings]" do
    setup do
      %{
        schema: Xema.new({:map, keys: :strings})
      }
    end

    test "from a map with atom keys", %{schema: schema} do
      assert cast(schema, %{abc: 55, zzz: "z"}) ==
               {:ok, %{"abc" => 55, "zzz" => "z"}}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"abc" => 55, "zzz" => "z"}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, foo: 6) == {:ok, %{"foo" => 6}}
    end
  end

  describe "cast/2 with a map schema, [keys: :atoms] and properties" do
    setup do
      %{
        schema: Xema.new({:map, keys: :atoms, properties: %{bla: :string}})
      }
    end

    test "from map with string keys and valid property", %{schema: schema} do
      data = %{"bla" => "foo"}
      assert validate(schema, data) == {:error, %{keys: :atoms}}
      assert cast(schema, data) == {:ok, %{bla: "foo"}}
    end

    test "from map with string keys and integer property", %{schema: schema} do
      data = %{"bla" => 11}
      assert validate(schema, data) == {:error, %{keys: :atoms}}

      assert {:ok, cast} = cast(schema, data)
      assert cast == %{bla: "11"}

      assert validate(schema, cast) == :ok
    end

    test "from map with atom keys and string property", %{schema: schema} do
      data = %{bla: "foo"}
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from map with atom keys and a castable value", %{schema: schema} do
      data = %{bla: 11}

      assert validate(schema, data) ==
               {:error, %{properties: %{bla: %{type: :string, value: 11}}}}

      assert {:ok, cast} = cast(schema, data)
      assert cast == %{bla: "11"}

      assert validate(schema, cast) == :ok
    end

    test "from a map with unknown atom", %{schema: schema} do
      assert cast(schema, %{"xyz" => "z"}) ==
               {:error, %{path: [], key: "xyz", to: :map}}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, foo: 6) == {:ok, %{foo: 6}}
    end
  end

  describe "cast/2 with a map schema, [keys: :strings] and properties" do
    setup do
      %{
        schema: Xema.new({:map, keys: :strings, properties: %{"bla" => :string}})
      }
    end

    test "from map with string keys", %{schema: schema} do
      data = %{"bla" => "foo"}
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, %{"bla" => "foo"}}
    end

    test "from map with string keys and castable value", %{schema: schema} do
      data = %{"bla" => 11}

      assert validate(schema, data) ==
               {:error, %{properties: %{"bla" => %{type: :string, value: 11}}}}

      assert cast(schema, data) == {:ok, %{"bla" => "11"}}
    end

    test "from map with atoms keys", %{schema: schema} do
      data = %{bla: "foo"}
      assert validate(schema, data) == {:error, %{keys: :strings}}
      assert cast(schema, data) == {:ok, %{"bla" => "foo"}}
    end

    test "from map with atom keys and castable value", %{schema: schema} do
      data = %{bla: 11}

      assert validate(schema, data) == {:error, %{keys: :strings}}

      assert cast(schema, data) == {:ok, %{"bla" => "11"}}
    end

    test "from a map with additional property", %{schema: schema} do
      assert cast(schema, %{bla: 42, foo: 11}) == {:ok, %{"bla" => "42", "foo" => 11}}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, bla: 6, foo: 11) == {:ok, %{"bla" => "6", "foo" => 11}}
    end
  end

  describe "cast/2 with a nested map schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             keys: :atoms,
             properties: %{
               foo:
                 {:map,
                  keys: :atoms,
                  properties: %{
                    num: {:integer, maximum: 12},
                    bar:
                      {:map,
                       keys: :atoms,
                       properties: %{
                         num: {:integer, maximum: 12}
                       }}
                  }}
             }}
          )
      }
    end

    test "from a valid map", %{schema: schema} do
      data = %{"foo" => %{"num" => 2}}
      expected = {:ok, %{foo: %{num: 2}}}

      assert cast(schema, data) == expected
    end

    test "from a map with unknown key", %{schema: schema} do
      data = %{"foo" => %{"xyz" => 42}}
      expected = {:error, %{path: [:foo], key: "xyz", to: :map}}

      assert cast(schema, data) == expected
    end

    test "from a map with unknown key (deeper)", %{schema: schema} do
      data = %{"foo" => %{"bar" => %{"xyz" => 42}}}
      expected = {:error, %{path: [:foo, :bar], key: "xyz", to: :map}}

      assert cast(schema, data) == expected
    end

    test "from an invalid map", %{schema: schema} do
      data = %{"foo" => %{"num" => "42"}}

      assert {:ok, cast} = cast(schema, data)
      assert cast == %{foo: %{num: 42}}

      assert validate(schema, cast) ==
               {:error,
                %{
                  properties: %{
                    foo: %{properties: %{num: %{value: 42, maximum: 12}}}
                  }
                }}
    end

    test "from a keyword list nested in a map", %{schema: schema} do
      data = %{"foo" => [num: 2]}
      expected = {:ok, %{foo: %{num: 2}}}

      assert cast(schema, data) == expected
    end

    test "from nested keyword lists", %{schema: schema} do
      data = [foo: [num: 2]]
      expected = {:ok, %{foo: %{num: 2}}}

      assert cast(schema, data) == expected
    end
  end

  describe "cast/2 with an integer property" do
    setup do
      %{
        schema: Xema.new(properties: %{num: :integer})
      }
    end

    test "with a valid value", %{schema: schema} do
      assert cast(schema, %{num: "77"}) == {:ok, %{num: 77}}
    end

    test "with a valid value from a keyword list", %{schema: schema} do
      assert cast(schema, num: "77") == {:ok, %{num: 77}}
    end

    test "with an invalid value", %{schema: schema} do
      assert cast(schema, %{num: "77."}) ==
               {:error, %{path: [:num], to: :integer, value: "77."}}
    end

    test "with an invalid value from a keyword list", %{schema: schema} do
      assert cast(schema, num: "77.") ==
               {:error, %{path: [:num], to: :integer, value: "77."}}
    end
  end

  #
  # Xema.cast!/2
  #

  describe "cast!/2 with a minimal map schema" do
    setup do
      %{
        schema: Xema.new(:map)
      }
    end

    test "from an empty map", %{schema: schema} do
      data = %{}
      assert cast!(schema, data) == data
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{bla: "foo"}
      assert cast!(schema, data) == data
    end

    test "from a map with key strings", %{schema: schema} do
      data = %{"bla" => "foo"}
      assert cast!(schema, data) == data
    end

    test "from a keyword list", %{schema: schema} do
      assert cast!(schema, foo: 5) == %{foo: 5}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data -> assert_raise_cast_error(schema, data) end)
    end
  end

  describe "cast!/2 with a map schema and [keys: :atoms]" do
    setup do
      %{
        schema: Xema.new({:map, keys: :atoms})
      }
    end

    test "from a map with known atom", %{schema: schema} do
      _ = String.to_atom("zzz")
      assert cast!(schema, %{"zzz" => "z"}) == %{zzz: "z"}
    end

    test "from a map with unknown atom", %{schema: schema} do
      assert_raise_cast_error(schema, %{"xyz" => "z"}, %{key: "xyz"})
    end

    test "from a keyword list", %{schema: schema} do
      assert cast!(schema, foo: 7) == %{foo: 7}
    end
  end

  describe "cast!/2 with a map schema and [keys: :strings]" do
    setup do
      %{
        schema: Xema.new({:map, keys: :strings})
      }
    end

    test "from a map with atom keys", %{schema: schema} do
      assert cast!(schema, %{abc: 55, zzz: "z"}) == %{"abc" => 55, "zzz" => "z"}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"abc" => 55, "zzz" => "z"}
      assert cast!(schema, data) == data
    end

    test "from a keyword list", %{schema: schema} do
      assert cast!(schema, foo: 9) == %{"foo" => 9}
    end
  end

  describe "cast!/2 with a map schema, [keys: :atoms] and properties" do
    setup do
      %{
        schema: Xema.new({:map, keys: :atoms, properties: %{bla: :string}})
      }
    end

    test "from map with string keys and valid property", %{schema: schema} do
      data = %{"bla" => "foo"}
      assert cast!(schema, data) == %{bla: "foo"}
    end

    test "from map with string keys and integer property", %{schema: schema} do
      data = %{"bla" => 11}
      assert validate(schema, data) == {:error, %{keys: :atoms}}

      assert cast = cast!(schema, data)
      assert cast == %{bla: "11"}

      assert validate(schema, cast) == :ok
    end

    test "from map with atom keys and string property", %{schema: schema} do
      data = %{bla: "foo"}
      assert validate(schema, data) == :ok
      assert cast!(schema, data) == data
    end

    test "from map with atom keys and a castable value", %{schema: schema} do
      data = %{bla: 11}

      assert validate(schema, data) ==
               {:error, %{properties: %{bla: %{type: :string, value: 11}}}}

      assert cast = cast!(schema, data)
      assert cast == %{bla: "11"}

      assert validate(schema, cast) == :ok
    end

    test "from a map with unknown atom", %{schema: schema} do
      assert_raise_cast_error(schema, %{"xyz" => "z"}, %{key: "xyz"})
    end

    test "from a keyword list", %{schema: schema} do
      assert cast!(schema, foo: 77) == %{foo: 77}
    end
  end

  describe "cast!/2 with a map schema, [keys: :strings] and properties" do
    setup do
      %{
        schema: Xema.new({:map, keys: :strings, properties: %{"bla" => :string}})
      }
    end

    test "from map with string keys", %{schema: schema} do
      data = %{"bla" => "foo"}
      assert validate(schema, data) == :ok
      assert cast!(schema, data) == %{"bla" => "foo"}
    end

    test "from map with string keys and castable value", %{schema: schema} do
      data = %{"bla" => 11}

      assert validate(schema, data) ==
               {:error, %{properties: %{"bla" => %{type: :string, value: 11}}}}

      assert cast!(schema, data) == %{"bla" => "11"}
    end

    test "from map with atoms keys", %{schema: schema} do
      data = %{bla: "foo", bar: 5}
      assert validate(schema, data) == {:error, %{keys: :strings}}
      assert cast!(schema, data) == %{"bla" => "foo", "bar" => 5}
    end

    test "from map with atom keys and castable value", %{schema: schema} do
      data = %{bla: 11}

      assert validate(schema, data) == {:error, %{keys: :strings}}
      assert cast!(schema, data) == %{"bla" => "11"}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast!(schema, bla: 11, foo: 7) == %{"bla" => "11", "foo" => 7}
    end
  end

  describe "cast!/2 with a nested map schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             keys: :atoms,
             properties: %{
               foo:
                 {:map,
                  keys: :atoms,
                  properties: %{
                    num: {:integer, maximum: 12},
                    bar:
                      {:map,
                       keys: :atoms,
                       properties: %{
                         num: {:integer, maximum: 12}
                       }}
                  }}
             }}
          )
      }
    end

    test "from a valid map", %{schema: schema} do
      data = %{"foo" => %{"num" => 2}}
      expected = %{foo: %{num: 2}}

      assert cast!(schema, data) == expected
    end

    test "from a map with unknown key", %{schema: schema} do
      data = %{"foo" => %{"xyz" => 42}}

      assert_raise_cast_error(schema, data, %{key: "xyz", path: [:foo]})
    end

    test "from a map with unknown key (deeper)", %{schema: schema} do
      data = %{"foo" => %{"bar" => %{"xyz" => 42}}}

      assert_raise_cast_error(schema, data, %{key: "xyz", path: [:foo, :bar]})
    end

    test "from an invalid map", %{schema: schema} do
      data = %{"foo" => %{"num" => "42"}}

      assert cast = cast!(schema, data)
      assert cast == %{foo: %{num: 42}}

      assert validate(schema, cast) ==
               {:error,
                %{
                  properties: %{
                    foo: %{properties: %{num: %{value: 42, maximum: 12}}}
                  }
                }}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast!(schema, foo: [num: "5"]) == %{foo: %{num: 5}}
    end
  end

  describe "cast!/2 with an integer property schema" do
    setup do
      %{
        schema: Xema.new(properties: %{num: :integer})
      }
    end

    test "with a valid value", %{schema: schema} do
      assert cast!(schema, %{num: "77"}) == %{num: 77}
    end

    test "with a valid value from a keyword list", %{schema: schema} do
      assert cast!(schema, num: "77") == %{num: 77}
    end

    test "with an invalid value", %{schema: schema} do
      assert_raise_cast_error(schema, %{num: "77."}, %{path: [:num], to: :integer, value: "77."})
    end

    test "with an invalid value from a keyword list", %{schema: schema} do
      assert_raise_cast_error(schema, [num: "77."], %{path: [:num], to: :integer, value: "77."})
    end
  end

  defp assert_raise_cast_error(schema, value, opts \\ %{}) do
    msg = error_msg(value, opts)

    assert_raise CastError, msg, fn -> cast!(schema, value) end
  end

  defp error_msg(_, %{path: path, key: key}) do
    "cannot cast #{inspect(key)} to :map key at #{inspect(path)}, the atom is unknown"
  end

  defp error_msg(_, %{key: key}) do
    "cannot cast #{inspect(key)} to :map key, the atom is unknown"
  end

  defp error_msg(_, %{to: to, path: path, value: value}) do
    "cannot cast #{inspect(value)} to #{inspect(to)} at #{inspect(path)}"
  end

  defp error_msg(value, _) do
    "cannot cast #{inspect(value)} to :map"
  end
end
