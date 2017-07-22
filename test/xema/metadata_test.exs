defmodule Xema.MetadataTest do

  use ExUnit.Case, async: true

  test "schema with metadta" do
    schema = Xema.create(
      :any,
      id: "ID",
      schema: "elixir-schema",
      title: "Just for fun",
      description: "Code for fun",
      default: "Currently ignored"
    )

    assert schema.id == "ID"
    assert schema.schema == "elixir-schema"
    assert schema.title == "Just for fun"
    assert schema.description == "Code for fun"
    assert schema.default == "Currently ignored"
  end
end
