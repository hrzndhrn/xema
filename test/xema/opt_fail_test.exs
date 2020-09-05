defmodule Xema.MapTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 3]

  alias Xema.ValidationError

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
        data: Map.put(%{foo: :bar, baz: 5, str_a: "a", str_b: "b"}, "z", 1)
      }
    end

    test "with [fail: :finally]", %{schema: schema, data: data} do
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
