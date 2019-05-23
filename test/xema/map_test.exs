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
                reason: %{
                  type: :map,
                  value: "foo"
                }
              } = error} = validate(schema, "foo")

      assert Exception.message(error) == ~s|Expected :map, got "foo".|
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
                reason: %{
                  properties: %{
                    foo: %{type: :number, value: "foo"}
                  }
                }
              } = error} = validate(schema, %{foo: "foo", bar: "bar"})

      assert Exception.message(error) == ~s|Expected :number, got "foo", at [:foo].|

      assert {:error,
              %ValidationError{
                reason: %{
                  properties: %{
                    foo: %{type: :number, value: "foo"},
                    bar: %{type: :string, value: 2}
                  }
                }
              } = error} = validate(schema, %{foo: "foo", bar: 2})

      message = """
      Expected :string, got 2, at [:bar].
      Expected :number, got "foo", at [:foo].\
      """

      assert Exception.message(error) == message
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
                reason: %{
                  properties: %{
                    "foo" => %{type: :number, value: "foo"}
                  }
                }
              } = error} = validate(schema, %{"foo" => "foo", "bar" => "bar"})

      assert Exception.message(error) == ~s|Expected :number, got "foo", at ["foo"].|
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
                 reason: %{
                   keys: :atoms
                 }
               } = error
             } = validate(schema, %{"foo" => 1})

      assert Exception.message(error) == ~s|Expected :atoms as key, got %{"foo" => 1}.|
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
                 reason: %{
                   keys: :strings
                 }
               } = error
             } = validate(schema, %{foo: 1})

      assert Exception.message(error) == "Expected :strings as key, got %{foo: 1}."
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
                 reason: %{
                   min_properties: 2
                 }
               } = error
             } = validate(schema, %{foo: 42})

      assert Exception.message(error) == "Expected at least 2 properties, got %{foo: 42}."
    end

    test "validate/2 with valid amount of properties", %{schema: schema} do
      assert validate(schema, %{foo: 42, bar: 44}) == :ok
    end

    test "validate/2 with too many properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   max_properties: 3
                 }
               } = error
             } = validate(schema, %{a: 1, b: 2, c: 3, d: 4})

      assert Exception.message(error) ==
               "Expected at most 3 properties, got %{a: 1, b: 2, c: 3, d: 4}."
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
              %ValidationError{
                reason: %{
                  properties: %{
                    "foo" => %{additional_properties: false}
                  }
                }
              } = error} = validate(schema, %{"foo" => 44})

      assert Exception.message(error) == ~s|Expected only defined properties, got key [\"foo\"].|
    end

    test "validate/2 with additional property", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  properties: %{
                    add: %{additional_properties: false},
                    extra: %{additional_properties: false}
                  }
                }
              } = error} = validate(schema, %{foo: 44, add: 1, extra: 2})

      message = """
      Expected only defined properties, got key [:add].
      Expected only defined properties, got key [:extra].\
      """

      assert Exception.message(error) == message
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
                reason: %{
                  properties: %{
                    foo: %{additional_properties: false}
                  }
                }
              } = error} = validate(schema, %{foo: 44})

      assert Exception.message(error) == "Expected only defined properties, got key [:foo]."
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
                 reason: %{
                   properties: %{add: %{type: :integer, value: "invalid"}}
                 }
               } = error
             } = validate(schema, %{foo: "foo", add: "invalid"})

      assert Exception.message(error) == ~s|Expected :integer, got \"invalid\", at [:add].|
    end

    test "validate/2 with invalid additional properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     add: %{type: :integer, value: "invalid"},
                     plus: %{type: :integer, value: "+"}
                   }
                 }
               } = error
             } = validate(schema, %{foo: "foo", add: "invalid", plus: "+"})

      message = """
      Expected :integer, got "invalid", at [:add].
      Expected :integer, got "+", at [:plus].\
      """

      assert Exception.message(error) == message
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
                reason: %{
                  required: [:foo]
                }
              } = error} = validate(schema, %{"foo" => 44})

      assert Exception.message(error) == "Required properties are missing: [:foo]."
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  required: [:foo]
                }
              } = error} = validate(schema, %{missing: 44})

      assert Exception.message(error) == "Required properties are missing: [:foo]."
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
                reason: %{
                  required: [:a, :b, :c]
                }
              } = error} = validate(schema, %{"a" => 1, "b" => 2, "c" => 3})

      assert Exception.message(error) == "Required properties are missing: [:a, :b, :c]."
    end

    test "validate/2 without required properties", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  required: [:a, :c]
                }
              } = error} = validate(schema, %{b: 3, d: 8})

      assert Exception.message(error) == "Required properties are missing: [:a, :c]."
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
                reason: %{
                  required: ["foo"]
                }
              } = error} = validate(schema, %{foo: 44})

      assert Exception.message(error) == ~s|Required properties are missing: ["foo"].|
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  required: ["foo"]
                }
              } = error} = validate(schema, %{missing: 44})

      assert Exception.message(error) == ~s|Required properties are missing: ["foo"].|
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
                reason: %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }
              } = error} = validate(schema, %{x_1: 44})

      assert Exception.message(error) == "Expected only defined properties, got key [:x_1]."
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
                reason: %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }
              } = error} = validate(schema, %{x_1: 44})

      assert Exception.message(error) == "Expected only defined properties, got key [:x_1]."
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
                reason: %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }
              } = error} = validate(schema, %{x_1: 44})

      assert Exception.message(error) == "Expected only defined properties, got key [:x_1]."
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
      {:error,
       %ValidationError{
         reason: %{
           dependencies: %{
             b: :c
           }
         }
       } = error} = validate(schema, %{a: 1, b: 2})

      assert Exception.message(error) == "Dependencies for :b failed. Missing required key :c."
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
                reason: %{
                  dependencies: %{b: :d}
                }
              } = error} = validate(schema, %{b: 2, c: 2})

      assert Exception.message(error) == "Dependencies for :b failed. Missing required key :d."
    end
  end

  describe "map schema with dependencies" do
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
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   dependencies: %{b: %{required: [:c]}}
                 }
               } = error
             } = validate(schema, %{a: 1, b: 2})

      message = """
      Dependencies for :b failed.
        Required properties are missing: [:c].\
      """

      assert Exception.message(error) == message
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
                 reason: %{
                   dependencies: %{penny: :pound}
                 }
               } = error
             } = validate(schema, %{penny: 1})

      assert Exception.message(error) ==
               "Dependencies for :penny failed. Missing required key :pound."
    end
  end

  describe "map schema with property names" do
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
                reason: %{
                  property_names: [
                    a: %{min_length: 3, value: "a"},
                    b: %{min_length: 3, value: "b"}
                  ],
                  value: [:a, :b, :foo]
                }
              } = error} = validate(schema, %{foo: 1, a: 2, b: 3})

      message = """
      Invalid property names.
        :a : Expected minimum length of 3, got "a".
        :b : Expected minimum length of 3, got "b".\
      """

      assert Exception.message(error) == message
    end

    test "with invalid string keys", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  property_names: [{"a", %{min_length: 3, value: "a"}}],
                  value: ["a", "foo"]
                }
              } = error} = validate(schema, %{"foo" => 1, "a" => 2})

      message = """
      Invalid property names.
        "a" : Expected minimum length of 3, got "a".\
      """

      assert Exception.message(error) == message
    end
  end

  describe "map schema with property names equal keywords" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              properties: [enum: ["yes", "no"]],
              items: :string,
              minimum: :integer
            }
          })
      }
    end

    test "validate with invalid property properties", %{schema: schema} do
      assert {:error,
              %Xema.ValidationError{
                reason: %{
                  properties: %{
                    properties: %{
                      enum: ["yes", "no"],
                      value: "maybe"
                    }
                  }
                }
              } = error} = validate(schema, %{properties: "maybe"})

      assert Exception.message(error) ==
               ~s|Value "maybe" is not defined in enum, at [:properties].|
    end

    test "validate with invalid property items", %{schema: schema} do
      assert {:error,
              %Xema.ValidationError{
                reason: %{
                  properties: %{
                    items: %{
                      type: :string,
                      value: 5
                    }
                  }
                }
              } = error} = validate(schema, %{items: 5})

      assert Exception.message(error) == "Expected :string, got 5, at [:items]."
    end

    test "validate with invalid property minimum", %{schema: schema} do
      assert {:error,
              %Xema.ValidationError{
                reason: %{
                  properties: %{
                    minimum: %{
                      type: :integer,
                      value: "5"
                    }
                  }
                }
              } = error} = validate(schema, %{minimum: "5"})

      assert Exception.message(error) == ~s|Expected :integer, got \"5\", at [:minimum].|
    end

    test "validate with invalid properties", %{schema: schema} do
      assert {:error,
              %Xema.ValidationError{
                reason: %{
                  properties: %{
                    minimum: %{type: :integer, value: "5"},
                    properties: %{enum: ["yes", "no"], value: "maybe"},
                    items: %{type: :string, value: 5}
                  }
                }
              } = error} = validate(schema, %{properties: "maybe", items: 5, minimum: "5"})

      message = """
      Expected :string, got 5, at [:items].
      Expected :integer, got "5", at [:minimum].
      Value "maybe" is not defined in enum, at [:properties].\
      """

      assert Exception.message(error) == message
    end
  end
end
