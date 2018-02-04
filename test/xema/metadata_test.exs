defmodule Xema.MetadataTest do
  use ExUnit.Case, async: true

  test "schema with metadta" do
    schema =
      Xema.new(
        :any,
        id: "ID",
        schema: "elixir-schema",
        title: "Just for fun",
        description: "Code for fun"
      )

    assert schema.content.id == "ID"
    assert schema.content.schema == "elixir-schema"
    assert schema.content.title == "Just for fun"
    assert schema.content.description == "Code for fun"
  end
end
