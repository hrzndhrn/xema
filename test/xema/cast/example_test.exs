defmodule Xema.Cast.ExampleTest do
  use ExUnit.Case, async: true

  defmodule UriCaster do
    @behaviour Xema.Caster

    @impl true
    def cast(%URI{} = uri), do: {:ok, uri}

    def cast(string) when is_binary(string), do: {:ok, URI.parse(string)}

    def cast(_), do: :error
  end

  defmodule UserSchema do
    use Xema

    xema do
      map(
        keys: :atoms,
        properties: %{
          name: :string,
          birthday: strux(Date),
          favorites:
            map(
              keys: :atoms,
              properties: %{
                fruits: list(items: atom(enum: [:apple, :orange, :banana])),
                uris: list(items: strux(URI, caster: UriCaster))
              }
            )
        },
        additional_properties: false
      )
    end
  end

  test "cast/1" do
    assert UserSchema.cast(%{
             "name" => "Nick",
             "birthday" => ~D|2000-04-17|,
             "favorites" => %{
               "fruits" => ~w(apple banana),
               "uris" => ["https://elixir-lang.org/"]
             }
           }) ==
             {:ok,
              %{
                birthday: ~D[2000-04-17],
                favorites: %{
                  fruits: [:apple, :banana],
                  uris: [
                    %URI{
                      authority: "elixir-lang.org",
                      fragment: nil,
                      host: "elixir-lang.org",
                      path: "/",
                      port: 443,
                      query: nil,
                      scheme: "https",
                      userinfo: nil
                    }
                  ]
                },
                name: "Nick"
              }}
  end

  test "cast/1 from json" do
    {:ok, json} =
      %{
        "name" => "Nick",
        "birthday" => ~D|2000-04-17|,
        "favorites" => %{
          "fruits" => ~w(apple banana),
          "uris" => ["https://elixir-lang.org/"]
        }
      }
      |> UserSchema.cast!()
      |> Jason.encode()

    assert json |> Jason.decode!() |> UserSchema.cast!() ==
             %{
               birthday: ~D[2000-04-17],
               favorites: %{
                 fruits: [:apple, :banana],
                 uris: [
                   %URI{
                     authority: "elixir-lang.org",
                     fragment: nil,
                     host: "elixir-lang.org",
                     path: "/",
                     port: 443,
                     query: nil,
                     scheme: "https",
                     userinfo: nil
                   }
                 ]
               },
               name: "Nick"
             }
  end
end
