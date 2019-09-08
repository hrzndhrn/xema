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

  @tag :only
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

  defp xema(json_schema), do: json_schema |> Jason.decode!() |> to_xema()
end
