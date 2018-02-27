defmodule Suite.Draft4.DefaultTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "invalid type for default" do
    setup do
      %{schema: Xema.new(:properties, %{"foo" => :integer})}
    end

    @tag :draft4
    @tag :default
    test "valid when property is specified", %{schema: schema} do
      data = %{"foo" => 13}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :default
    test "still valid when the invalid default is used", %{schema: schema} do
      data = %{}
      assert is_valid?(schema, data)
    end
  end

  describe "invalid string value for default" do
    setup do
      %{schema: Xema.new(:properties, %{"bar" => {:string, min_length: 4}})}
    end

    @tag :draft4
    @tag :default
    test "valid when property is specified", %{schema: schema} do
      data = %{"bar" => "good"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :default
    test "still valid when the invalid default is used", %{schema: schema} do
      data = %{}
      assert is_valid?(schema, data)
    end
  end
end
