defmodule Xema.Cast.MapTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, validate: 2]

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

    test "from a valid map with atom keys", %{schema: schema} do
      data = %{bla: "foo"}
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from an integer", %{schema: schema} do
      assert cast(schema, 11) ==
               {:error, %{path: [], reason: %{cast: Integer, to: :map, value: 11}}}
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
               {:error, %{path: [], reason: {:unknown_atom, "xyz"}}}
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

    test "from map with string keys and invalid property", %{schema: schema} do
      data = %{"bla" => 11}
      assert validate(schema, data) == {:error, %{keys: :atoms}}

      assert {:ok, cast} = cast(schema, data)
      assert cast == %{bla: "11"}

      assert validate(schema, cast) == :ok
    end

    test "from map with atoms keys and valid property", %{schema: schema} do
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
               {:error, %{path: [], reason: {:unknown_atom, "xyz"}}}
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
      expected = {:error, %{path: [:foo], reason: {:unknown_atom, "xyz"}}}

      assert cast(schema, data) == expected
    end

    test "from a map with unknown key (deeper)", %{schema: schema} do
      data = %{"foo" => %{"bar" => %{"xyz" => 42}}}
      expected = {:error, %{path: [:foo, :bar], reason: {:unknown_atom, "xyz"}}}

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

    test "with an invalid value", %{schema: schema} do
      assert cast(schema, %{num: "77."}) ==
               {:error, %{path: [:num], reason: {:not_an_integer, "77."}}}
    end
  end
end
