defmodule Xema.MapTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 3]

  alias Xema.ValidationError

  test "throws ArgumentError for invalid fail option" do
    message = "the optional option :fail must be one of [:immediately, :early, :finally] when set"
    assert_raise ArgumentError, message, fn -> validate(Xema.new(:integer), 5, fail: :unknown) end
  end

  describe "multiple invalid data in a map" do
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
          multi: Map.put(%{foo: :bar, baz: 5, str_a: "a", str_b: "b"}, "z", 1)
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
  end
end
