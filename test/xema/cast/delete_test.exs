defmodule Xema.Cast.DeleteTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 3]

  alias Xema.ValidationError

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
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, [a: 1, b: 2]}
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
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, [a: 1, b: 2]}
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
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, [a: 1]}
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, [a: 1]}
    end

    test "deletes additional properties from a keyword list", %{schema: schema} do
      assert cast(schema, [a: "1", x: "2"], @opts) == {:ok, [a: 1]}
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

    test "converts the given properties", %{schema: schema} do
      assert {:error, error} = cast(schema, %{a: "1", b: "2"}, @opts)

      assert error == %ValidationError{
               message: nil,
               reason: %{one_of: {:ok, [0, 1]}, value: %{a: 1, b: 2}}
             }
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, %{a: 1}}
    end

    test "deletes additional properties from a keyword list", %{schema: schema} do
      assert cast(schema, [a: "1", x: "2"], @opts) == {:ok, %{a: 1}}
    end
  end

  describe "cast/3 with pattern properties" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            pattern_properties: %{
              ~r/^s_/ => :string,
              ~r/^i_/ => :number
            },
            additional_properties: false
          })
      }
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{s_1: "str", i_1: 5, f_1: 5.5}, @opts) == {:ok, %{s_1: "str", i_1: 5}}
    end
  end

  describe "cast/3 with pattern properties and properties" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              s_1: :string
            },
            pattern_properties: %{
              ~r/^i_/ => :number
            },
            additional_properties: false
          })
      }
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{s_1: "str", i_1: 5, f_1: 5.5}, @opts) == {:ok, %{}}
    end
  end
end
