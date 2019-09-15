defmodule JsonSchemaTestSuite.Draft7.IfThenElse do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "ignore if without then or else" do
    setup do
      %{schema: Xema.from_json_schema(%{"if" => %{"const" => 0}})}
    end

    test "valid when valid against lone if", %{schema: schema} do
      assert valid?(schema, 0)
    end

    test "valid when invalid against lone if", %{schema: schema} do
      assert valid?(schema, "hello")
    end
  end

  describe "ignore then without if" do
    setup do
      %{schema: Xema.from_json_schema(%{"then" => %{"const" => 0}})}
    end

    test "valid when valid against lone then", %{schema: schema} do
      assert valid?(schema, 0)
    end

    test "valid when invalid against lone then", %{schema: schema} do
      assert valid?(schema, "hello")
    end
  end

  describe "ignore else without if" do
    setup do
      %{schema: Xema.from_json_schema(%{"else" => %{"const" => 0}})}
    end

    test "valid when valid against lone else", %{schema: schema} do
      assert valid?(schema, 0)
    end

    test "valid when invalid against lone else", %{schema: schema} do
      assert valid?(schema, "hello")
    end
  end

  describe "if and then without else" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "if" => %{"exclusiveMaximum" => 0},
            "then" => %{"minimum" => -10}
          })
      }
    end

    test "valid through then", %{schema: schema} do
      assert valid?(schema, -1)
    end

    test "invalid through then", %{schema: schema} do
      refute valid?(schema, -100)
    end

    test "valid when if test fails", %{schema: schema} do
      assert valid?(schema, 3)
    end
  end

  describe "if and else without then" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "else" => %{"multipleOf" => 2},
            "if" => %{"exclusiveMaximum" => 0}
          })
      }
    end

    test "valid when if test passes", %{schema: schema} do
      assert valid?(schema, -1)
    end

    test "valid through else", %{schema: schema} do
      assert valid?(schema, 4)
    end

    test "invalid through else", %{schema: schema} do
      refute valid?(schema, 3)
    end
  end

  describe "validate against correct branch, then vs else" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "else" => %{"multipleOf" => 2},
            "if" => %{"exclusiveMaximum" => 0},
            "then" => %{"minimum" => -10}
          })
      }
    end

    test "valid through then", %{schema: schema} do
      assert valid?(schema, -1)
    end

    test "invalid through then", %{schema: schema} do
      refute valid?(schema, -100)
    end

    test "valid through else", %{schema: schema} do
      assert valid?(schema, 4)
    end

    test "invalid through else", %{schema: schema} do
      refute valid?(schema, 3)
    end
  end

  describe "non-interference across combined schemas" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "allOf" => [
              %{"if" => %{"exclusiveMaximum" => 0}},
              %{"then" => %{"minimum" => -10}},
              %{"else" => %{"multipleOf" => 2}}
            ]
          })
      }
    end

    test "valid, but would have been invalid through then", %{schema: schema} do
      assert valid?(schema, -100)
    end

    test "valid, but would have been invalid through else", %{schema: schema} do
      assert valid?(schema, 3)
    end
  end
end
