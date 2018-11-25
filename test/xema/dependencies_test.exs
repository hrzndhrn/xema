defmodule Xema.Dependencies do
  use ExUnit.Case, async: true

  test "dependencies with boolean subschemas" do
    schema = Xema.new(dependencies: %{bar: true, foo: false})

    assert schema.schema.dependencies.bar == %Xema.Schema{type: true}
    assert schema.schema.dependencies.foo == %Xema.Schema{type: false}
  end
end
