defmodule Xema.Dependencies do
  use ExUnit.Case, async: true

  test "dependencies with boolean subschemas" do
    schema = Xema.new(dependencies: %{bar: true, foo: false})

    assert schema.content.dependencies.bar == %Xema.Schema{type: true}
    assert schema.content.dependencies.foo == %Xema.Schema{type: false}
  end
end
