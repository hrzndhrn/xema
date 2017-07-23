defmodule Xema.MapTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2, xema: 1]

  alias Xema.Map

  setup do
    %{
      # A map schema with min_properties
      min: xema({:map, min_properties: 2}),
      # A map schema with max_properties
      max: Xema.create(:map, max_properties: 3),
      # A map schema with min_properties and max_properties
      min_max: Xema.create(:map, min_properties: 2, max_properties: 3),
      # Just some properties
      # Some properties and no additional properties
      no_add: Xema.create(
        :map,
        additional_properties: false,
        properties: %{
          foo: Xema.create(:number),
          bar: Xema.create(:string)
        }),
      # Some propertieds ans some required properties
      atom: %{
        required: Xema.create(
          :map,
          required: [:foo, :bar],
          properties: %{
            foo: Xema.create(:number),
            bar: Xema.create(:string),
            baz: Xema.create(:number)
          }
        ),
      },
      string: %{
        required: Xema.create(
          :map,
          required: ["foo", "bar"],
          properties: %{
            foo: Xema.create(:number),
            bar:  Xema.create(:string),
            baz: Xema.create(:number)
          }
        ),
        props: Xema.create(
          :map,
          properties: %{
            "foo" => Xema.create(:number),
            "bar" => Xema.create(:string)
          }
        )
      },
      pattern: Xema.create(
        :map,
        pattern_properties: %{
          ~r/^s_/ => Xema.create(:string),
          ~r/^i_/ => Xema.create(:number)
        },
        additional_properties: false
      )
    }
  end

  describe "empty map schema" do
    setup do
      %{schema: xema :map}
    end

    test "type", %{schema: schema} do
      assert schema.type == :map
      assert Xema.type(schema) == :map
      assert %Map{} = schema.keywords
    end

    test "with an empty map", %{schema: schema},
      do: assert validate(schema, %{}) == :ok

    test "with a string", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :map}}
      assert validate(schema, "foo") == expected
    end
  end

  describe "empty map schema as object" do
    setup do
      %{schema: xema {:map, as: :object}}
    end

    test "type", %{schema: schema} do
      assert schema.type == :map
      assert Xema.type(schema) == :object
      assert %Map{} = schema.keywords
    end

    test "with a string", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :object}}
      assert validate(schema, "foo") == expected
    end
  end

  describe "map schema with properties (atom keys)" do
    setup do
      %{
        schema: xema {
          :map,
          properties: %{
            foo: :number,
            bar: :string
          }
        }
      }
    end

    test "with valid values", %{schema: schema} do
      assert validate(schema, %{foo: 2, bar: "bar"}) == :ok
      assert validate(schema, %{"foo" => 2, "bar" => "bar"}) == :ok
    end

    test "with invalid values (atom keys)", %{schema: schema} do
      expected = {:error, %{
        reason: :invalid_property,
        property: :foo,
        error: %{reason: :wrong_type, type: :number}
      }}
      assert validate(schema, %{foo: "foo", bar: "bar"}) == expected
    end

    test "with invalid values (string keys)", %{schema: schema} do
      expected = {:error, %{
        reason: :invalid_property,
        property: "foo",
        error: %{reason: :wrong_type, type: :number}
      }}
      assert validate(schema, %{"foo" => "foo", "bar" => "bar"}) == expected
    end
  end

  describe "map schema with properties (string keys)" do
    setup do
      %{
        schema: xema{
          :map,
          properties: %{
            "foo" => :number,
            "bar" => :string
          }
        }
      }
    end

    test "with valid values", %{schema: schema} do
      assert validate(schema, %{foo: 2, bar: "bar"}) == :ok
      assert validate(schema, %{"foo" => 2, "bar" => "bar"}) == :ok
    end

    test "with invalid values (atom keys)", %{schema: schema} do
      expected = {:error, %{
        reason: :invalid_property,
        property: :foo,
        error: %{reason: :wrong_type, type: :number}
      }}
      assert validate(schema, %{foo: "foo", bar: "bar"}) == expected
    end

    test "with invalid values (string keys)", %{schema: schema} do
      expected = {:error, %{
        reason: :invalid_property,
        property: "foo",
        error: %{reason: :wrong_type, type: :number}
      }}
      assert validate(schema, %{"foo" => "foo", "bar" => "bar"}) == expected
    end
  end

  describe "map schema with keys: :atom" do
    setup do
      %{
        schema: xema{
          :map,
          keys: :atoms,
          properties: %{
            "foo" => :number,
            "bar" => :string
          }
        }
      }
    end

    test "with valid key type", %{schema: schema},
      do: assert validate(schema, %{foo: 1}) == :ok

    test "with invalid key type", %{schema: schema} do
      expected = {:error, %{reason: :invalid_keys, keys: :atoms}}
      assert validate(schema, %{"foo" => 1}) == expected
    end
  end

  describe "map schema with keys: :string" do
    setup do
      %{
        schema: xema {
          :map,
          keys: :strings,
          properties: %{
            "foo" => :number,
            "bar" => :string
          }
        }
      }
    end

    test "returns :ok for valid key type", %{schema: schema} do
      expected = {:error, %{reason: :invalid_keys, keys: :strings}}
      assert validate(schema, %{foo: 1}) == expected
    end

    test "returns an error tuple for invalid key type", %{schema: schema},
      do: assert validate(schema, %{"foo" => 1}) == :ok
  end

  test "min_properties with too less properties", %{min: schema} do
    expected = {:error, %{reason: :too_less_properties, min_properties: 2}}
    assert validate(schema, %{a: 1}) == expected
  end

  test "min_properties with propper properties", %{min: schema},
    do: assert validate(schema, %{a: 1, b: 2}) == :ok

  test "max_properties with propper properties", %{max: schema},
    do: assert validate(schema, %{a: 1, b: 2, c: 3}) == :ok

  test "max_properties with too many properties", %{max: schema} do
    expected = {:error, %{reason: :too_many_properties, max_properties: 3}}
    assert validate(schema, %{a: 1, b: 2, c: 3, d: 4}) == expected
  end

  test "min/max_properties with too less properties", %{min_max: schema} do
    expected = {:error, %{reason: :too_less_properties, min_properties: 2}}
    assert validate(schema, %{a: 1}) == expected
  end

  test "min/max_properties propper properties", %{min_max: schema} do
    assert validate(schema, %{a: 1, b: 2}) == :ok
    assert validate(schema, %{a: 1, b: 2, c: 3}) == :ok
  end

  test "min/max_properties with too many properties", %{min_max: schema} do
    expected = {:error, %{reason: :too_many_properties, max_properties: 3}}
    assert validate(schema, %{a: 1, b: 2, c: 3, d: 4}) == expected
  end

  describe "schema with no additional properties" do
    test "with less properties", %{no_add: schema},
      do: assert validate(schema, %{foo: 1}) == :ok

    test "with additional property", %{no_add: schema} do
      expected = {:error, %{
        reason: :no_additional_properties_allowed,
        additional_properties: [:add]
      }}
      assert validate(schema, %{add: 1}) == expected
    end
  end

  describe "schema with required properties (atom keys)" do
    test "with propper map", %{atom: %{required: schema}},
      do: assert validate(schema, %{foo: 1, bar: "x"}) == :ok

    test "with a missing property", %{atom: %{required: schema}} do
      expected = {:error, %{
        reason: :missing_properties,
        missing: [:bar],
        required: [:bar, :foo]
      }}
      assert validate(schema, %{foo: 1}) == expected
    end
  end

  describe "schema with required properties (string keys)" do
    test "with propper map", %{string: %{required: schema}},
      do: assert validate(schema, %{"foo" => 1, "bar" => "x"}) == :ok

    test "with a missing property", %{string: %{required: schema}} do
      expected = {:error, %{
        reason: :missing_properties,
        missing: ["bar"],
        required: ["bar", "foo"]
      }}
      assert validate(schema, %{"foo" => 1}) == expected
    end
  end

  describe "schema with pattern properties" do
    test "with propper map", %{pattern: schema},
      do: assert validate(schema, %{i_0: 0, i_1: 1, s_X: "six"}) == :ok

    test "with wrong value", %{pattern: schema} do
      expected = {:error, %{
        reason: :invalid_property,
        property: :i_0,
        error: %{
          reason: :wrong_type,
          type: :number
        }
      }}
      assert validate(schema, %{i_0: "bla"}) == expected
    end

    test "with addition property", %{pattern: schema} do
      expected = {:error, %{
        reason: :no_additional_properties_allowed,
        additional_properties: [:add]
      }}
      assert validate(schema, %{i_0: 0, add: 1}) == expected
    end
  end

  describe "empty map schema is_valid?/2" do
    setup do
      %{schema: Xema.create(:map)}
    end

    test "with an empty map", %{schema: schema},
      do: assert is_valid?(schema, %{})

    test "map with a string", %{schema: schema},
      do: refute is_valid?(schema, "foo")
  end
end
