defmodule Xema.UseTest do
  use ExUnit.Case, async: true

  alias Xema.ValidationError

  defmodule Schema do
    use Xema

    @pos integer(minimum: 0)
    @neg integer(maximum: 0)

    defxema user,
            map(
              properties: %{
                name: string(min_length: 1),
                age: @pos
              }
            )

    defxema nums,
            map(
              properties: %{
                pos: list(items: @pos),
                neg: list(items: @neg)
              }
            )
  end

  test "user/0 returns Xema" do
    assert %Xema{} = Schema.user()
  end

  test "nums/0 returns Xema" do
    assert %Xema{} = Schema.nums()
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

  test "validate/2 returns :ok for a valid user" do
    assert Schema.validate(:user, %{name: "John", age: 21}) == :ok
  end

  test "validate/2 returns :ok for a valid nums map" do
    assert Schema.validate(:nums, %{pos: [1, 2, 3], neg: [-5, -4]}) == :ok
  end

  test "validate/2 returns an error tuple for an invalid user" do
    assert Schema.validate(:user, %{name: "", age: 21}) ==
             {:error, %{properties: %{name: %{min_length: 1, value: ""}}}}
  end

  test "validate/2 returns an error tuple for an invalid nums map" do
    assert Schema.validate(:nums, %{pos: [1, -2, 3], neg: [-5, -4]}) ==
             {:error,
              %{properties: %{pos: %{items: [{1, %{minimum: 0, value: -2}}]}}}}
  end

  test "validate!/2 raises a ValidationError for an invalid user" do
    assert_raise ValidationError, fn ->
      Schema.validate!(:user, %{name: "", age: 21}) ==
        {:error, %{properties: %{name: %{min_length: 1, value: ""}}}}
    end
  end

  test "validate!/2 raises a ValidationError for an invalid nums map" do
    assert_raise ValidationError, fn ->
      Schema.validate!(:nums, %{pos: [1, -2, 3], neg: [-5, -4]}) ==
        {:error,
         %{properties: %{pos: %{items: [{1, %{minimum: 0, value: -2}}]}}}}
    end
  end
end
