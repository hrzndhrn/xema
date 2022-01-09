defmodule Xema.Cast.OneOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2]

  alias Xema.{CastError, ValidationError}

  describe "cast/2 with one_of schema with types" do
    setup do
      %{
        schema: Xema.new(one_of: [:integer, :string, nil])
      }
    end

    test "from an integer", %{schema: schema} do
      assert cast(schema, 6) == {:ok, 6}
    end

    test "from an integer string", %{schema: schema} do
      assert cast(schema, "9") == {:ok, 9}
    end

    test "from a string", %{schema: schema} do
      assert cast(schema, "nine") == {:ok, "nine"}
    end

    test "from a nil", %{schema: schema} do
      assert cast(schema, nil) == {:ok, nil}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 5.5) == {:ok, "5.5"}
    end

    test "from an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, [])

      assert error == %CastError{
               path: [],
               to: [
                 %{path: [], to: :integer, value: []},
                 %{path: [], to: :string, value: []},
                 %{path: [], to: nil, value: []}
               ],
               value: []
             }

      assert Exception.message(error) ==
               """
               cannot cast [] to any of:
                 cannot cast [] to :integer
                 cannot cast [] to :string
                 cannot cast [] to nil\
               """
    end
  end

  describe "cast/2 with one_of schema with properties" do
    setup do
      %{
        schema:
          Xema.new(
            one_of: [
              [properties: %{a: :string}],
              [properties: %{b: :integer}]
            ]
          )
      }
    end

    test "from a map", %{schema: schema} do
      assert cast(schema, %{a: 1, b: "2"}) == {:ok, %{a: "1", b: "2"}}
    end

    test "from a map with an invalid value", %{schema: schema} do
      assert cast(schema, %{a: 1, b: 1.5}) == {:ok, %{a: "1", b: 1.5}}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, a: 1, b: "2") == {:ok, [a: "1", b: "2"]}
    end
  end

  describe "cast/2 with one_of schema with multiple properties" do
    setup do
      %{
        schema:
          Xema.new(
            one_of: [
              [properties: %{a: :integer}],
              [properties: %{a: :string}],
              [properties: %{a: nil}]
            ]
          )
      }
    end

    test "from a map with an integer", %{schema: schema} do
      assert cast(schema, %{a: 1}) == {:ok, %{a: 1}}
    end

    test "from a map with an integer string", %{schema: schema} do
      assert cast(schema, %{a: "2"}) == {:ok, %{a: 2}}
    end

    test "from a map with a string", %{schema: schema} do
      assert cast(schema, %{a: "three"}) == {:ok, %{a: "three"}}
    end

    test "from a map with a nil", %{schema: schema} do
      assert cast(schema, %{a: nil}) == {:ok, %{a: nil}}
    end

    test "from a map with an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, %{a: []})

      message = """
      cannot cast %{a: []} to any of:
        cannot cast [] to :integer at [:a]
        cannot cast [] to :string at [:a]
        cannot cast [] to nil at [:a]\
      """

      assert Exception.message(error) == message

      assert error ==
               %CastError{
                 error: nil,
                 key: nil,
                 message: nil,
                 path: [],
                 to: [
                   %{path: [:a], to: :integer, value: []},
                   %{path: [:a], to: :string, value: []},
                   %{path: [:a], to: nil, value: []}
                 ],
                 value: %{a: []}
               }
    end
  end

  describe "cast/2 with xema modules" do
    defmodule OneOf.Foo do
      use Xema

      xema_struct do
        field :value, :atom, const: :foo
      end
    end

    defmodule OneOf.Bar do
      use Xema

      xema_struct do
        field :value, :atom, const: :bar
      end
    end

    defmodule OneOf.FooBar do
      use Xema

      xema_struct do
        field :foobar, :any, one_of: [OneOf.Foo, OneOf.Bar]
      end
    end

    test "casts valid data to foobar: Foo" do
      assert OneOf.FooBar.cast(%{foobar: %{value: :foo}}) ==
               {:ok, %OneOf.FooBar{foobar: %OneOf.Foo{value: :foo}}}
    end

    test "casts valid data to foobar: Bar" do
      assert OneOf.FooBar.cast(%{foobar: %{value: :bar}}) ==
               {:ok, %OneOf.FooBar{foobar: %OneOf.Bar{value: :bar}}}
    end

    test "returns an error for invalid data" do
      {:error, error} = OneOf.FooBar.cast(%{foobar: %{value: :baz}})

      assert Exception.message(error) == """
             cannot cast %{value: :baz} at [:foobar] to any of:
               cannot cast %{value: :baz} to Xema.Cast.OneOfTest.OneOf.Foo - \
             Expected :foo, got :baz, at [:value].
               cannot cast %{value: :baz} to Xema.Cast.OneOfTest.OneOf.Bar - \
             Expected :bar, got :baz, at [:value].\
             """

      assert error == %CastError{
               path: [:foobar],
               to: [
                 %{
                   reason: %ValidationError{
                     __exception__: true,
                     message: nil,
                     reason: %{properties: %{value: %{const: :foo, value: :baz}}}
                   },
                   module: Xema.Cast.OneOfTest.OneOf.Foo,
                   to: :struct,
                   value: %{value: :baz}
                 },
                 %{
                   reason: %ValidationError{
                     __exception__: true,
                     message: nil,
                     reason: %{properties: %{value: %{const: :bar, value: :baz}}}
                   },
                   module: Xema.Cast.OneOfTest.OneOf.Bar,
                   to: :struct,
                   value: %{value: :baz}
                 }
               ],
               value: %{value: :baz}
             }
    end
  end
end
