defmodule JsonSchemaTestSuite.Draft7.MultipleOfTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|by int| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"multipleOf" => 2},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|int by int|, %{schema: schema} do
      assert valid?(schema, 10)
    end

    test ~s|int by int fail|, %{schema: schema} do
      refute valid?(schema, 7)
    end

    test ~s|ignores non-numbers|, %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end

  describe ~s|by number| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"multipleOf" => 1.5},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|zero is multiple of anything|, %{schema: schema} do
      assert valid?(schema, 0)
    end

    test ~s|4.5 is multiple of 1.5|, %{schema: schema} do
      assert valid?(schema, 4.5)
    end

    test ~s|35 is not multiple of 1.5|, %{schema: schema} do
      refute valid?(schema, 35)
    end
  end

  describe ~s|by small number| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"multipleOf" => 0.0001},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|0.0075 is multiple of 0.0001|, %{schema: schema} do
      assert valid?(schema, 0.0075)
    end

    test ~s|0.00751 is not multiple of 0.0001|, %{schema: schema} do
      refute valid?(schema, 0.00751)
    end
  end
end
