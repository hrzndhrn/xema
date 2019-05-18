defmodule Xema.Cast.CustomTest do
  use ExUnit.Case, async: true

  alias Xema.{
    CastError,
    ValidationError
  }

  defmodule UriCaster do
    @behaviour Xema.Caster

    @impl true
    def cast(%URI{} = uri), do: {:ok, uri}

    def cast(string) when is_binary(string), do: {:ok, URI.parse(string)}

    def cast(_), do: :error

    def path(%URI{} = uri, _), do: {:ok, uri}

    def path(path, string) when is_binary(path) and is_binary(string),
      do: {:ok, URI.parse(string) |> Map.put(:path, path)}

    def path(_, _), do: :error
  end

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  describe "cast/2 with an URI schema" do
    setup do
      %{
        schema: Xema.new({:struct, module: URI, properties: %{path: :string}})
      }
    end

    test "from an URI", %{schema: schema} do
      data = URI.parse("https://elixir-lang.org/docs.html")

      assert validate(schema, data) == :ok

      assert cast(schema, data) ==
               {:error,
                %Protocol.UndefinedError{
                  description: "",
                  protocol: Xema.Castable,
                  value: %URI{
                    authority: "elixir-lang.org",
                    fragment: nil,
                    host: "elixir-lang.org",
                    path: "/docs.html",
                    port: 443,
                    query: nil,
                    scheme: "https",
                    userinfo: nil
                  }
                }}
    end

    test "from a string", %{schema: schema} do
      data = "https://elixir-lang.org/docs.html"

      assert validate(schema, data) ==
               {:error,
                %ValidationError{
                  message: ~s|Expected :struct, got "https://elixir-lang.org/docs.html".|,
                  reason: %{
                    type: :struct,
                    value: "https://elixir-lang.org/docs.html"
                  }
                }}

      assert cast(schema, data) ==
               {:error,
                %CastError{
                  key: nil,
                  path: [],
                  value: "https://elixir-lang.org/docs.html",
                  message: "cannot cast \"https://elixir-lang.org/docs.html\" to URI",
                  to: URI
                }}

      assert_raise CastError, fn -> cast!(schema, data) end
    end
  end

  describe "cast/2 with an URI schema including a caster function" do
    setup do
      caster = fn
        string when is_binary(string) -> {:ok, URI.parse(string)}
        float when is_float(float) -> :error
        %URI{} = uri -> {:ok, uri}
      end

      %{
        schema:
          Xema.new({
            :struct,
            module: URI,
            properties: %{
              path: :string
            },
            caster: caster
          })
      }
    end

    test "from an URI", %{schema: schema} do
      data = URI.parse("https://elixir-lang.org/docs.html")

      assert cast(schema, data) == {:ok, data}
    end

    test "from a string", %{schema: schema} do
      data = "https://elixir-lang.org/docs.html"

      assert validate(schema, data) ==
               {:error,
                %ValidationError{
                  message: ~s|Expected :struct, got "https://elixir-lang.org/docs.html".|,
                  reason: %{
                    type: :struct,
                    value: "https://elixir-lang.org/docs.html"
                  }
                }}

      assert cast(schema, data) == {:ok, URI.parse(data)}
    end

    test "from an integer", %{schema: schema} do
      assert {:error, %FunctionClauseError{}} = cast(schema, 5)
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 5.0) ==
               {:error,
                %CastError{
                  key: nil,
                  message: "cannot cast 5.0 to URI",
                  path: [],
                  to: URI,
                  value: 5.0
                }}
    end
  end

  describe "cast/2 with an URI schema including a caster module" do
    setup do
      %{
        schema:
          Xema.new({
            :struct,
            module: URI,
            properties: %{
              path: :string
            },
            caster: {UriCaster, :cast}
          })
      }
    end

    test "from an URI", %{schema: schema} do
      data = URI.parse("https://elixir-lang.org/docs.html")

      assert cast(schema, data) == {:ok, data}
    end

    test "from a string", %{schema: schema} do
      data = "https://elixir-lang.org/docs.html"

      assert validate(schema, data) ==
               {:error,
                %ValidationError{
                  message: ~s|Expected :struct, got "https://elixir-lang.org/docs.html".|,
                  reason: %{
                    type: :struct,
                    value: "https://elixir-lang.org/docs.html"
                  }
                }}

      assert cast(schema, data) == {:ok, URI.parse(data)}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 5.0) ==
               {:error,
                %CastError{
                  key: nil,
                  message: "cannot cast 5.0 to URI",
                  path: [],
                  to: URI,
                  value: 5.0
                }}
    end
  end

  describe "cast/2 with an URI schema including a caster module with an additional arg" do
    setup do
      %{
        schema:
          Xema.new({
            :struct,
            module: URI,
            properties: %{
              path: :string
            },
            caster: {UriCaster, :path, ["https://elixir-lang.org"]}
          })
      }
    end

    test "from an URI", %{schema: schema} do
      data = URI.parse("https://elixir-lang.org/docs.html")

      assert cast(schema, data) == {:ok, data}
    end

    test "from a string", %{schema: schema} do
      data = "/docs.html"

      assert validate(schema, data) ==
               {:error,
                %ValidationError{
                  message: ~s|Expected :struct, got "/docs.html".|,
                  reason: %{
                    type: :struct,
                    value: "/docs.html"
                  }
                }}

      assert cast(schema, data) == {:ok, URI.parse("https://elixir-lang.org/docs.html")}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 5.0) ==
               {:error,
                %CastError{
                  key: nil,
                  message: "cannot cast 5.0 to URI",
                  path: [],
                  to: URI,
                  value: 5.0
                }}
    end
  end

  describe "cast/2 with an URI schema including a caster behaviour" do
    setup do
      %{
        schema:
          Xema.new({
            :struct,
            module: URI,
            properties: %{
              path: :string
            },
            caster: UriCaster
          })
      }
    end

    test "from an URI", %{schema: schema} do
      data = URI.parse("https://elixir-lang.org/docs.html")

      assert cast(schema, data) == {:ok, data}
    end

    test "from a string", %{schema: schema} do
      data = "https://elixir-lang.org/docs.html"

      assert validate(schema, data) ==
               {:error,
                %ValidationError{
                  message: ~s|Expected :struct, got "https://elixir-lang.org/docs.html".|,
                  reason: %{
                    type: :struct,
                    value: "https://elixir-lang.org/docs.html"
                  }
                }}

      assert cast(schema, data) == {:ok, URI.parse(data)}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 5.0) ==
               {:error,
                %CastError{
                  key: nil,
                  message: "cannot cast 5.0 to URI",
                  path: [],
                  to: URI,
                  value: 5.0
                }}
    end
  end
end
