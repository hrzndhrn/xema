defmodule JsonSchemaTestSuite.Draft6.Optional.Format.EmailTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of e-mail addresses| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "email"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|a valid e-mail address|, %{schema: schema} do
      assert valid?(schema, "joe.bloggs@example.com")
    end

    test ~s|an invalid e-mail address|, %{schema: schema} do
      refute valid?(schema, "2962")
    end

    test ~s|tilde in local part is valid|, %{schema: schema} do
      assert valid?(schema, "te~st@example.com")
    end

    test ~s|tilde before local part is valid|, %{schema: schema} do
      assert valid?(schema, "~test@example.com")
    end

    test ~s|tilde after local part is valid|, %{schema: schema} do
      assert valid?(schema, "test~@example.com")
    end

    test ~s|dot before local part is not valid|, %{schema: schema} do
      refute valid?(schema, ".test@example.com")
    end

    test ~s|dot after local part is not valid|, %{schema: schema} do
      refute valid?(schema, "test.@example.com")
    end

    test ~s|two separated dots inside local part are valid|, %{schema: schema} do
      assert valid?(schema, "te.s.t@example.com")
    end

    test ~s|two subsequent dots inside local part are not valid|, %{schema: schema} do
      refute valid?(schema, "te..st@example.com")
    end
  end
end
