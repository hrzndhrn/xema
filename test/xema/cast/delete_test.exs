defmodule Xema.Cast.DeleteTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, cast: 3, validate: 2]

  alias Xema.{CastError, ValidationError}

  @opts [additional_properties: :delete]

  describe "cast/2 with map schema and option [additional_properties: :delete]" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             properties: %{
               a: :integer,
               b: :integer
             },
             additional_properties: false}
          )
      }
    end

    test "converts the given properties", %{schema: schema} do
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, %{a: 1, b: 2}}
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, %{a: 1}}
    end

    test "deletes additional properties from a keyword list", %{schema: schema} do
      assert cast(schema, [a: "1", x: "2"], @opts) == {:ok, %{a: 1}}
    end
  end

  describe "cast/2 with keyword schema and option [additional_properties: :delete]" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             properties: %{
               a: :integer,
               b: :integer
             },
             additional_properties: false}
          )
      }
    end

    test "converts the given properties", %{schema: schema} do
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, [b: 2, a: 1]}
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, [a: 1]}
    end

    test "deletes additional properties from a keyword list", %{schema: schema} do
      assert cast(schema, [a: "1", x: "2"], @opts) == {:ok, [a: 1]}
    end
  end

  describe "cast/2 with any_of schema and option [additional_properties: :delete]" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             any_of: [
               [
                 properties: %{
                   a: :integer,
                   b: :integer
                 },
                 additional_properties: false
               ]
             ]}
          )
      }
    end

    test "converts the given properties", %{schema: schema} do
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, [b: 2, a: 1]}
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, [a: 1]}
    end

    test "deletes additional properties from a keyword list", %{schema: schema} do
      assert cast(schema, [a: "1", x: "2"], @opts) == {:ok, [a: 1]}
    end
  end

  describe "cast/2 with any_of schema and options [additional_properties: :delete]" do
    setup do
      %{
        schema:
          Xema.new(
            {:keyword,
             any_of: [
               [
                 properties: %{
                   a: :integer
                 },
                 additional_properties: false
               ],
               [
                 properties: %{
                   b: :integer
                 },
                 additional_properties: false
               ]
             ]}
          )
      }
    end

    test "converts the given properties", %{schema: schema} do
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, []}
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, []}
    end

    test "deletes additional properties from a keyword list", %{schema: schema} do
      assert cast(schema, [a: "1", x: "2"], @opts) == {:ok, []}
    end
  end

  describe "cast/2 with either or schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             properties: %{
               a: :integer,
               b: :integer
             },
             additional_properties: false,
             one_of: [
               [required: [:a]],
               [required: [:b]]
             ]}
          )
      }
    end

    test "validate", %{schema: schema} do
      assert validate(schema, %{a: 5, b: 7}) == :error
    end

    test "converts the given properties", %{schema: schema} do
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, []}
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, %{a: 1}}
    end

    test "deletes additional properties from a keyword list", %{schema: schema} do
      assert cast(schema, [a: "1", x: "2"], @opts) == {:ok, %{a: 1}}
    end
  end
end
