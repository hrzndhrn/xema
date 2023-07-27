defmodule Xema.KeywordTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "empty keyword schema" do
    setup do
      %{schema: Xema.new(:keyword)}
    end

    test "validate/2 with an empty keyword list", %{schema: schema} do
      assert validate(schema, []) == :ok
    end

    test "validate/2 with a string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: :keyword, value: "foo"}
               } = error
             } = validate(schema, "foo")

      assert Exception.message(error) == ~s|Expected :keyword, got "foo".|
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, foo: 42, bar: 66)
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute valid?(schema, 55)
    end
  end

  describe "keyword schema with properties" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{
              foo: :number,
              bar: :string
            }
          })
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, foo: 2, bar: "bar") == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     foo: %{type: :number, value: "foo"}
                   }
                 }
               } = error
             } = validate(schema, foo: "foo", bar: "bar")

      assert Exception.message(error) == ~s|Expected :number, got "foo", at [:foo].|

      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     foo: %{type: :number, value: "foo"},
                     bar: %{type: :string, value: 2}
                   }
                 }
               } = error
             } = validate(schema, foo: "foo", bar: 2)

      assert message = Exception.message(error)
      assert message =~ ~s|Expected :string, got 2, at [:bar].|
      assert message =~ ~s|Expected :number, got "foo", at [:foo].|
    end
  end

  describe "keyword schema with min/max properties" do
    setup do
      %{schema: Xema.new({:keyword, min_properties: 2, max_properties: 3})}
    end

    test "validate/2 with too less properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{min_properties: 2}
               } = error
             } = validate(schema, foo: 42)

      assert Exception.message(error) == "Expected at least 2 properties, got [foo: 42]."
    end

    test "validate/2 with valid amount of properties", %{schema: schema} do
      assert validate(schema, foo: 42, bar: 44) == :ok
    end

    test "validate/2 with too many properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{max_properties: 3}
               } = error
             } = validate(schema, a: 1, b: 2, c: 3, d: 4)

      assert Exception.message(error) ==
               "Expected at most 3 properties, got [a: 1, b: 2, c: 3, d: 4]."
    end
  end

  describe "map schema without additional properties" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{foo: :number}, additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, foo: 44) == :ok
    end

    test "validate/2 with additional property", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     add: %{additional_properties: false}
                   }
                 }
               } = error
             } = validate(schema, foo: 44, add: 1)

      assert Exception.message(error) == "Expected only defined properties, got key [:add]."
    end

    test "validate/2 with additional properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     add: %{additional_properties: false},
                     plus: %{additional_properties: false}
                   }
                 }
               } = error
             } = validate(schema, foo: 44, add: 1, plus: 3)

      message = """
      Expected only defined properties, got key [:add].
      Expected only defined properties, got key [:plus].\
      """

      assert Exception.message(error) == message
    end
  end

  describe "map schema with specific additional properties" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{foo: {:string, min_length: 3}}, additional_properties: :integer
          })
      }
    end

    test "validate/2 with valid additional property", %{schema: schema} do
      assert validate(schema, foo: "foo", add: 1) == :ok
    end

    test "validate/2 with invalid additional property", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  properties: %{
                    add: %{type: :integer, value: "invalid"}
                  }
                }
              } = error} = validate(schema, foo: "foo", add: "invalid")

      assert Exception.message(error) == ~s|Expected :integer, got "invalid", at [:add].|
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
             } = validate(schema, foo: "foo", add: "invalid", plus: "+")

      message = """
      Expected :integer, got "invalid", at [:add].
      Expected :integer, got "+", at [:plus].\
      """

      assert Exception.message(error) == message
    end
  end

  describe "keyword schema with required property" do
    setup do
      %{
        schema: Xema.new({:keyword, properties: %{foo: :number}, required: [:foo]})
      }
    end

    test "validate/2 with required property (atom key)", %{schema: schema} do
      assert validate(schema, foo: 44) == :ok
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   required: [:foo]
                 }
               } = error
             } = validate(schema, missing: 44)

      assert Exception.message(error) == "Required properties are missing: [:foo]."
    end
  end

  describe "keyword schema with required properties" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{a: :number, b: :number, c: :number}, required: [:a, :b, :c]
          })
      }
    end

    test "validate/2 without required properties", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   required: required
                 }
               } = error
             } = validate(schema, b: 3, d: 8)

      assert Enum.sort(required) == [:a, :c]

      assert Exception.message(error) =~ "Required properties are missing:"
    end
  end

  describe "keyword schema with pattern properties" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            pattern_properties: %{
              ~r/^s_/ => :string,
              ~r/^i_/ => :number
            },
            additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, s_1: "foo", i_1: 42) == :ok
    end

    test "validate/2 with invalid map", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     x_1: %{additional_properties: false}
                   }
                 }
               } = error
             } = validate(schema, x_1: 44)

      assert Exception.message(error) == "Expected only defined properties, got key [:x_1]."
    end
  end

  describe "keyword schema with pattern properties (string key)" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            pattern_properties: %{
              "^s_" => :string,
              "^i_" => :number
            },
            additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, s_1: "foo", i_1: 42) == :ok
    end

    test "validate/2 with invalid map", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     x_1: %{additional_properties: false}
                   }
                 }
               } = error
             } = validate(schema, x_1: 44)

      assert Exception.message(error) == "Expected only defined properties, got key [:x_1]."
    end
  end

  describe "map schema with pattern properties (atom key)" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            pattern_properties: %{
              "^s_": :string,
              "^i_": :number
            },
            additional_properties: false
          })
      }
    end

    test "validate/2 with valid map", %{schema: schema} do
      assert validate(schema, s_1: "foo", i_1: 42) == :ok
    end

    test "validate/2 with invalid keyword list", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     x_1: %{additional_properties: false}
                   }
                 }
               } = error
             } = validate(schema, x_1: 44)

      assert Exception.message(error) == "Expected only defined properties, got key [:x_1]."
    end
  end

  describe "keyword schema with property names like keywords" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{
              map: :number,
              items: :number,
              properties: :number
            }
          })
      }
    end

    test "validate/2 with valid keyword list", %{schema: schema} do
      assert validate(schema, map: 3, items: 5, properties: 4) == :ok
    end
  end

  describe "keyword schema with dependencies property: " do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
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
      assert validate(schema, a: 1) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, a: 1, b: 2, c: 3) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   dependencies: %{
                     b: :c
                   }
                 }
               } = error
             } = validate(schema, a: 1, b: 2)

      assert Exception.message(error) == "Dependencies for :b failed. Missing required key :c."
    end
  end

  describe "keyword schema with dependencies list" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{
              a: :number,
              b: :number,
              c: :number
            },
            dependencies: %{
              b: [:c]
            }
          })
      }
    end

    test "validate/2 without dependency", %{schema: schema} do
      assert validate(schema, a: 1) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, a: 1, b: 2, c: 3) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   dependencies: %{b: :c}
                 }
               } = error
             } = validate(schema, a: 1, b: 2)

      assert Exception.message(error) == "Dependencies for :b failed. Missing required key :c."
    end
  end

  describe "keyword schema with dependencies schema" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{
              a: :number,
              b: :number
            },
            dependencies: %{
              b: {
                :keyword,
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
      assert validate(schema, a: 1) == :ok
    end

    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, a: 1, b: 2, c: 3) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert {
               :error,
               %ValidationError{reason: %{dependencies: %{b: %{required: [:c]}}}} = error
             } = validate(schema, a: 1, b: 2)

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
            :keyword,
            dependencies: %{
              penny: [:pound]
            }
          })
      }
    end

    test "a cent", %{schema: schema} do
      assert valid?(schema, cent: 1)
    end

    test "a pound", %{schema: schema} do
      assert valid?(schema, pound: 1)
    end

    test "a penny and a pound", %{schema: schema} do
      assert valid?(schema, penny: 1, pound: 1)
    end

    test "a penny", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{dependencies: %{penny: :pound}}
               } = error
             } = validate(schema, penny: 1)

      assert Exception.message(error) ==
               "Dependencies for :penny failed. Missing required key :pound."
    end
  end

  describe "keyword schema with if then else" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             if: [properties: %{a: :integer}],
             then: [properties: %{b: :string}],
             else: [properties: %{b: :integer}]}
          )
      }
    end

    test "validate/2 with a valid keyword list and then branch", %{schema: schema} do
      assert validate(schema, a: 1, b: "2") == :ok
    end

    test "validate/2 with a valid keyword list and else branch", %{schema: schema} do
      assert validate(schema, a: "1", b: 2) == :ok
    end

    test "validate/2 with an invalid keyword list", %{schema: schema} do
      assert {:error, error} = validate(schema, a: "1", b: "2")

      assert error == %ValidationError{
               message: nil,
               reason: %{
                 else: %{properties: %{b: %{type: :integer, value: "2"}}}
               }
             }

      message = """
      Schema for else does not match.
        Expected :integer, got "2", at [:b].\
      """

      assert Exception.message(error) == message
    end
  end

  describe "validate/2 property names" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            property_names: [min_length: 3]
          })
      }
    end

    test "with valid keys", %{schema: schema} do
      data = [foo: 1, bar: 2]

      assert validate(schema, data) == :ok
    end

    test "with invalid atom keys", %{schema: schema} do
      data = [foo: 1, a: 2, b: 3]

      assert {
               :error,
               %ValidationError{
                 reason: %{
                   value: values,
                   property_names: [
                     a: %{min_length: 3, value: "a"},
                     b: %{min_length: 3, value: "b"}
                   ]
                 }
               } = error
             } = validate(schema, data)

      assert Enum.sort(values) == [:a, :b, :foo]

      message = """
      Invalid property names.
        :a : Expected minimum length of 3, got "a".
        :b : Expected minimum length of 3, got "b".\
      """

      assert Exception.message(error) == message
    end
  end

  describe "keyword schema with multiple rules" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             properties: %{foo: :integer, bar: :integer},
             max_properties: 3,
             pattern_properties: %{~r/str_.*/ => :string},
             additional_properties: false}
          )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      assert validate(schema, foo: 5, str_a: "a") == :ok
    end

    test "validate/2 with invalid property", %{schema: schema} do
      assert validate(schema, foo: :bar) ==
               {:error,
                %Xema.ValidationError{
                  message: nil,
                  reason: %{properties: %{foo: %{type: :integer, value: :bar}}}
                }}
    end

    test "validate/2 with invalid pattern property", %{schema: schema} do
      assert validate(schema, foo: 1, str_bar: :bar) ==
               {:error,
                %Xema.ValidationError{
                  message: nil,
                  reason: %{properties: %{str_bar: %{type: :string, value: :bar}}}
                }}
    end

    test "validate/2 with additional property", %{schema: schema} do
      assert validate(schema, foo: 5, baz: 5) ==
               {:error,
                %Xema.ValidationError{
                  message: nil,
                  reason: %{properties: %{baz: %{additional_properties: false}}}
                }}
    end

    test "validate/2 with invalid properties", %{schema: schema} do
      assert {:error, error} = validate(schema, foo: "foo", str_a: 42, add: :more)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 properties: %{
                   add: %{additional_properties: false},
                   foo: %{type: :integer, value: "foo"},
                   str_a: %{type: :string, value: 42}
                 }
               }
             }

      assert Exception.message(error) ==
               """
               Expected only defined properties, got key [:add].
               Expected :integer, got \"foo\", at [:foo].
               Expected :string, got 42, at [:str_a].\
               """
    end

    test "validate/2 with too many properties", %{schema: schema} do
      assert validate(schema, foo: :bar, baz: 5, str_a: "a", str_b: "b", z: 1) ==
               {
                 :error,
                 %Xema.ValidationError{
                   __exception__: true,
                   message: nil,
                   reason: %{
                     max_properties: 3,
                     value: [foo: :bar, baz: 5, str_a: "a", str_b: "b", z: 1]
                   }
                 }
               }
    end
  end
end
