defmodule Xema.JsonSchemaTest do
  use ExUnit.Case, async: true

  import Xema.JsonSchema

  test "converts a simple type to an type atom" do
    json_schema = """
    { "type": "string" }
    """

    assert xema(json_schema) == :string
  end

  test "converts rules to keyword list" do
    json_schema = """
    { "type": "integer", "minimum": 5, "multipleOf": 5 }
    """

    assert xema(json_schema) == {:integer, minimum: 5, multiple_of: 5}
  end

  test "converts object to map" do
    json_schema = """
    { "type": "object" }
    """

    assert xema(json_schema) == :map
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

    assert xema(json_schema) == {:map, properties: %{"number" => :number}}
  end

  test "none schema" do
    # make the atoms existing
    [:a, :b, :c]

    json_schema = """
    {"a": {"b": {"c": "none"}}}
    """

    assert xema(json_schema) == {:any, [a: [b: [c: "none"]]]}
  end

  test "nested schema" do
    # make the atoms existing
    [:a, :b, :c]

    json_schema = """
    {"a": {"b": {"c": {"type": "number", "minimum": 5}}}}
    """

    assert xema(json_schema) == {:any, [a: [b: [c: {:number, [minimum: 5]}]]]}
  end

  test "missing key" do
    json_schema = """
    {"xyz": {"b": {"c": {"type": "number", "minimum": 5}}}}
    """

    message = "All additional schema keys must be existing atoms. Missing atom for xyz"

    assert_raise Xema.SchemaError, message, fn ->
      xema(json_schema)
    end
  end

  defp xema(json_schema), do: json_schema |> Jason.decode!() |> to_xema()
end
