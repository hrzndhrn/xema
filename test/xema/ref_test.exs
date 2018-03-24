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

  describe "schema with a ref to property" do
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

  describe "schema with ref and definitions" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: {:ref, "#/definitions/pos"},
              bar: {:ref, "#/definitions/neg"}
            },
            definitions: %{
              pos: {:integer, minimum: 0},
              neg: {:integer, maximum: 0}
            }
          )
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert Xema.validate(schema, %{foo: 5, bar: -1}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert Xema.validate(schema, %{foo: -1, bar: 1}) ==
               {:error,
                %{
                  properties: %{
                    bar: %{maximum: 0, value: 1},
                    foo: %{minimum: 0, value: -1}
                  }
                }}
    end
  end

  describe "schema with ref chain" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: {:ref, "#/definitions/bar"}
            },
            definitions: %{
              bar: {:ref, "#/definitions/pos"},
              pos: {:integer, minimum: 0}
            }
          )
      }
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert Xema.validate(schema, %{foo: 42}) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert Xema.validate(schema, %{foo: -21}) ==
               {:error, %{properties: %{foo: %{minimum: 0, value: -21}}}}
    end
  end

  describe "schema with ref as keyword" do
    setup do
      %{
        schema:
          Xema.new(
            ref: "#/definitions/pos",
            definitions: %{
              pos: {:integer, minimum: 0}
            }
          )
      }
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert Xema.validate(schema, 42) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert Xema.validate(schema, -42) == {:error, %{minimum: 0, value: -42}}
    end
  end

  describe "schema with ref to id" do
    setup do
      %{
        schema:
          Xema.new(
            id: "http://foo.com",
            ref: "pos",
            definitions: %{
              pos: {:integer, minimum: 0, id: "http://foo.com/pos"}
            }
          )
      }
    end

    @tag :only
    test "validate/2 with valid value", %{schema: schema} do
      # IO.inspect(schema)
      assert Xema.validate(schema, 42) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert Xema.validate(schema, -42) == {:error, %{minimum: 0, value: -42}}
    end
  end
end
