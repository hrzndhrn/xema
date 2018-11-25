defmodule Xema.DataTest do
  use ExUnit.Case, async: true

  defmodule Foo do
    defstruct [:bar]
  end

  describe "custom data: " do
    test "additional data goes to the data map" do
      schema = Xema.new({:map, foo: 3})
      assert schema.schema.data == %{foo: 3}

      schema = Xema.new({:integer, foo: :bar})
      assert schema.schema.data == %{foo: :bar}

      schema = Xema.new({:list, foo: [1, 2, 3]})
      assert schema.schema.data == %{foo: [1, 2, 3]}

      schema = Xema.new({:list, foo: %Foo{bar: 42}})
      assert schema.schema.data == %{foo: %Foo{bar: 42}}

      schema = Xema.new({:list, foo: [bar: 42]})
      assert schema.schema.data == %{foo: [bar: 42]}

      schema = Xema.new({:map, foo: {:foo, [42]}})
      assert schema.schema.data == %{foo: {:foo, [42]}}
    end

    test "maps are copied" do
      schema = Xema.new({:map, foo: %{min_length: 5}})
      assert schema.schema.data.foo == %{min_length: 5}
    end

    test "can contain schemas" do
      schema = Xema.new({:string, foo: :integer})
      assert schema.schema.data.foo == Xema.new(:integer).schema

      schema = Xema.new({:integer, foo: [min_items: 5]})
      assert schema.schema.data.foo == Xema.new(min_items: 5).schema

      schema = Xema.new({:integer, foo: {:list, min_items: 5}})
      assert schema.schema.data.foo == Xema.new({:list, min_items: 5}).schema
    end

    test "data goes into data" do
      schema = Xema.new({:map, data: 3})
      assert schema.schema.data == %{data: 3}
    end
  end
end
