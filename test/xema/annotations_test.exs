defmodule Xema.AnnotationsTest do
  use ExUnit.Case, async: true

  test "schema with metadta" do
    id = "ID"
    schema = "elixir-schema"
    title = "Just for fun"
    description = "Code for fun"
    examples = [%{test: "data"}]
    default = 42
    comment = "No"
    content_media_type = "media"
    content_encoding = "encoding"

    xema =
      Xema.new(
        :any,
        id: id,
        schema: schema,
        title: title,
        description: description,
        examples: examples,
        default: default,
        comment: comment,
        content_media_type: content_media_type,
        content_encoding: content_encoding
      )

    assert xema.content.id == id
    assert xema.content.schema == schema
    assert xema.content.title == title
    assert xema.content.description == description
    assert xema.content.examples == examples
    assert xema.content.default == default
    assert xema.content.comment == comment
    assert xema.content.content_media_type == content_media_type
    assert xema.content.content_encoding == content_encoding
  end
end
