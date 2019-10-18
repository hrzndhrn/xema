defmodule Xema.JsonSchema.ValidatorTest do
  use ExUnit.Case

  doctest Xema.JsonSchema.Validator

  alias Xema.{
    JsonSchema.Validator,
    ValidationError
  }

  test "validate with schema http://json-schema.org/draft-04/schema# with a valid schema" do
    assert Validator.validate("http://json-schema.org/draft-04/schema#", %{"minimum" => 5}) == :ok
  end

  test "validate with schema http://json-schema.org/draft-06/schema# with a valid schema" do
    assert Validator.validate("http://json-schema.org/draft-06/schema#", %{"minimum" => 5}) == :ok
  end

  test "validate with schema http://json-schema.org/draft-07/schema# with a valid schema" do
    assert Validator.validate("http://json-schema.org/draft-07/schema#", %{"minimum" => 5}) == :ok
  end

  test "validate with schema http://json-schema.org/draft-04/schema# with an invalid schema" do
    assert Validator.validate("http://json-schema.org/draft-04/schema#", %{"minimum" => "5"}) ==
             {:error,
              %ValidationError{
                reason: %{
                  properties: %{"minimum" => %{type: :number, value: "5"}}
                }
              }}
  end

  test "validate with schema http://json-schema.org/draft-06/schema# with an invalid schema" do
    assert Validator.validate("http://json-schema.org/draft-06/schema#", %{"minimum" => "5"}) ==
             {:error,
              %ValidationError{
                reason: %{
                  properties: %{"minimum" => %{type: :number, value: "5"}}
                }
              }}
  end

  test "validate with schema http://json-schema.org/draft-07/schema# with an invalid schema" do
    assert Validator.validate("http://json-schema.org/draft-07/schema#", %{"minimum" => "5"}) ==
             {:error,
              %ValidationError{
                reason: %{
                  properties: %{"minimum" => %{type: :number, value: "5"}}
                }
              }}
  end
end
