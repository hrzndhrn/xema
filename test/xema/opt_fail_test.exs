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
        invalid: %{
          multi: Map.put(%{foo: :bar, baz: 5, str_a: "a", str_b: "b"}, "z", 1),
          properties: %{foo: "foo", bar: "bar"}
        }
      }
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
  end

  describe "list schema" do
    setup do
      %{
        schema: Xema.new({:list, items_max: 3, items: :integer, unique: true}),
        invalid: %{
          short: [1, "a", "b"],
          long: [1, "a", "b", 4],
          duplicate: [1, "a", "b", 1]
        }
      }
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

    test "validate/3 with [fail: :early] and invalid.short"
    test "validate/3 with [fail: :finally] and invalid.short"

    test "validate/3 with [fail: :immediately] and invalid.long",
    test "validate/3 with [fail: :early] and invalid.long",
    test "validate/3 with [fail: :finally] and invalid.long",

    test "validate/3 with [fail: :immediately] and invalid.duplicate",
    test "validate/3 with [fail: :early] and invalid.duplicate",
    test "validate/3 with [fail: :finally] and invalid.duplicate",
  end

  describe "list-tuple schema" do
    test "todo"
  end
end
