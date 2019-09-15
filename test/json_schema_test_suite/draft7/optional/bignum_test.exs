defmodule JsonSchemaTestSuite.Draft7.Optional.Bignum do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "integer" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "integer"})}
    end

    test "a bignum is an integer", %{schema: schema} do
      assert valid?(
               schema,
               12_345_678_910_111_213_141_516_171_819_202_122_232_425_262_728_293_031
             )
    end
  end

  describe "number" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "number"})}
    end

    test "a bignum is a number", %{schema: schema} do
      assert valid?(
               schema,
               98_249_283_749_234_923_498_293_171_823_948_729_348_710_298_301_928_331
             )
    end
  end

  describe "integer (1)" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "integer"})}
    end

    test "a negative bignum is an integer", %{schema: schema} do
      assert valid?(
               schema,
               -12_345_678_910_111_213_141_516_171_819_202_122_232_425_262_728_293_031
             )
    end
  end

  describe "number (1)" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "number"})}
    end

    test "a negative bignum is a number", %{schema: schema} do
      assert valid?(
               schema,
               -98_249_283_749_234_923_498_293_171_823_948_729_348_710_298_301_928_331
             )
    end
  end

  describe "string" do
    setup do
      %{schema: Xema.from_json_schema(%{"type" => "string"})}
    end

    test "a bignum is not a string", %{schema: schema} do
      refute valid?(
               schema,
               98_249_283_749_234_923_498_293_171_823_948_729_348_710_298_301_928_331
             )
    end
  end

  describe "integer comparison" do
    setup do
      %{schema: Xema.from_json_schema(%{"maximum" => 18_446_744_073_709_551_615})}
    end

    test "comparison works for high numbers", %{schema: schema} do
      assert valid?(schema, 18_446_744_073_709_551_600)
    end
  end

  describe "float comparison with high precision" do
    setup do
      %{schema: Xema.from_json_schema(%{"exclusiveMaximum" => 9.727837981879871e26})}
    end

    test "comparison works for high numbers", %{schema: schema} do
      refute valid?(schema, 9.727837981879871e26)
    end
  end

  describe "integer comparison (1)" do
    setup do
      %{schema: Xema.from_json_schema(%{"minimum" => -18_446_744_073_709_551_615})}
    end

    test "comparison works for very negative numbers", %{schema: schema} do
      assert valid?(schema, -18_446_744_073_709_551_600)
    end
  end

  describe "float comparison with high precision on negative numbers" do
    setup do
      %{schema: Xema.from_json_schema(%{"exclusiveMinimum" => -9.727837981879871e26})}
    end

    test "comparison works for very negative numbers", %{schema: schema} do
      refute valid?(schema, -9.727837981879871e26)
    end
  end
end
