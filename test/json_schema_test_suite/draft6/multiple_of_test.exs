defmodule JsonSchemaTestSuite.Draft6.MultipleOfTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "by int" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"multipleOf" => 2},
            draft: "draft6"
          )
      }
    end

    test "int by int", %{schema: schema} do
      assert valid?(schema, 10)
    end

    test "int by int fail", %{schema: schema} do
      refute valid?(schema, 7)
    end

    test "ignores non-numbers", %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end

  describe "by number" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"multipleOf" => 1.5},
            draft: "draft6"
          )
      }
    end

    test "zero is multiple of anything", %{schema: schema} do
      assert valid?(schema, 0)
    end

    test "4.5 is multiple of 1.5", %{schema: schema} do
      assert valid?(schema, 4.5)
    end

    test "35 is not multiple of 1.5", %{schema: schema} do
      refute valid?(schema, 35)
    end
  end

  describe "by small number" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"multipleOf" => 0.0001},
            draft: "draft6"
          )
      }
    end

    test "0.0075 is multiple of 0.0001", %{schema: schema} do
      assert valid?(schema, 0.0075)
    end

    test "0.00751 is not multiple of 0.0001", %{schema: schema} do
      refute valid?(schema, 0.00751)
    end
  end
end
