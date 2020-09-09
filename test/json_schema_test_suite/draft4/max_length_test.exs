defmodule JsonSchemaTestSuite.Draft4.MaxLengthTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|maxLength validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"maxLength" => 2},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|shorter is valid|, %{schema: schema} do
      assert valid?(schema, "f")
    end

    test ~s|exact length is valid|, %{schema: schema} do
      assert valid?(schema, "fo")
    end

    test ~s|too long is invalid|, %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test ~s|ignores non-strings|, %{schema: schema} do
      assert valid?(schema, 100)
    end

    test ~s|two supplementary Unicode code points is long enough|, %{schema: schema} do
      assert valid?(schema, "💩💩")
    end
  end
end
