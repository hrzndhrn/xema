defmodule Xema.JsonSchemaTest do
  use ExUnit.Case, async: true

  doctest Xema.JsonSchema

  alias Xema.{
    JsonSchema,
    SchemaError
  }

  test "converts a simple type to an type atom" do
    json_schema = """
    { "type": "string" }
    """

    assert to_xema(json_schema) == :string
  end

  test "converts rules to keyword list" do
    json_schema = """
    { "type": "integer", "minimum": 5, "multipleOf": 5 }
    """

    assert to_xema(json_schema) == {:integer, minimum: 5, multiple_of: 5}
  end

  test "converts object to map" do
    json_schema = """
    { "type": "object" }
    """

    assert to_xema(json_schema) == :map
  end

  test "converts properties" do
    json_schema = """
    {
      "type": "object",
      "properties": {
        "number": { "type": "number" }
      }
    }
    """

    assert to_xema(json_schema) == {:map, keys: :strings, properties: %{"number" => :number}}
  end

  test "none schema" do
    # make the atoms existing
    [:a, :b, :c]

    json_schema = """
    {"a": {"b": {"c": "none"}}}
    """

    assert to_xema(json_schema) == {:any, [a: [b: [c: "none"]]]}
  end

  test "nested schema" do
    # make the atoms existing
    [:a, :b, :c]

    json_schema = """
    {"a": {"b": {"c": {"type": "number", "minimum": 5}}}}
    """

    assert to_xema(json_schema) == {:any, [a: [b: [c: {:number, [minimum: 5]}]]]}
  end

  test "missing key" do
    refute atom_exists?("xyz")

    json_schema = """
    {"xyz": {"b": {"c": {"type": "number", "minimum": 5}}}}
    """

    message = "All additional schema keys must be existing atoms. Missing atom for xyz"

    assert_raise Xema.SchemaError, message, fn ->
      to_xema(json_schema)
    end
  end

  test "option atom: :force" do
    refute atom_exists?("xyz_force")

    json_schema = """
    {"xyz_force": {"b_force": {"c_force": {"type": "number", "minimum": 5}}}}
    """

    assert {:any, _} = to_xema(json_schema, atom: :force)
  end

  test "check against draft4 with an invalid schema" do
    assert_raise Xema.SchemaError, fn ->
      to_xema(~s|{"minimum": "5"}|, draft: "draft4")
    end
  end

  test "check against draft4 with a valid schema" do
    assert to_xema(~s|{"minimum": 5}|, draft: "draft4") == {:any, [minimum: 5]}
  end

  test "check against draft6 with a valid schema" do
    assert to_xema(~s|{"minimum": 5}|, draft: "draft6") == {:any, [minimum: 5]}
  end

  test "check against draft7 with a valid schema" do
    assert to_xema(~s|{"minimum": 5}|, draft: "draft7") == {:any, [minimum: 5]}
  end

  test "check against unknown schema" do
    message = ~s|unknown draft "foo", has to be one of ["draft4", "draft6", "draft7"]|

    assert_raise RuntimeError, message, fn ->
      to_xema(~s|{"minimum": 5}|, draft: "foo") == {:any, [minimum: 5]}
    end
  end

  test "check against $schema with a valid schema" do
    json_schema = """
    {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "maximum": 5,
      "exclusiveMaximum": true
    }
    """

    assert to_xema(json_schema) ==
             {:any,
              [
                schema: "http://json-schema.org/draft-04/schema#",
                exclusive_maximum: true,
                maximum: 5
              ]}
  end

  test "check against $schema with an invalid schema" do
    json_schema = """
    {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "maximum": 5,
      "exclusiveMaximum": true
    }
    """

    assert_raise SchemaError, fn ->
      to_xema(json_schema)
    end
  end

  defp to_xema(json_schema, opts \\ []) do
    json_schema |> Jason.decode!() |> JsonSchema.to_xema(opts)
  end

  defp atom_exists?(str) do
    is_atom(String.to_existing_atom(str))
  rescue
    _ -> false
  end
end
