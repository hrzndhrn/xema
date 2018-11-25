defmodule Xema.AnnotationsTest do
  use ExUnit.Case, async: true

  test "schema with metadta" do
    id = "ID"
    schema = "http://xema.org/version-0-5-0/schema#"
    title = "Just for fun"
    description = "Code for fun"
    examples = [%{test: "data"}]
    default = 42
    comment = "No"
    content_media_type = "media"
    content_encoding = "encoding"

    xema =
      Xema.new({
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
      })

    assert xema.schema.id == id
    assert xema.schema.schema == schema
    assert xema.schema.title == title
    assert xema.schema.description == description
    assert xema.schema.examples == examples
    assert xema.schema.default == default
    assert xema.schema.comment == comment
    assert xema.schema.content_media_type == content_media_type
    assert xema.schema.content_encoding == content_encoding
  end
end
