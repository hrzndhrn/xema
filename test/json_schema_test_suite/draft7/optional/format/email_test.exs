defmodule JsonSchemaTestSuite.Draft7.Optional.Format.EmailTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of e-mail addresses" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "email"},
            draft: "draft7"
          )
      }
    end

    test "a valid e-mail address", %{schema: schema} do
      assert valid?(schema, "joe.bloggs@example.com")
    end

    test "an invalid e-mail address", %{schema: schema} do
      refute valid?(schema, "2962")
    end
  end
end
