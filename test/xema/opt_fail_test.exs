defmodule Xema.OptFailTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 3]

  alias Xema.ValidationError

  test "throws ArgumentError for invalid fail option" do
    message = "the optional option :fail must be one of [:immediately, :early, :finally] when set"
    assert_raise ArgumentError, message, fn -> validate(Xema.new(:integer), 5, fail: :unknown) end
  end

  describe "map schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             keys: :atoms,
             properties: %{foo: :integer, bar: :integer},
             max_properties: 3,
             pattern_properties: %{~r/str_.*/ => :string},
             additional_properties: false}
          ),
        valid: %{foo: 5, bar: 7},
        invalid: %{
          multi: Map.put(%{foo: :bar, baz: 5, str_a: "a", str_b: "b"}, "z", 1),
          properties: %{foo: "foo", bar: "bar"},
          pattern: %{foo: 1, bar: "bar", str_baz: 4, more: :things}
        }
      }
    end

    test "validate/3 with valid data", %{schema: schema, valid: data} do
      assert validate(schema, data, fail: :immediately) == :ok
      assert validate(schema, data, fail: :early) == :ok
      assert validate(schema, data, fail: :finally) == :ok
    end

    test "validate/3 with [fail: :immediately] and invalid.multi",
         %{schema: schema, invalid: %{multi: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 max_properties: 3,
                 value: %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}
               }
             }

      assert Exception.message(error) == """
             Expected at most 3 properties, \
             got %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}.\
             """
    end

    test "validate/3 with [fail: :early] and invalid.multi",
         %{schema: schema, invalid: %{multi: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 max_properties: 3,
                 value: %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}
               }
             }

      assert Exception.message(error) == """
             Expected at most 3 properties, \
             got %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}.\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.multi",
         %{schema: schema, invalid: %{multi: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: [
                   %{
                     properties: %{
                       :baz => %{additional_properties: false},
                       :foo => %{type: :integer, value: :bar},
                       "z" => %{additional_properties: false}
                     }
                   },
                   %{
                     keys: :atoms,
                     value: %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}
                   },
                   %{
                     max_properties: 3,
                     value: %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}
                   }
                 ]
               }

      got = ~s|got %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}.|

      assert Exception.message(error) == """
             Expected at most 3 properties, #{got}
             Expected :atoms as key, #{got}
             Expected only defined properties, got key [:baz].
             Expected :integer, got :bar, at [:foo].
             Expected only defined properties, got key [\"z\"].\
             """
    end

    test "validate/3 with [fail: :immediately] and invalid.properties",
         %{schema: schema, invalid: %{properties: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{properties: %{bar: %{type: :integer, value: "bar"}}}
             }

      assert Exception.message(error) == """
             Expected :integer, got "bar", at [:bar].\
             """
    end

    test "validate/3 with [fail: :early] and invalid.propertes",
         %{schema: schema, invalid: %{properties: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: %{
                   properties: %{
                     foo: %{
                       type: :integer,
                       value: "foo"
                     },
                     bar: %{type: :integer, value: "bar"}
                   }
                 }
               }

      assert Exception.message(error) == """
             Expected :integer, got "bar", at [:bar].
             Expected :integer, got "foo", at [:foo].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.properties",
         %{schema: schema, invalid: %{properties: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: [
                   %{
                     properties: %{
                       foo: %{
                         type: :integer,
                         value: "foo"
                       },
                       bar: %{type: :integer, value: "bar"}
                     }
                   }
                 ]
               }

      assert Exception.message(error) == """
             Expected :integer, got "bar", at [:bar].
             Expected :integer, got "foo", at [:foo].\
             """
    end

    test "validate/3 with [fail: :immediately] and invalid.pattern",
         %{schema: schema, invalid: %{pattern: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 max_properties: 3,
                 value: %{bar: "bar", foo: 1, more: :things, str_baz: 4}
               }
             }

      assert Exception.message(error) == """
             Expected at most 3 properties, \
             got %{bar: "bar", foo: 1, more: :things, str_baz: 4}.\
             """
    end

    test "validate/3 with [fail: :early] and invalid.pattern",
         %{schema: schema, invalid: %{pattern: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: %{
                   max_properties: 3,
                   value: %{bar: "bar", foo: 1, more: :things, str_baz: 4}
                 }
               }

      assert Exception.message(error) == """
             Expected at most 3 properties, \
             got %{bar: \"bar\", foo: 1, more: :things, str_baz: 4}.\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.pattern",
         %{schema: schema, invalid: %{pattern: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: [
                   %{
                     properties: %{
                       bar: %{
                         type: :integer,
                         value: "bar"
                       },
                       more: %{additional_properties: false},
                       str_baz: %{type: :string, value: 4}
                     }
                   },
                   %{max_properties: 3, value: %{bar: "bar", foo: 1, more: :things, str_baz: 4}}
                 ]
               }

      assert Exception.message(error) == """
             Expected at most 3 properties, got %{bar: "bar", foo: 1, more: :things, str_baz: 4}.
             Expected :integer, got "bar", at [:bar].
             Expected only defined properties, got key [:more].
             Expected :string, got 4, at [:str_baz].\
             """
    end
  end

  describe "keyword schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             properties: %{foo: :integer, bar: :integer},
             pattern_properties: %{~r/str_.*/ => :string},
             max_properties: 3,
             additional_properties: false}
          ),
        valid: [foo: 5, bar: 7, str_foo: "foo"],
        invalid: %{
          multi: [foo: 1, bar: "bar", str_baz: 4, more: :things],
          properties: [foo: "foo", bar: "bar", str_baz: 6]
        }
      }
    end

    test "validate/3 with valid data", %{schema: schema, valid: data} do
      assert validate(schema, data, fail: :immediately) == :ok
      assert validate(schema, data, fail: :early) == :ok
      assert validate(schema, data, fail: :finally) == :ok
    end

    test "validate/3 with [fail: :immediately] and invalid.multi",
         %{schema: schema, invalid: %{multi: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 max_properties: 3,
                 value: [foo: 1, bar: "bar", str_baz: 4, more: :things]
               }
             }

      assert Exception.message(error) == """
             Expected at most 3 properties, \
             got [foo: 1, bar: "bar", str_baz: 4, more: :things].\
             """
    end

    test "validate/3 with [fail: :early] and invalid.multi",
         %{schema: schema, invalid: %{multi: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 max_properties: 3,
                 value: [foo: 1, bar: "bar", str_baz: 4, more: :things]
               }
             }

      assert Exception.message(error) == """
             Expected at most 3 properties, got [foo: 1, bar: "bar", str_baz: 4, more: :things].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.multi",
         %{schema: schema, invalid: %{multi: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: [
                   %{
                     properties: %{
                       bar: %{type: :integer, value: "bar"},
                       more: %{additional_properties: false},
                       str_baz: %{type: :string, value: 4}
                     }
                   },
                   %{max_properties: 3, value: [foo: 1, bar: "bar", str_baz: 4, more: :things]}
                 ]
               }

      assert Exception.message(error) == """
             Expected at most 3 properties, got [foo: 1, bar: \"bar\", str_baz: 4, more: :things].
             Expected :integer, got "bar", at [:bar].
             Expected only defined properties, got key [:more].
             Expected :string, got 4, at [:str_baz].\
             """
    end

    test "validate/3 with [fail: :immediately] and invalid.properties",
         %{schema: schema, invalid: %{properties: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{properties: %{str_baz: %{type: :string, value: 6}}}
             }

      assert Exception.message(error) == """
             Expected :string, got 6, at [:str_baz].\
             """
    end

    test "validate/3 with [fail: :early] and invalid.propertes",
         %{schema: schema, invalid: %{properties: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: %{
                   properties: %{
                     bar: %{type: :integer, value: "bar"},
                     foo: %{type: :integer, value: "foo"},
                     str_baz: %{type: :string, value: 6}
                   }
                 }
               }

      assert Exception.message(error) == """
             Expected :integer, got "bar", at [:bar].
             Expected :integer, got "foo", at [:foo].
             Expected :string, got 6, at [:str_baz].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.properties",
         %{schema: schema, invalid: %{properties: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error ==
               %ValidationError{
                 __exception__: true,
                 message: nil,
                 reason: [
                   %{
                     properties: %{
                       bar: %{type: :integer, value: "bar"},
                       foo: %{type: :integer, value: "foo"},
                       str_baz: %{type: :string, value: 6}
                     }
                   }
                 ]
               }

      assert Exception.message(error) == """
             Expected :integer, got "bar", at [:bar].
             Expected :integer, got "foo", at [:foo].
             Expected :string, got 6, at [:str_baz].\
             """
    end
  end

  describe "list schema" do
    setup do
      %{
        schema: Xema.new({:list, max_items: 3, items: :integer, unique_items: true}),
        valid: [1, 2, 3],
        invalid: %{
          short: [1, "a", "b"],
          long: [1, "a", "b", 4],
          duplicate: [1, "a", "b", "a"]
        }
      }
    end

    test "validate/3 with valid data", %{schema: schema, valid: data} do
      assert validate(schema, data, fail: :immediately) == :ok
      assert validate(schema, data, fail: :early) == :ok
      assert validate(schema, data, fail: :finally) == :ok
    end

    test "validate/3 with [fail: :immediately] and invalid.short",
         %{schema: schema, invalid: %{short: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{items: %{1 => %{type: :integer, value: "a"}}}
             }

      assert Exception.message(error) == ~s|Expected :integer, got "a", at [1].|
    end

    test "validate/3 with [fail: :early] and invalid.short",
         %{schema: schema, invalid: %{short: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 items: %{
                   1 => %{type: :integer, value: "a"},
                   2 => %{type: :integer, value: "b"}
                 }
               }
             }

      assert Exception.message(error) == """
             Expected :integer, got "a", at [1].
             Expected :integer, got "b", at [2].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.short",
         %{schema: schema, invalid: %{short: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   items: %{
                     1 => %{type: :integer, value: "a"},
                     2 => %{type: :integer, value: "b"}
                   }
                 }
               ]
             }

      assert Exception.message(error) == """
             Expected :integer, got "a", at [1].
             Expected :integer, got "b", at [2].\
             """
    end

    test "validate/3 with [fail: :immediately] and invalid.long",
         %{schema: schema, invalid: %{long: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 max_items: 3,
                 value: [1, "a", "b", 4]
               }
             }

      assert Exception.message(error) == "Expected at most 3 items, got [1, \"a\", \"b\", 4]."
    end

    test "validate/3 with [fail: :early] and invalid.long",
         %{schema: schema, invalid: %{long: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 max_items: 3,
                 value: [1, "a", "b", 4]
               }
             }

      assert Exception.message(error) == "Expected at most 3 items, got [1, \"a\", \"b\", 4]."
    end

    test "validate/3 with [fail: :finally] and invalid.long",
         %{schema: schema, invalid: %{long: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   items: %{
                     1 => %{type: :integer, value: "a"},
                     2 => %{type: :integer, value: "b"}
                   }
                 },
                 %{max_items: 3, value: [1, "a", "b", 4]}
               ]
             }

      assert Exception.message(error) == """
             Expected at most 3 items, got [1, "a", "b", 4].
             Expected :integer, got "a", at [1].
             Expected :integer, got "b", at [2].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.duplicate",
         %{schema: schema, invalid: %{duplicate: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   items: %{
                     1 => %{type: :integer, value: "a"},
                     2 => %{type: :integer, value: "b"},
                     3 => %{type: :integer, value: "a"}
                   }
                 },
                 %{unique_items: true, value: [1, "a", "b", "a"]},
                 %{max_items: 3, value: [1, "a", "b", "a"]}
               ]
             }

      assert Exception.message(error) == """
             Expected at most 3 items, got [1, "a", "b", "a"].
             Expected unique items, got [1, "a", "b", "a"].
             Expected :integer, got "a", at [1].
             Expected :integer, got "b", at [2].
             Expected :integer, got "a", at [3].\
             """
    end
  end

  describe "list-tuple schema" do
    setup do
      %{
        schema:
          Xema.new({
            :list,
            items: [:integer, :integer, :string], unique_items: true, additional_items: false
          }),
        valid: [1, 2, "a"],
        invalid: %{
          short: [1, "a", 2],
          long: [1, "a", "b", 4],
          duplicate: [1, 2, 3, 1]
        }
      }
    end

    test "validate/3 with valid data", %{schema: schema, valid: data} do
      assert validate(schema, data, fail: :immediately) == :ok
      assert validate(schema, data, fail: :early) == :ok
      assert validate(schema, data, fail: :finally) == :ok
    end

    test "validate/3 with [fail: :immediately] and invalid.short",
         %{schema: schema, invalid: %{short: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{items: %{1 => %{type: :integer, value: "a"}}}
             }

      assert Exception.message(error) == ~s|Expected :integer, got "a", at [1].|
    end

    test "validate/3 with [fail: :early] and invalid.short",
         %{schema: schema, invalid: %{short: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 items: %{
                   1 => %{type: :integer, value: "a"},
                   2 => %{type: :string, value: 2}
                 }
               }
             }

      assert Exception.message(error) == """
             Expected :integer, got "a", at [1].
             Expected :string, got 2, at [2].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.short",
         %{schema: schema, invalid: %{short: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   items: %{
                     1 => %{type: :integer, value: "a"},
                     2 => %{type: :string, value: 2}
                   }
                 }
               ]
             }

      assert Exception.message(error) == """
             Expected :integer, got "a", at [1].
             Expected :string, got 2, at [2].\
             """
    end

    test "validate/3 with [fail: :immediately] and invalid.long",
         %{schema: schema, invalid: %{long: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 items: %{1 => %{type: :integer, value: "a"}}
               }
             }

      assert Exception.message(error) == ~s|Expected :integer, got "a", at [1].|
    end

    test "validate/3 with [fail: :early] and invalid.long",
         %{schema: schema, invalid: %{long: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 items: %{
                   1 => %{type: :integer, value: "a"},
                   3 => %{additional_items: false}
                 }
               }
             }

      assert Exception.message(error) == """
             Expected :integer, got "a", at [1].
             Unexpected additional item, at [3].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.long",
         %{schema: schema, invalid: %{long: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   items: %{
                     1 => %{type: :integer, value: "a"},
                     3 => %{additional_items: false}
                   }
                 }
               ]
             }

      assert Exception.message(error) == """
             Expected :integer, got "a", at [1].
             Unexpected additional item, at [3].\
             """
    end

    test "validate/3 with [fail: :finally] and invalid.duplicate",
         %{schema: schema, invalid: %{duplicate: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   items: %{
                     2 => %{type: :string, value: 3},
                     3 => %{additional_items: false}
                   }
                 },
                 %{
                   unique_items: true,
                   value: [1, 2, 3, 1]
                 }
               ]
             }

      assert Exception.message(error) == """
             Expected unique items, got [1, 2, 3, 1].
             Expected :string, got 3, at [2].
             Unexpected additional item, at [3].\
             """
    end
  end

  describe "all together" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             properties: %{
               a:
                 {:map,
                  keys: :atoms,
                  properties: %{foo: :integer, bar: :integer},
                  max_properties: 3,
                  pattern_properties: %{~r/str_.*/ => :string},
                  additional_properties: false},
               b:
                 {:keyword,
                  properties: %{foo: :integer, bar: :integer},
                  pattern_properties: %{~r/str_.*/ => :string},
                  max_properties: 3,
                  additional_properties: false},
               c: {:list, max_items: 3, items: :integer, unique_items: true},
               d:
                 {:list,
                  items: [:integer, :integer, :string],
                  unique_items: true,
                  additional_items: false}
             }}
          ),
        valid: %{
          a: %{foo: 5, bar: 9, str_baz: "baz"},
          b: [foo: 11, bar: 12, str_boo: "boo"],
          c: [1, 2, 3],
          d: [1, 2, "three"]
        },
        invalid: %{
          values: %{
            a: %{foo: "foo", bar: 9, str_baz: 7},
            b: [foo: 11, bar: "bar", str_boo: 11],
            c: [1, "2", "3"],
            d: ["1", 2, 3]
          },
          structure: %{
            a: %{foo: "foo", bar: 9, str_baz: 7, more: :things},
            b: [foo: 11, bar: "bar", str_boo: 11, another: :thing],
            c: [1, "2", "3", :next, 1],
            d: ["1", 2, 3, 2]
          }
        }
      }
    end

    test "validate/3 with valid data", %{schema: schema, valid: data} do
      assert validate(schema, data, fail: :immediately) == :ok
      assert validate(schema, data, fail: :early) == :ok
      assert validate(schema, data, fail: :finally) == :ok
    end

    test "validate/3 with [fail: :immediately] invalid.values",
         %{schema: schema, invalid: %{values: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 properties: %{
                   a: %{
                     properties: %{str_baz: %{type: :string, value: 7}}
                   }
                 }
               }
             }

      assert Exception.message(error) == "Expected :string, got 7, at [:a, :str_baz]."
    end

    test "validate/3 with [fail: :early] invalid.values",
         %{schema: schema, invalid: %{values: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 properties: %{
                   a: %{
                     properties: %{
                       foo: %{type: :integer, value: "foo"},
                       str_baz: %{type: :string, value: 7}
                     }
                   },
                   b: %{
                     properties: %{
                       bar: %{type: :integer, value: "bar"},
                       str_boo: %{type: :string, value: 11}
                     }
                   },
                   c: %{
                     items: %{
                       1 => %{type: :integer, value: "2"},
                       2 => %{type: :integer, value: "3"}
                     }
                   },
                   d: %{
                     items: %{
                       0 => %{type: :integer, value: "1"},
                       2 => %{type: :string, value: 3}
                     }
                   }
                 }
               }
             }

      assert Exception.message(error) == """
             Expected :integer, got "foo", at [:a, :foo].
             Expected :string, got 7, at [:a, :str_baz].
             Expected :integer, got "bar", at [:b, :bar].
             Expected :string, got 11, at [:b, :str_boo].
             Expected :integer, got "2", at [:c, 1].
             Expected :integer, got "3", at [:c, 2].
             Expected :integer, got "1", at [:d, 0].
             Expected :string, got 3, at [:d, 2].\
             """
    end

    test "validate/3 with [fail: :finally] invalid.values",
         %{schema: schema, invalid: %{values: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   properties: %{
                     a: [
                       %{
                         properties: %{
                           foo: %{type: :integer, value: "foo"},
                           str_baz: %{type: :string, value: 7}
                         }
                       }
                     ],
                     b: [
                       %{
                         properties: %{
                           bar: %{type: :integer, value: "bar"},
                           str_boo: %{type: :string, value: 11}
                         }
                       }
                     ],
                     c: [
                       %{
                         items: %{
                           1 => %{type: :integer, value: "2"},
                           2 => %{type: :integer, value: "3"}
                         }
                       }
                     ],
                     d: [
                       %{
                         items: %{
                           0 => %{type: :integer, value: "1"},
                           2 => %{type: :string, value: 3}
                         }
                       }
                     ]
                   }
                 }
               ]
             }

      assert Exception.message(error) == """
             Expected :integer, got "foo", at [:a, :foo].
             Expected :string, got 7, at [:a, :str_baz].
             Expected :integer, got "bar", at [:b, :bar].
             Expected :string, got 11, at [:b, :str_boo].
             Expected :integer, got "2", at [:c, 1].
             Expected :integer, got "3", at [:c, 2].
             Expected :integer, got "1", at [:d, 0].
             Expected :string, got 3, at [:d, 2].\
             """
    end

    test "validate/3 with [fail: :immediately] invalid.structure",
         %{schema: schema, invalid: %{structure: data}} do
      opts = [fail: :immediately]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 properties: %{
                   a: %{
                     max_properties: 3,
                     value: %{bar: 9, foo: "foo", more: :things, str_baz: 7}
                   }
                 }
               }
             }

      assert Exception.message(error) == """
             Expected at most 3 properties, \
             got %{bar: 9, foo: \"foo\", more: :things, str_baz: 7}, at [:a].\
             """
    end

    test "validate/3 with [fail: :early] invalid.structure",
         %{schema: schema, invalid: %{structure: data}} do
      opts = [fail: :early]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: %{
                 properties: %{
                   a: %{
                     max_properties: 3,
                     value: %{bar: 9, foo: "foo", more: :things, str_baz: 7}
                   },
                   b: %{
                     max_properties: 3,
                     value: [foo: 11, bar: "bar", str_boo: 11, another: :thing]
                   },
                   c: %{max_items: 3, value: [1, "2", "3", :next, 1]},
                   d: %{unique_items: true, value: ["1", 2, 3, 2]}
                 }
               }
             }

      got = %{
        a: ~s|got %{bar: 9, foo: "foo", more: :things, str_baz: 7}, at [:a].|,
        b: ~s|got [foo: 11, bar: "bar", str_boo: 11, another: :thing], at [:b].|
      }

      assert Exception.message(error) == """
             Expected at most 3 properties, #{got.a}
             Expected at most 3 properties, #{got.b}
             Expected at most 3 items, got [1, "2", "3", :next, 1], at [:c].
             Expected unique items, got ["1", 2, 3, 2], at [:d].\
             """
    end

    test "validate/3 with [fail: :finally] invalid.structure",
         %{schema: schema, invalid: %{structure: data}} do
      opts = [fail: :finally]

      assert {:error, error} = validate(schema, data, opts)

      assert error == %Xema.ValidationError{
               message: nil,
               reason: [
                 %{
                   properties: %{
                     a: [
                       %{
                         properties: %{
                           foo: %{type: :integer, value: "foo"},
                           more: %{additional_properties: false},
                           str_baz: %{type: :string, value: 7}
                         }
                       },
                       %{
                         max_properties: 3,
                         value: %{bar: 9, foo: "foo", more: :things, str_baz: 7}
                       }
                     ],
                     b: [
                       %{
                         properties: %{
                           another: %{additional_properties: false},
                           bar: %{type: :integer, value: "bar"},
                           str_boo: %{type: :string, value: 11}
                         }
                       },
                       %{
                         max_properties: 3,
                         value: [foo: 11, bar: "bar", str_boo: 11, another: :thing]
                       }
                     ],
                     c: [
                       %{
                         items: %{
                           1 => %{type: :integer, value: "2"},
                           2 => %{type: :integer, value: "3"},
                           3 => %{type: :integer, value: :next}
                         }
                       },
                       %{unique_items: true, value: [1, "2", "3", :next, 1]},
                       %{max_items: 3, value: [1, "2", "3", :next, 1]}
                     ],
                     d: [
                       %{
                         items: %{
                           0 => %{type: :integer, value: "1"},
                           2 => %{type: :string, value: 3},
                           3 => %{additional_items: false}
                         }
                       },
                       %{unique_items: true, value: ["1", 2, 3, 2]}
                     ]
                   }
                 }
               ]
             }

      got = %{
        a: ~s|got %{bar: 9, foo: "foo", more: :things, str_baz: 7}, at [:a].|,
        b: ~s|got [foo: 11, bar: "bar", str_boo: 11, another: :thing], at [:b].|
      }

      assert Exception.message(error) == """
             Expected at most 3 properties, #{got.a}
             Expected :integer, got "foo", at [:a, :foo].
             Expected only defined properties, got key [:a, :more].
             Expected :string, got 7, at [:a, :str_baz].
             Expected at most 3 properties, #{got.b}
             Expected only defined properties, got key [:b, :another].
             Expected :integer, got "bar", at [:b, :bar].
             Expected :string, got 11, at [:b, :str_boo].
             Expected at most 3 items, got [1, "2", "3", :next, 1], at [:c].
             Expected unique items, got [1, "2", "3", :next, 1], at [:c].
             Expected :integer, got "2", at [:c, 1].
             Expected :integer, got "3", at [:c, 2].
             Expected :integer, got :next, at [:c, 3].
             Expected unique items, got ["1", 2, 3, 2], at [:d].
             Expected :integer, got "1", at [:d, 0].
             Expected :string, got 3, at [:d, 2].
             Unexpected additional item, at [:d, 3].\
             """
    end
  end
end
