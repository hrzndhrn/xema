defmodule Xema.RefTest do
  use ExUnit.Case, async: true

  alias Xema.Ref

  import Xema, only: [validate: 2]

  describe "schema without keyword ref" do
    setup do
      %{
        schema:
          Xema.new(:properties, %{
            foo: :integer
          })
      }
    end

    test "get/2 returns the pointed schema", %{schema: schema} do
      ref = Ref.new(pointer: "#/properties/foo")
      assert Ref.get(ref, schema) == {:ok, Xema.new(:integer).content}
    end

    test "get/2 returns an error tuple for an invalid pointer", %{
      schema: schema
    } do
      ref = Ref.new(pointer: "#/properties/bar")
      assert Ref.get(ref, schema) == {:error, :not_found}
    end

    test "get/2 returns the root schema for #", %{schema: schema} do
      ref = Ref.new(pointer: "#")
      assert Ref.get(ref, schema) == {:ok, schema.content}
    end
  end

  describe "schema with ref root pointer" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            properties: %{
              foo: {:ref, "#"}
            },
            additional_properties: false
          )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      assert validate(schema, %{foo: 1}) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      assert validate(schema, %{bar: 1}) ==
               {:error, %{properties: %{bar: %{additional_properties: false}}}}
    end

    test "validate/2 with recursive valid data", %{schema: schema} do
      assert validate(schema, %{foo: %{foo: %{foo: 3}}}) == :ok
    end

    test "validate/2 with recursive invalid data", %{schema: schema} do
      assert validate(schema, %{foo: %{foo: %{bar: 3}}}) ==
               {:error,
                %{
                  properties: %{
                    foo: %{
                      properties: %{
                        foo: %{
                          properties: %{bar: %{additional_properties: false}}
                        }
                      }
                    }
                  }
                }}
    end
  end

  describe "schema with ref" do
    setup do
      %{
        schema:
          Xema.new(:properties, %{
            foo: :integer,
            bar: {:ref, "#/properties/foo"}
          })
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      assert validate(schema, %{foo: 42}) == :ok
      assert validate(schema, %{bar: 42}) == :ok
      assert validate(schema, %{foo: 21, bar: 42}) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      assert validate(schema, %{foo: "42"}) ==
               {:error, %{properties: %{foo: %{type: :integer, value: "42"}}}}

      assert validate(schema, %{bar: "42"}) ==
               {:error, %{properties: %{bar: %{type: :integer, value: "42"}}}}

      assert validate(schema, %{foo: "21", bar: "42"}) ==
               {:error,
                %{
                  properties: %{
                    bar: %{type: :integer, value: "42"},
                    foo: %{type: :integer, value: "21"}
                  }
                }}
    end
  end
end
