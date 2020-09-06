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

      assert Exception.message(error) ==
               ~s|Expected at most 3 properties, | <>
                 ~s|got %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}.|
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

      assert Exception.message(error) ==
               ~s|Expected at most 3 properties, | <>
                 ~s|got %{:baz => 5, :foo => :bar, :str_a => "a", :str_b => "b", "z" => 1}.|
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

      assert Exception.message(error) ==
               ~s|Expected at most 3 properties, | <>
                 ~s|got %{bar: "bar", foo: 1, more: :things, str_baz: 4}.|
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

      assert Exception.message(error) ==
               ~s|Expected at most 3 properties, | <>
                 ~s|got %{bar: \"bar\", foo: 1, more: :things, str_baz: 4}.|
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

      assert Exception.message(error) ==
               ~s|Expected at most 3 properties, | <>
                 ~s|got [foo: 1, bar: "bar", str_baz: 4, more: :things].|
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
end
