defmodule Xema.Cast.CustomTest do
  use ExUnit.Case, async: true

  import AssertBlame

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
      do: {:ok, string |> URI.parse() |> Map.put(:path, path)}

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
                  reason: %{
                    type: :struct,
                    value: "https://elixir-lang.org/docs.html"
                  }
                }}

      assert {:error,
              %CastError{
                key: nil,
                path: [],
                value: "https://elixir-lang.org/docs.html",
                to: URI
              } = error} = cast(schema, data)

      assert Exception.message(error) ==
               ~s|cannot cast "https://elixir-lang.org/docs.html" to URI|

      assert_blame CastError, fn -> cast!(schema, data) end
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
      assert {:error,
              %CastError{
                key: nil,
                path: [],
                to: URI,
                value: 5.0
              } = error} = cast(schema, 5.0)

      assert Exception.message(error) == "cannot cast 5.0 to URI"
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
                  reason: %{
                    type: :struct,
                    value: "https://elixir-lang.org/docs.html"
                  }
                }}

      assert cast(schema, data) == {:ok, URI.parse(data)}
    end

    test "from a float", %{schema: schema} do
      assert {:error,
              %CastError{
                key: nil,
                path: [],
                to: URI,
                value: 5.0
              } = error} = cast(schema, 5.0)

      assert Exception.message(error) == "cannot cast 5.0 to URI"
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
                  reason: %{
                    type: :struct,
                    value: "/docs.html"
                  }
                }}

      assert cast(schema, data) == {:ok, URI.parse("https://elixir-lang.org/docs.html")}
    end

    test "from a float", %{schema: schema} do
      assert {:error,
              %CastError{
                key: nil,
                path: [],
                to: URI,
                value: 5.0
              } = error} = cast(schema, 5.0)

      assert Exception.message(error) == "cannot cast 5.0 to URI"
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
                  reason: %{
                    type: :struct,
                    value: "https://elixir-lang.org/docs.html"
                  }
                }}

      assert cast(schema, data) == {:ok, URI.parse(data)}
    end

    test "from a float", %{schema: schema} do
      assert {:error,
              %CastError{
                key: nil,
                path: [],
                to: URI,
                value: 5.0
              } = error} = cast(schema, 5.0)

      assert Exception.message(error) == "cannot cast 5.0 to URI"
    end
  end

  describe "use Xema an caster behaviour" do
    defmodule UriSchema do
      use Xema

      xema :uri,
           map(
             keys: :strings,
             properties: %{
               "uri" => strux(URI, caster: UriCaster)
             },
             additional_properties: false
           )
    end

    test "valid?/1" do
      refute UriSchema.valid?(%{"uri" => "http://www.example.com"})
    end

    test "cast/1" do
      assert UriSchema.cast(%{uri: "http://www.example.com"}) ==
               {:ok, %{"uri" => URI.parse("http://www.example.com")}}
    end
  end
end
