defmodule Xema.KeywordTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  describe "empty keyword schema" do
    setup do
      %{schema: Xema.new(:keyword)}
    end

    test "validate/2 with an empty keyword list", %{schema: schema} do
      assert validate(schema, []) == :ok
    end

    test "validate/2 with a string", %{schema: schema} do
      expected = {:error, %{type: :keyword, value: "foo"}}

      assert validate(schema, "foo") == expected
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, foo: 42, bar: 66)
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute valid?(schema, 55)
    end
  end

  describe "keyword schema with properties (atom keys)" do
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
      assert validate(schema, foo: "foo", bar: "bar") ==
               {:error,
                %{
                  properties: %{
                    foo: %{type: :number, value: "foo"}
                  }
                }}

      assert validate(schema, foo: "foo", bar: 2) ==
               {:error,
                %{
                  properties: %{
                    foo: %{type: :number, value: "foo"},
                    bar: %{type: :string, value: 2}
                  }
                }}
    end
  end

  describe "keyword schema with properties (string keys)" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{
              "foo" => :number,
              "bar" => :string
            }
          })
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, foo: 2, bar: "bar") == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert validate(schema, foo: "foo", bar: "bar") ==
               {:error,
                %{
                  properties: %{
                    foo: %{type: :number, value: "foo"}
                  }
                }}
    end
  end

  describe "keyword schema with min/max properties" do
    setup do
      %{schema: Xema.new({:keyword, min_properties: 2, max_properties: 3})}
    end

    test "validate/2 with too less properties", %{schema: schema} do
      assert validate(schema, foo: 42) == {:error, %{min_properties: 2}}
    end

    test "validate/2 with valid amount of properties", %{schema: schema} do
      assert validate(schema, foo: 42, bar: 44) == :ok
    end

    test "validate/2 with too many properties", %{schema: schema} do
      assert validate(schema, a: 1, b: 2, c: 3, d: 4) ==
               {:error, %{max_properties: 3}}
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
      assert validate(schema, foo: 44, add: 1) ==
               {:error,
                %{
                  properties: %{
                    add: %{additional_properties: false}
                  }
                }}
    end

    test "validate/2 with additional properties", %{schema: schema} do
      assert validate(schema, foo: 44, add: 1, plus: 3) ==
               {:error,
                %{
                  properties: %{
                    add: %{additional_properties: false},
                    plus: %{additional_properties: false}
                  }
                }}
    end
  end

  describe "map schema with specific additional properties" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{foo: {:string, min_length: 3}},
            additional_properties: :integer
          })
      }
    end

    test "validate/2 with valid additional property", %{schema: schema} do
      assert validate(schema, foo: "foo", add: 1) == :ok
    end

    test "validate/2 with invalid additional property", %{schema: schema} do
      assert validate(schema, foo: "foo", add: "invalid") ==
               {
                 :error,
                 %{
                   add: %{type: :integer, value: "invalid"}
                 }
               }
    end

    test "validate/2 with invalid additional properties", %{schema: schema} do
      assert validate(schema, foo: "foo", add: "invalid", plus: "+") ==
               {
                 :error,
                 %{
                   add: %{type: :integer, value: "invalid"},
                   plus: %{type: :integer, value: "+"}
                 }
               }
    end
  end

  describe "keyword schema with required property" do
    setup do
      %{
        schema:
          Xema.new({:keyword, properties: %{foo: :number}, required: [:foo]})
      }
    end

    test "validate/2 with required property (atom key)", %{schema: schema} do
      assert validate(schema, foo: 44) == :ok
    end

    test "validate/2 with missing key", %{schema: schema} do
      assert validate(schema, missing: 44) ==
               {:error,
                %{
                  required: [:foo]
                }}
    end
  end

  describe "keyword schema with required properties" do
    setup do
      %{
        schema:
          Xema.new({
            :keyword,
            properties: %{a: :number, b: :number, c: :number},
            required: [:a, :b, :c]
          })
      }
    end

    test "validate/2 without required properties", %{schema: schema} do
      assert validate(schema, b: 3, d: 8) ==
               {:error,
                %{
                  required: [:a, :c]
                }}
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
      assert validate(schema, x_1: 44) ==
               {:error,
                %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }}
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
      assert validate(schema, x_1: 44) ==
               {:error,
                %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }}
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
      assert validate(schema, x_1: 44) ==
               {:error,
                %{
                  properties: %{
                    x_1: %{additional_properties: false}
                  }
                }}
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
      assert validate(schema, a: 1, b: 2) ==
               {:error,
                %{
                  dependencies: %{
                    b: :c
                  }
                }}
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
      assert validate(schema, a: 1, b: 2) ==
               {:error,
                %{
                  dependencies: %{b: :c}
                }}
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

    @tag :only
    test "validate/2 with dependency", %{schema: schema} do
      assert validate(schema, a: 1, b: 2, c: 3) == :ok
    end

    test "validate/2 with missing dependency", %{schema: schema} do
      assert validate(schema, a: 1, b: 2) ==
               {:error, %{dependencies: %{b: %{required: [:c]}}}}
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
      assert validate(schema, penny: 1) ==
               {:error, %{dependencies: %{penny: :pound}}}
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

      assert validate(schema, data) ==
               {:error,
                %{
                  value: [:a, :b],
                  property_names: Xema.new(min_length: 3).schema
                }}
    end
  end
end
