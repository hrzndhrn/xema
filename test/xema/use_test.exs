defmodule Xema.UseTest do
  use ExUnit.Case, async: true

  alias Xema.ValidationError

  test "use Xema with multiple schema and option multi false raises error" do
    message = "Use `use Xema, multi: true` to setup multiple schema in a module."

    assert_raise RuntimeError, message, fn ->
      defmodule MultiError do
        use Xema

        xema :int, integer()

        xema :str, string()
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

    test "valild?/2 returns true for a valied user" do
      assert UserSchema.valid?(:user, %{name: "Nick", age: 24})
    end

    test "valild?/1 returns true for a valied user" do
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

    test "cast/1 returns an errot tuple with ValidationError for invalid data" do
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

  describe "module with multiple schemas" do
    defmodule Schema do
      use Xema, multi: true

      @pos integer(minimum: 0)
      @neg integer(maximum: 0)

      xema :user,
           map(
             properties: %{
               name: string(min_length: 1),
               age: @pos
             }
           )

      @default true
      xema :person,
           keyword(
             properties: %{
               name: string(min_length: 1),
               age: @pos
             }
           )

      xema :nums,
           map(
             properties: %{
               pos: list(items: @pos),
               neg: list(items: @neg)
             }
           )
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
                 reason: %{properties: %{pos: %{items: [{1, %{minimum: 0, value: -2}}]}}}
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
end
