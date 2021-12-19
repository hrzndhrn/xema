defmodule Xema.FromJsonSchemaTest do
  use ExUnit.Case, async: true

  alias Xema.Schema

  describe "Xema.from_json_schema/2" do
    test "with a simple schema" do
      json_schema =
        """
        { "type": "integer", "minimum": 5, "multipleOf": 5 }
        """
        |> Jason.decode!()

      assert Xema.from_json_schema(json_schema) ==
               %Xema{schema: %Schema{minimum: 5, multiple_of: 5, type: :integer}}
    end

    test "with properties" do
      json_schema =
        """
        {
          "type": "object",
          "properties": {
            "foo": {"type": "integer"}
           }
        }
        """
        |> Jason.decode!()

      assert Xema.from_json_schema(json_schema) ==
               %Xema{
                 refs: %{},
                 schema: %Schema{
                   properties: %{"foo" => %Schema{type: :integer}},
                   type: :map,
                   keys: :strings
                 }
               }
    end

    test "with additional data" do
      json_schema =
        """
        {
          "type": "object",
          "zonk": "bla",
          "properties": {
            "foo": {"type": "integer"}
          }
        }
        """
        |> Jason.decode!()

      assert Xema.from_json_schema(json_schema, atom: :force) ==
               %Xema{
                 refs: %{},
                 schema: %Xema.Schema{
                   data: %{zonk: "bla"},
                   properties: %{"foo" => %Xema.Schema{type: :integer}},
                   type: :map,
                   keys: :strings
                 }
               }
    end

    test "with an supported format value" do
      json_schema =
        """
        {"format": "email"}
        """
        |> Jason.decode!()

      assert Xema.from_json_schema(json_schema) == %Xema{
               refs: %{},
               schema: %Xema.Schema{format: :email}
             }
    end

    test "with an unsupported format value" do
      json_schema =
        """
        {"format": "unsupported"}
        """
        |> Jason.decode!()

      assert Xema.from_json_schema(json_schema) == %Xema{
               refs: %{},
               schema: %Xema.Schema{format: :unsupported}
             }
    end

    test "can cast from a json schema" do
      json_schema =
        """
          {
            "additionalProperties": false,
            "properties": {
              "foo": { "type": "string" },
              "bar": { "items": { "type": "string" }, "type": "array" },
              "baz": { "type": "object", "properties": {"prop": { "type": "string" } } }
            },
            "required": ["foo", "bar"],
            "type": "object"
          }
        """
        |> Jason.decode!()
        |> Xema.from_json_schema()

      data = %{"foo" => "somestring", "bar" => ["a", "b"]}
      assert Xema.validate(json_schema, data) == :ok
      assert Xema.cast(json_schema, data) == {:ok, data}
    end
  end
end
