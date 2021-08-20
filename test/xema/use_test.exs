defmodule Xema.UseTest do
  use ExUnit.Case, async: true

  alias Xema.{CastError, Schema, SchemaError, ValidationError}

  test "use Xema with multiple schema and option multi false raises error" do
    message = "Use `use Xema, multi: true` to setup multiple schema in a module."

    assert_raise RuntimeError, message, fn ->
      defmodule MultiError do
        use Xema

        xema :int, do: integer()

        xema :str, do: string()
      end
    end
  end

  describe "module with one schema" do
    defmodule UserSchema do
      use Xema

      xema :user do
        map(
          properties: %{
            name: string(min_length: 1),
            age: integer(minimum: 0)
          }
        )
      end
    end

    test "valild?/2 returns true for a valid user" do
      assert UserSchema.valid?(:user, %{name: "Nick", age: 24})
    end

    test "valild?/1 returns true for a valid user" do
      assert UserSchema.valid?(%{name: "Nick", age: 24})
    end

    test "cast/1 returns casted data" do
      assert UserSchema.cast(%{name: "Nick", age: "42"}) == {:ok, %{age: 42, name: "Nick"}}
    end

    test "cast/1 returns an error tuple with CastError for invalid data" do
      assert {:error,
              %Xema.CastError{
                key: nil,
                path: [:name],
                to: :string,
                value: []
              } = error} = UserSchema.cast(%{name: [], age: "42"})

      assert Exception.message(error) == "cannot cast [] to :string at [:name]"
    end

    test "cast/1 returns an error tuple with ValidationError for invalid data" do
      assert {:error,
              %Xema.ValidationError{
                reason: %{properties: %{age: %{minimum: 0, value: -42}}}
              } = error} = UserSchema.cast(%{name: "Nick", age: "-42"})

      assert Exception.message(error) == "Value -42 is less than minimum value of 0, at [:age]."
    end

    test "cast!/1 returns casted data" do
      assert UserSchema.cast!(%{name: "Nick", age: "42"}) == %{age: 42, name: "Nick"}
    end
  end

  describe "module with one schema and xema/0" do
    defmodule PersonSchema do
      use Xema

      xema do
        map(
          properties: %{
            name: string(min_length: 1),
            age: integer(minimum: 0)
          }
        )
      end
    end

    test "valild?/1 returns true for a valid user" do
      assert PersonSchema.valid?(%{name: "Nick", age: 24})
    end

    test "cast/1 returns casted data" do
      assert PersonSchema.cast(%{name: "Nick", age: "42"}) == {:ok, %{age: 42, name: "Nick"}}
    end
  end

  describe "module with multiple schemas" do
    defmodule Schema do
      use Xema, multi: true

      @pos integer(minimum: 0)
      @neg integer(maximum: 0)

      xema :user do
        map(
          properties: %{
            name: string(min_length: 1),
            age: @pos
          }
        )
      end

      @default true
      xema :person do
        keyword(
          properties: %{
            name: string(min_length: 1),
            age: @pos
          }
        )
      end

      xema :nums do
        map(
          properties: %{
            pos: list(items: @pos),
            neg: list(items: @neg)
          }
        )
      end
    end

    test "valid?/2 returns true for a valid person" do
      assert Schema.valid?(:person, name: "John", age: 21)
    end

    test "valid?/2 returns false for an invalid person" do
      refute Schema.valid?(:person, name: "John", age: -21)
    end

    test "valid?/1 returns true for a valid person" do
      assert Schema.valid?(name: "John", age: 21)
    end

    test "valid?/1 returns false for an invalid person" do
      refute Schema.valid?(name: "John", age: -21)
    end

    test "valid?/2 returns true for a valid user" do
      assert Schema.valid?(:user, %{name: "John", age: 21})
    end

    test "valid?/2 returns true for a valid nums map" do
      assert Schema.valid?(:nums, %{pos: [1, 2, 3], neg: [-5, -4]})
    end

    test "valid?/2 returns false for an invalid user" do
      refute Schema.valid?(:user, %{name: "", age: 21})
    end

    test "valid?/2 returns false for an invalid nums map" do
      refute Schema.valid?(:nums, %{pos: [1, -2, 3], neg: [-5, -4]})
    end

    test "validate/1 returns :ok for a valid person" do
      assert Schema.validate(name: "John", age: 21) == :ok
    end

    test "validate/1 returns an error tuple for an invalid person" do
      assert {
               :error,
               %ValidationError{
                 reason: %{properties: %{age: %{minimum: 0, value: -21}}}
               } = error
             } = Schema.validate(name: "John", age: -21)

      assert Exception.message(error) == "Value -21 is less than minimum value of 0, at [:age]."
    end

    test "validate/2 returns :ok for a valid user" do
      assert Schema.validate(:user, %{name: "John", age: 21}) == :ok
    end

    test "validate/2 returns :ok for a valid nums map" do
      assert Schema.validate(:nums, %{pos: [1, 2, 3], neg: [-5, -4]}) == :ok
    end

    test "validate/2 returns an error tuple for an invalid user" do
      assert {
               :error,
               %ValidationError{
                 reason: %{properties: %{name: %{min_length: 1, value: ""}}}
               } = error
             } = Schema.validate(:user, %{name: "", age: 21})

      assert Exception.message(error) == ~s|Expected minimum length of 1, got "", at [:name].|
    end

    test "validate/2 returns an error tuple for an invalid nums map" do
      assert {
               :error,
               %ValidationError{
                 reason: %{properties: %{pos: %{items: %{1 => %{minimum: 0, value: -2}}}}}
               } = error
             } = Schema.validate(:nums, %{pos: [1, -2, 3], neg: [-5, -4]})

      assert Exception.message(error) == "Value -2 is less than minimum value of 0, at [:pos, 1]."
    end

    test "validate!/2 raises a ValidationError for an invalid user" do
      assert_raise ValidationError, fn ->
        Schema.validate!(:user, %{name: "", age: 21})
      end
    end

    test "validate!/2 raises a ValidationError for an invalid nums map" do
      assert_raise ValidationError, fn ->
        Schema.validate!(:nums, %{pos: [1, -2, 3], neg: [-5, -4]})
      end
    end

    test "validate!/1 returns :ok for a valid person" do
      assert Schema.validate!(name: "John", age: 21) == :ok
    end

    test "validate!/1 raises a ValidationError for an invalid person" do
      assert_raise ValidationError, fn ->
        Schema.validate!(age: -1)
      end
    end

    test "cast/2 returns casted data" do
      assert Schema.cast(:nums, %{pos: [1, "2"], neg: [-5, "-4"]}) ==
               {:ok, %{neg: [-5, -4], pos: [1, 2]}}
    end

    test "cast!/2 returns casted data" do
      assert Schema.cast!(:nums, %{pos: [1, "2"], neg: [-5, "-4"]}) ==
               %{neg: [-5, -4], pos: [1, 2]}
    end
  end

  describe "struct schema with strux" do
    defmodule UserStrux do
      use Xema

      defstruct [:name, :age]

      xema do
        strux(
          module: UserStrux,
          properties: %{
            name: string(min_length: 1),
            age: integer(minimum: 0)
          }
        )
      end
    end

    test "cast!/1" do
      assert UserStrux.cast!(name: "Nick", age: 21) == %UserStrux{name: "Nick", age: 21}
    end

    test "xema/0" do
      assert UserStrux.xema() == %Xema{
               refs: %{},
               schema: %Schema{
                 module: Xema.UseTest.UserStrux,
                 properties: %{
                   age: %Schema{minimum: 0, type: :integer},
                   name: %Schema{min_length: 1, type: :string}
                 },
                 type: :struct
               }
             }
    end
  end

  describe "struct schema with one field and without keywords" do
    defmodule OneFieldWithoutKeywords do
      use Xema

      xema do
        field :age, :integer
      end
    end

    test "cast!/1" do
      assert OneFieldWithoutKeywords.cast!(%{"age" => "5"}) == %OneFieldWithoutKeywords{age: 5}
    end
  end

  describe "struct schema with one field and with keywords" do
    defmodule OneFieldWithKeywords do
      use Xema

      xema do
        field :age, :integer, minimum: 0
      end
    end

    test "cast!/1" do
      assert OneFieldWithKeywords.cast!(%{"age" => "5"}) == %OneFieldWithKeywords{age: 5}
    end
  end

  describe "struct schema with fields" do
    defmodule UserStruct do
      use Xema

      xema do
        field :name, :string, min_length: 1
        field :age, [:integer, nil], minimum: 0
        required [:age]
      end
    end

    test "xema/0" do
      assert UserStruct.xema() == %Xema{
               refs: %{},
               schema: %Schema{
                 module: Xema.UseTest.UserStruct,
                 properties: %{
                   age: %Schema{minimum: 0, type: [:integer, nil]},
                   name: %Schema{min_length: 1, type: :string}
                 },
                 required: MapSet.new([:age]),
                 type: :struct,
                 keys: :atoms
               }
             }
    end

    test "cast!/1" do
      assert UserStruct.cast!(name: "Nick", age: 21) == %UserStruct{name: "Nick", age: 21}

      assert UserStruct.cast!(%{"name" => "Nick", "age" => "21"}) == %UserStruct{
               name: "Nick",
               age: 21
             }
    end

    test "cast/1 with invalid data" do
      assert {:error, error} = UserStruct.cast(name: "", age: -1)

      assert Exception.message(error) == """
             Value -1 is less than minimum value of 0, at [:age].
             Expected minimum length of 1, got "", at [:name].\
             """
    end

    test "cast/1 with missing age" do
      assert {:error, error} = UserStruct.cast(name: "Nick")

      assert error ==
               %CastError{
                 path: [],
                 required: [:age],
                 to: Xema.UseTest.UserStruct,
                 value: [name: "Nick"]
               }

      assert Exception.message(error) ==
               ~s|cannot cast [name: "Nick"] to Xema.UseTest.UserStruct| <>
                 ~s| missing required keys [:age]|
    end

    test "cast/1 from a map with missing age" do
      assert {:error, error} = UserStruct.cast(%{name: "Nick"})

      assert error ==
               %CastError{
                 path: [],
                 required: [:age],
                 to: Xema.UseTest.UserStruct,
                 value: %{name: "Nick"}
               }

      assert Exception.message(error) ==
               ~s|cannot cast %{name: "Nick"} to Xema.UseTest.UserStruct| <>
                 ~s| missing required keys [:age]|
    end

    test "cast/1 from a map with string keys and missing age" do
      assert {:error, error} = UserStruct.cast(%{"name" => "Nick"})

      assert error ==
               %CastError{
                 path: [],
                 required: [:age],
                 to: Xema.UseTest.UserStruct,
                 value: %{"name" => "Nick"}
               }

      assert Exception.message(error) ==
               ~s|cannot cast %{"name" => "Nick"} to Xema.UseTest.UserStruct| <>
                 ~s| missing required keys [:age]|
    end

    test "cast/1 from a map with string keys, missing age and an unknown property" do
      assert {:error, error} = UserStruct.cast(%{"name" => "Nick", "xyz" => 5})

      assert error ==
               %CastError{
                 path: [],
                 required: [:age],
                 to: Xema.UseTest.UserStruct,
                 value: %{"name" => "Nick", "xyz" => 5}
               }
    end

    test "validate/1" do
      assert {:error, error} = UserStruct.validate(%UserStruct{name: "Nix", age: -1})
      assert Exception.message(error) == "Value -1 is less than minimum value of 0, at [:age]."
    end
  end

  describe "xema/0" do
    test "raises ArgumentError for multiple required functions" do
      code =
        quote do
          defmodule MultiRequired do
            use Xema

            xema do
              field :foo, :integer, minimum: 0
              required [:foo]
              required [:foo]
            end
          end
        end

      message = "the required function can only be called once per xema"

      assert_raise ArgumentError, message, fn ->
        Code.eval_quoted(code)
      end
    end

    test "raises ArgumentError for invalid type in field" do
      code =
        quote do
          defmodule MultiRequired do
            use Xema

            xema do
              field :foo, %{}, minimum: 0
            end
          end
        end

      message = "invalid type %{} for field :foo"

      assert_raise ArgumentError, message, fn ->
        Code.eval_quoted(code)
      end
    end

    test "raises ArgumentError for invalid argument in field" do
      code =
        quote do
          defmodule MultiRequired do
            use Xema

            xema do
              field :foo, "bar", minimum: 0
            end
          end
        end

      message = ~s|invalid type "bar" for field :foo|

      assert_raise ArgumentError, message, fn ->
        Code.eval_quoted(code)
      end
    end

    test "raises SchemaError for missing module" do
      code =
        quote do
          defmodule MissingBehaviour do
            use Xema

            xema do
              field :foo, Foo
            end
          end
        end

      message = "Module Foo not compiled"

      assert_raise SchemaError, message, fn ->
        Code.eval_quoted(code)
      end
    end

    test "raises SchemaError for invalid module" do
      code =
        quote do
          defmodule Bad do
            # empty
          end

          defmodule BadBehaviour do
            use Xema

            xema do
              field :grants, :list, items: Bad, default: []
            end
          end
        end

      message = "Module Bad is not a Xema behaviour"

      assert_raise SchemaError, message, fn ->
        Code.eval_quoted(code)
      end
    end
  end

  describe "allow nil property" do
    defmodule AllowFoo do
      use Xema

      xema do
        field :a, :integer, allow: nil
      end
    end

    defmodule AllowBar do
      use Xema

      xema do
        field :foo, AllowFoo, allow: nil
      end
    end

    test "with a valid value struct" do
      assert AllowBar.valid?(%AllowBar{foo: %AllowFoo{a: 5}}) == true
    end

    test "with an invalid value struct" do
      assert AllowBar.valid?(%AllowBar{foo: %AllowFoo{a: "5"}}) == false
    end

    test "with nil instead of a struct" do
      assert AllowBar.valid?(%AllowBar{}) == true
    end
  end

  describe "allow multiple types to extend struct" do
    defmodule AllowMultiFoo do
      use Xema

      xema do
        field :a, :integer
      end
    end

    defmodule AllowMultiBar do
      use Xema

      xema do
        field :foo, AllowMultiFoo, allow: [:integer, nil]
      end
    end

    test "with a valid value struct" do
      assert AllowMultiBar.valid?(%AllowMultiBar{foo: %AllowMultiFoo{a: 5}}) == true
    end

    test "with a valid integer" do
      assert AllowMultiBar.valid?(%AllowMultiBar{foo: 5}) == true
    end

    test "with a valid nil" do
      assert AllowMultiBar.valid?(%AllowMultiBar{}) == true
    end

    test "with an invalid value" do
      assert AllowMultiBar.valid?(%AllowMultiBar{foo: :foo}) == false
    end
  end

  describe "allow multiple types to extend basic type" do
    defmodule AllowMulti do
      use Xema

      xema do
        field :a, :integer, allow: [:string, :boolean]
      end
    end

    test "with a valid integer value" do
      assert AllowMulti.valid?(%AllowMulti{a: 5}) == true
    end

    test "with a valid string value" do
      assert AllowMulti.valid?(%AllowMulti{a: "5"}) == true
    end

    test "with a valid boolean value" do
      assert AllowMulti.valid?(%AllowMulti{a: false}) == true
    end

    test "with an invalid value" do
      assert AllowMulti.valid?(%AllowMulti{a: :foo}) == false
    end
  end

  describe "allow type to extend multiple types" do
    defmodule AllowToMulti do
      use Xema

      xema do
        field :a, [:integer, :boolean], allow: :string
      end
    end

    test "with a valid integer value" do
      assert AllowToMulti.valid?(%AllowToMulti{a: 5}) == true
    end

    test "with a valid string value" do
      assert AllowToMulti.valid?(%AllowToMulti{a: "5"}) == true
    end

    test "with a valid boolean value" do
      assert AllowToMulti.valid?(%AllowToMulti{a: false}) == true
    end

    test "with an invalid value" do
      assert AllowToMulti.valid?(%AllowToMulti{a: :foo}) == false
    end
  end

  describe "allow multiple types to extend multiple types" do
    defmodule AllowMultiMulti do
      use Xema

      xema do
        field :a, [:integer], allow: [:string, :boolean]
      end
    end

    test "with a valid integer value" do
      assert AllowMultiMulti.valid?(%AllowMultiMulti{a: 5}) == true
    end

    test "with a valid string value" do
      assert AllowMultiMulti.valid?(%AllowMultiMulti{a: "5"}) == true
    end

    test "with a valid boolean value" do
      assert AllowMultiMulti.valid?(%AllowMultiMulti{a: false}) == true
    end

    test "with an invalid value" do
      assert AllowMultiMulti.valid?(%AllowMultiMulti{a: :foo}) == false
    end
  end
end
