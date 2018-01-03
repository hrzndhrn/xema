defmodule Xema.MapTest do
  use ExUnit.Case, async: true

  import Xema

  describe "empty 'map' schema" do
    setup do
      %{schema: xema(:map)}
    end

    test "type", %{schema: schema} do
      assert schema.content.as == :map
    end

    test "validate/2 with an empty map", %{schema: schema} do
      assert validate(schema, %{}) == :ok
    end

    test "validate/2 with a string", %{schema: schema} do
      expected = {:error, %{type: :map, value: "foo"}}

      assert validate(schema, "foo") == expected
    end

    test "is_valid?/2 with a valid value", %{schema: schema} do
      assert is_valid?(schema, %{})
    end

    test "is_valid?/2 with an invalid value", %{schema: schema} do
      refute is_valid?(schema, 55)
    end
  end

  describe "empty 'map' schema as object" do
    setup do
      %{schema: xema(:map, as: :object)}
    end

    test "type", %{schema: schema} do
      assert schema.content.as == :object
    end

    test "validate/2 with a string", %{schema: schema} do
      expected = {:error, %{type: :object, value: "foo"}}

      assert validate(schema, "foo") == expected
    end
  end

  describe "'map' schema with properties (atom keys)" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{
              foo: :number,
              bar: :string
            }
          )
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, %{foo: 2, bar: "bar"}) == :ok
      assert validate(schema, %{"foo" => 2, "bar" => "bar"}) == :ok
    end

    test "validate/2 with invalid values (atom keys)", %{schema: schema} do
      assert validate(schema, %{foo: "foo", bar: "bar"}) ==
               {:error, %{
                 foo: %{type: :number, value: "foo"}
               }}

      assert validate(schema, %{foo: "foo", bar: 2}) ==
               {:error, %{
                 foo: %{type: :number, value: "foo"},
                 bar: %{type: :string, value: 2}
               }}
    end

    test "validate/2 with invalid values (string keys)", %{schema: schema} do
      assert validate(schema, %{"foo" => "foo", "bar" => "bar"}) ==
               {:error, %{
                 "foo" => %{type: :number, value: "foo"}
               }}
    end

    test "validate/2 with mixed map", %{schema: schema} do
      assert validate(schema, %{"foo" => 1, foo: 2}) == {:error, %{foo: :mixed_map}}
    end
  end

  describe "'map' schema with properties (string keys)" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{
              "foo" => :number,
              "bar" => :string
            }
          )
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, %{foo: 2, bar: "bar"}) == :ok
      assert validate(schema, %{"foo" => 2, "bar" => "bar"}) == :ok
    end

    test "validate/2 with invalid values (atom keys)", %{schema: schema} do
      assert validate(schema, %{foo: "foo", bar: "bar"}) ==
               {:error, %{
                 foo: %{type: :number, value: "foo"}
               }}
    end

    test "validate/2 with invalid values (string keys)", %{schema: schema} do
      assert validate(schema, %{"foo" => "foo", "bar" => "bar"}) ==
               {:error, %{
                 "foo" => %{type: :number, value: "foo"}
               }}
    end

    test "validate/2 with mixed map", %{schema: schema} do
      assert validate(schema, %{"foo" => 1, foo: 2}) == {:error, %{"foo" => :mixed_map}}
    end
  end

  describe "'map' schema with keys: :atoms" do
    setup do
      %{
        schema:
          xema(
            :map,
            keys: :atoms,
            properties: %{
              "foo" => :number,
              "bar" => :string
            }
          )
      }
    end

    test "validate/2 with valid key type", %{schema: schema} do
      assert validate(schema, %{foo: 1}) == :ok
    end

    test "validate/2 with invalid key type", %{schema: schema} do
      assert validate(schema, %{"foo" => 1}) == {:error, %{keys: :atoms}}
    end
  end

  describe "'map' schema with keys: :strings" do
    setup do
      %{
        schema:
          xema(
            :map,
            keys: :strings,
            properties: %{
              "foo" => :number,
              "bar" => :string
            }
          )
      }
    end

    test "validate/2 with valid key type", %{schema: schema} do
      assert validate(schema, %{foo: 1}) == {:error, %{keys: :strings}}
    end

    test "validate/2 invalid key type", %{schema: schema} do
      assert validate(schema, %{"foo" => 1}) == :ok
    end
  end

  describe "'map' schema with min/max properties" do
    setup do
      %{schema: xema(:map, min_properties: 2, max_properties: 3)}
    end

    test "validate/2 with too less properties", %{schema: schema} do
      assert validate(schema, %{foo: 42}) == {:error, %{min_properties: 2}}
    end

    test "validate/2 with valid amount of properties", %{schema: schema} do
      assert validate(schema, %{foo: 42, bar: 44}) == :ok
    end

    test "validate/2 with too many properties", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2, c: 3, d: 4}) == {:error, %{max_properties: 3}}
    end
  end

  describe "'map' schema without additional properties" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{foo: :number},
            additional_properties: false
          )
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{foo: 44}) == :ok
    end

    test "validate/2 with additional property", %{schema: schema} do
      assert validate(schema, %{foo: 44, add: 1}) ==
               {:error, %{
                 add: %{additional_properties: false}
               }}
    end

    test "validate/2 with additional properties", %{schema: schema} do
      assert validate(schema, %{foo: 44, add: 1, plus: 3}) ==
               {:error, %{
                 add: %{additional_properties: false},
                 plus: %{additional_properties: false}
               }}
    end
  end

  describe "map schema with specific additional properties" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{foo: {:string, min_length: 3}},
            additional_properties: :integer
          )
      }
    end

    test "validate/2 with valid additional property", %{schema: schema} do
      assert validate(schema, %{foo: "foo", add: 1}) == :ok
    end

    test "validate/2 with invalid additional property", %{schema: schema} do
      assert validate(schema, %{foo: "foo", add: "invalid"}) ==
               {
                 :error,
                 %{
                   add: %{type: :integer, value: "invalid"}
                 }
               }
    end

    test "validate/2 with invalid additional properties", %{schema: schema} do
      assert validate(schema, %{foo: "foo", add: "invalid", plus: "+"}) ==
               {
                 :error,
                 %{
                   add: %{type: :integer, value: "invalid"},
                   plus: %{type: :integer, value: "+"}
                 }
               }
    end
  end

  describe "'map' schema with required property (atom keys)" do
    setup do
      %{schema: xema(:map, properties: %{foo: :number}, required: [:foo])}
    end

    test "validate/2 with required property", %{schema: schema} do
      assert validate(schema, %{foo: 44}) == :ok
    end

    test "validate/2 with invalid key", %{schema: schema} do
      assert validate(schema, %{"foo" => 44}) ==
               {:error, %{
                 foo: :required
               }}
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert validate(schema, %{missing: 44}) ==
               {:error, %{
                 foo: :required
               }}
    end
  end

  describe "'map' schema with required properties (atom keys)" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{a: :number, b: :number, c: :number},
            required: [:a, :b, :c]
          )
      }
    end

    test "validate/2 without required properties", %{schema: schema} do
      assert validate(schema, %{b: 3, d: 8}) ==
               {:error, %{
                 a: :required,
                 c: :required
               }}
    end
  end

  describe "'map' schema with required property (string keys)" do
    setup do
      %{schema: xema(:map, properties: %{foo: :number}, required: ["foo"])}
    end

    test "validate/2 with required property", %{schema: schema} do
      assert validate(schema, %{"foo" => 44}) == :ok
    end

    test "validate/2 with invalid key", %{schema: schema} do
      assert validate(schema, %{foo: 44}) ==
               {:error, %{
                 "foo" => :required
               }}
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert validate(schema, %{missing: 44}) ==
               {:error, %{
                 "foo" => :required
               }}
    end
  end

  describe "'map' schema with pattern properties" do
    setup do
      %{
        schema:
          xema(
            :map,
            pattern_properties: %{
              ~r/^s_/ => :string,
              ~r/^i_/ => :number
            },
            additional_properties: false
          )
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{s_1: "foo", i_1: 42}) == :ok
    end

    test "validate/2 with invalid map", %{schema: schema} do
      assert validate(schema, %{x_1: 44}) ==
               {:error, %{
                 x_1: %{additional_properties: false}
               }}
    end
  end

  describe "'map' schema with property names like keywords" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{
              map: :number,
              items: :number,
              properties: :number
            }
          )
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{map: 3, items: 5, properties: 4}) == :ok
    end
  end

  describe "map schema with dependencies list" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{
              a: :number,
              b: :number,
              c: :number
            },
            dependencies: %{
              b: [:c]
            }
          )
      }
    end

    test "validate/2 without dependency", %{schema: schema} do
      assert validate(schema, %{a: 1}) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2, c: 3}) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2}) ==
               {:error, %{
                 b: %{dependency: :c}
               }}
    end
  end

  describe "map schema with dependencies schema" do
    setup do
      %{
        schema:
          xema(
            :map,
            properties: %{
              a: :number,
              b: :number
            },
            dependencies: %{
              b:
                {
                  :map,
                  properties: %{
                    c: :number
                  },
                  required: [:c]
                }
            }
          )
      }
    end

    test "validate/2 without dependency", %{schema: schema} do
      assert validate(schema, %{a: 1}) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2, c: 3}) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2}) ==
               {:error, %{
                 b: %{required: [:c]}
               }}
    end
  end

  describe "In for a penny, in for a pound." do
    setup do
      %{
        schema:
          xema(
            :map,
            dependencies: %{
              penny: [:pound]
            }
          )
      }
    end

    test "a cent", %{schema: schema} do
      assert is_valid?(schema, %{cent: 1})
    end

    test "a pound", %{schema: schema} do
      assert is_valid?(schema, %{pound: 1})
    end

    test "a penny and a pound", %{schema: schema} do
      assert is_valid?(schema, %{penny: 1, pound: 1})
    end

    test "a penny", %{schema: schema} do
      assert validate(schema, %{penny: 1}) == {:error, %{penny: %{dependency: :pound}}}
    end
  end
end
