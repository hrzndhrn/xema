defmodule Xema.MetadataTest do
  use ExUnit.Case, async: true

  import Xema

  test "schema with metadta" do
    schema =
      xema(
        :any,
        id: "ID",
        schema: "elixir-schema",
        title: "Just for fun",
        description: "Code for fun"
      )

    assert schema.id == "ID"
    assert schema.schema == "elixir-schema"
    assert schema.title == "Just for fun"
    assert schema.description == "Code for fun"
  end
end
