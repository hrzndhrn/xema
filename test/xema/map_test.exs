defmodule Xema.MapTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "empty map schema" do
    setup do
      %{schema: Xema.new(:map)}
    end

    test "validate/2 with an empty map", %{schema: schema} do
      assert validate(schema, %{}) == :ok
    end

    test "validate/2 with a string", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: ~s|Expected :map, got "foo".|,
                reason: %{
                  type: :map,
                  value: "foo"
                }
              }} = validate(schema, "foo")
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute valid?(schema, 55)
    end
  end

  describe "map schema with properties (atom keys)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              foo: :number,
              bar: :string
            }
          })
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, %{foo: 2, bar: "bar"}) == :ok

      # The following test are ok because the string keys are not part of the schema.
      assert validate(schema, %{"foo" => 2, "bar" => "bar"}) == :ok
      assert validate(schema, %{"foo" => "bar", "bar" => 2}) == :ok
      assert validate(schema, %{"foo" => 1, foo: 2}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: ~s|Expected :number, got "foo", at [:foo].|,
                reason: %{
                  properties: %{
                    foo: %{type: :number, value: "foo"}
                  }
                }
              }} = validate(schema, %{foo: "foo", bar: "bar"})

      message = """
      Expected :string, got 2, at [:bar].
      Expected :number, got "foo", at [:foo].\
      """

      assert {:error,
              %ValidationError{
                message: ^message,
                reason: %{
                  properties: %{
                    foo: %{type: :number, value: "foo"},
                    bar: %{type: :string, value: 2}
                  }
                }
              }} = validate(schema, %{foo: "foo", bar: 2})
    end
  end

  describe "map schema with properties (string keys)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              "foo" => :number,
              "bar" => :string
            }
          })
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, %{"foo" => 2, "bar" => "bar"}) == :ok

      # The following test are ok because the string keys are not part of the
      # schema.
      assert validate(schema, %{foo: 2, bar: "bar"}) == :ok
      assert validate(schema, %{foo: "2", bar: 2}) == :ok
      assert validate(schema, %{"foo" => 1, foo: 2}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: ~s|Expected :number, got "foo", at ["foo"].|,
                reason: %{
                  properties: %{
                    "foo" => %{type: :number, value: "foo"}
                  }
                }
              }} = validate(schema, %{"foo" => "foo", "bar" => "bar"})
    end
  end

  describe "map schema with keys: :atoms" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            keys: :atoms,
            properties: %{
              foo: :number,
              bar: :string
            }
          })
      }
    end

    test "validate/2 with valid key type", %{schema: schema} do
      assert validate(schema, %{foo: 1}) == :ok
    end

    test "validate/2 with invalid key type", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected :atoms as key, got %{"foo" => 1}.|,
                 reason: %{
                   keys: :atoms
                 }
               }
             } = validate(schema, %{"foo" => 1})
    end
  end

  describe "map schema with keys: :strings" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            keys: :strings,
            properties: %{
              "foo" => :number,
              "bar" => :string
            }
          })
      }
    end

    test "validate/2 with valid key type", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected :strings as key, got %{foo: 1}.",
                 reason: %{
                   keys: :strings
                 }
               }
             } = validate(schema, %{foo: 1})
    end

    test "validate/2 invalid key type", %{schema: schema} do
      assert validate(schema, %{"foo" => 1}) == :ok
    end
  end

  describe "map schema with min/max properties" do
    setup do
      %{schema: Xema.new({:map, min_properties: 2, max_properties: 3})}
    end

    test "validate/2 with too less properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected at least 2 properties, got %{foo: 42}.",
                 reason: %{
                   min_properties: 2
                 }
               }
             } = validate(schema, %{foo: 42})
    end

    test "validate/2 with valid amount of properties", %{schema: schema} do
      assert validate(schema, %{foo: 42, bar: 44}) == :ok
    end

    test "validate/2 with too many properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected at most 3 properties, got %{a: 1, b: 2, c: 3, d: 4}.",
                 reason: %{
                   max_properties: 3
                 }
               }
             } = validate(schema, %{a: 1, b: 2, c: 3, d: 4})
    end
  end

  describe "map schema without additional properties (atom properties)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{foo: :number}, additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{foo: 44}) == :ok
    end

    test "validate/2 with invalid key type", %{schema: schema} do
      assert {:error,
              %{
                message: ~s|Expected only defined properties, got key [\"foo\"].|,
                reason: %{
                  properties: %{
                    "foo" => %{additional_properties: false}
                  }
                }
              }} = validate(schema, %{"foo" => 44})
    end

    test "validate/2 with additional property", %{schema: schema} do
      msg = """
      Expected only defined properties, got key [:add].
      Expected only defined properties, got key [:extra].\
      """

      assert {:error,
              %ValidationError{
                message: ^msg,
                reason: %{
                  properties: %{
                    add: %{additional_properties: false}
                  }
                }
              }} = validate(schema, %{foo: 44, add: 1, extra: 2})
    end
  end

  describe "map schema without additional properties (string properties)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{"foo" => :number}, additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{"foo" => 44}) == :ok
    end

    test "validate/2 with invalid key type", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Expected only defined properties, got key [:foo].",
                reason: %{
                  properties: %{
                    foo: %{additional_properties: false}
                  }
                }
              }} = validate(schema, %{foo: 44})
    end
  end

  describe "map schema with specific additional properties" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{foo: {:string, min_length: 3}}, additional_properties: :integer
          })
      }
    end

    test "validate/2 with valid additional property", %{schema: schema} do
      assert validate(schema, %{foo: "foo", add: 1}) == :ok
    end

    test "validate/2 with invalid additional property", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected :integer, got \"invalid\", at [:add].|,
                 reason: %{
                   properties: %{add: %{type: :integer, value: "invalid"}}
                 }
               }
             } = validate(schema, %{foo: "foo", add: "invalid"})
    end

    test "validate/2 with invalid additional properties", %{schema: schema} do
      msg = """
      Expected :integer, got "invalid", at [:add].
      Expected :integer, got "+", at [:plus].\
      """

      assert {
               :error,
               %ValidationError{
                 message: ^msg,
                 reason: %{
                   properties: %{
                     add: %{type: :integer, value: "invalid"},
                     plus: %{type: :integer, value: "+"}
                   }
                 }
               }
             } = validate(schema, %{foo: "foo", add: "invalid", plus: "+"})
    end
  end

  describe "map schema with required property (atom keys)" do
    setup do
      %{schema: Xema.new({:map, properties: %{foo: :number}, required: [:foo]})}
    end

    test "validate/2 with required property", %{schema: schema} do
      assert validate(schema, %{foo: 44}) == :ok
    end

    test "validate/2 with invalid key type", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Required properties are missing: [:foo].",
                reason: %{
                  required: [:foo]
                }
              }} = validate(schema, %{"foo" => 44})
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Required properties are missing: [:foo].",
                reason: %{
                  required: [:foo]
                }
              }} = validate(schema, %{missing: 44})
    end
  end

  describe "map schema with required properties (atom keys)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{a: :number, b: :number, c: :number}, required: [:a, :b, :c]
          })
      }
    end

    test "validate/2 with invalid key type", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Required properties are missing: [:a, :b, :c].",
                reason: %{
                  required: [:a, :b, :c]
                }
              }} = validate(schema, %{"a" => 1, "b" => 2, "c" => 3})
    end

    test "validate/2 without required properties", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Required properties are missing: [:a, :c].",
                reason: %{
                  required: [:a, :c]
                }
              }} = validate(schema, %{b: 3, d: 8})
    end
  end

  describe "map schema with required property (string keys)" do
    setup do
      %{
        schema: Xema.new({:map, properties: %{"foo" => :number}, required: ["foo"]})
      }
    end

    test "validate/2 with required property", %{schema: schema} do
      assert validate(schema, %{"foo" => 44}) == :ok
    end

    test "validate/2 with invalid key type", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: ~s|Required properties are missing: ["foo"].|,
                reason: %{
                  required: ["foo"]
                }
              }} = validate(schema, %{foo: 44})
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: ~s|Required properties are missing: ["foo"].|,
                reason: %{
                  required: ["foo"]
                }
              }} = validate(schema, %{missing: 44})
    end
  end

  describe "map schema with pattern properties" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            pattern_properties: %{
              ~r/^s_/ => :string,
              ~r/^i_/ => :number
            },
            additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{s_1: "foo", i_1: 42}) == :ok
    end

    test "validate/2 with invalid map", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Expected only defined properties, got key [:x_1].",
                reason: %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }
              }} = validate(schema, %{x_1: 44})
    end
  end

  describe "map schema with pattern properties (string key)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            pattern_properties: %{
              "^s_" => :string,
              "^i_" => :number
            },
            additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{s_1: "foo", i_1: 42}) == :ok
    end

    test "validate/2 with invalid map", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Expected only defined properties, got key [:x_1].",
                reason: %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }
              }} = validate(schema, %{x_1: 44})
    end
  end

  describe "map schema with pattern properties (atom key)" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            pattern_properties: %{
              "^s_": :string,
              "^i_": :number
            },
            additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{s_1: "foo", i_1: 42}) == :ok
    end

    test "validate/2 with invalid map", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Expected only defined properties, got key [:x_1].",
                reason: %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }
              }} = validate(schema, %{x_1: 44})
    end
  end

  describe "map schema with property names like keywords" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              map: :number,
              items: :number,
              properties: :number
            }
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, %{map: 3, items: 5, properties: 4}) == :ok
    end
  end

  describe "map schema with dependencies property: " do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              a: :number,
              b: :number,
              c: :number
            },
            dependencies: %{
              b: :c
            }
          })
      }
    end

    test "validate/2 without dependency", %{schema: schema} do
      assert validate(schema, %{a: 1}) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2, c: 3}) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Dependencies for :b failed. Missing required key :c.",
                reason: %{
                  dependencies: %{
                    b: :c
                  }
                }
              }} = validate(schema, %{a: 1, b: 2})
    end
  end

  describe "map schema with dependencies list" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              a: :number,
              b: :number,
              c: :number,
              d: :number
            },
            dependencies: %{
              b: [:c, :d]
            }
          })
      }
    end

    test "validate/2 without dependency", %{schema: schema} do
      assert validate(schema, %{a: 1}) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, %{b: 2, c: 3, d: 4}) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Dependencies for :b failed. Missing required key :d.",
                reason: %{
                  dependencies: %{b: :d}
                }
              }} = validate(schema, %{b: 2, c: 2})
    end
  end

  describe "map schema with dependencies schema" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              a: :number,
              b: :number
            },
            dependencies: %{
              b: {
                :map,
                properties: %{
                  c: :number
                },
                required: [:c]
              }
            }
          })
      }
    end

    test "validate/2 without dependency", %{schema: schema} do
      assert validate(schema, %{a: 1}) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2, c: 3}) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      msg = """
      Dependencies for :b failed:
        Required properties are missing: [:c].\
      """

      assert {
               :error,
               %ValidationError{
                 message: ^msg,
                 reason: %{
                   dependencies: %{b: %{required: [:c]}}
                 }
               }
             } = validate(schema, %{a: 1, b: 2})
    end
  end

  describe "In for a penny, in for a pound." do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            dependencies: %{
              penny: [:pound]
            }
          })
      }
    end

    test "a cent", %{schema: schema} do
      assert valid?(schema, %{cent: 1})
    end

    test "a pound", %{schema: schema} do
      assert valid?(schema, %{pound: 1})
    end

    test "a penny and a pound", %{schema: schema} do
      assert valid?(schema, %{penny: 1, pound: 1})
    end

    test "a penny", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Dependencies for :penny failed. Missing required key :pound.",
                 reason: %{
                   dependencies: %{penny: :pound}
                 }
               }
             } = validate(schema, %{penny: 1})
    end
  end

  describe "validate/2 property names" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            property_names: [min_length: 3]
          })
      }
    end

    test "with valid keys", %{schema: schema} do
      assert validate(schema, %{foo: 1, bar: 2}) == :ok
    end

    test "with invalid atom keys", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: "Invalid property names: [:a, :b].",
                reason: %{
                  value: [:a, :b]
                }
              }} = validate(schema, %{foo: 1, a: 2, b: 3})
    end

    test "with invalid string keys", %{schema: schema} do
      assert {:error,
              %ValidationError{
                message: ~s|Invalid property names: ["a"].|,
                reason: %{
                  value: ["a"]
                }
              }} = validate(schema, %{"foo" => 1, "a" => 2})
    end
  end
end
