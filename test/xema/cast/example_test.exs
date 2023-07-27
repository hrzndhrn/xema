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

  defmodule Person do
    use Xema

    xema do
      map(
        keys: :atoms,
        properties: %{
          name: string(),
          age: integer(minimum: 0),
          fav: atom(enum: [:erlan, :elixir, :js, :rust, :go])
        }
      )
    end

    def new(args), do: cast!(args)
  end

  describe "user" do
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

  describe "person" do
    test "new/1" do
      assert Person.new(name: "Joe", age: 24, fav: :elixir) == %{
               age: 24,
               fav: :elixir,
               name: "Joe"
             }
    end

    test "cast/1" do
      assert person = Person.new(name: "Joe", age: 24, fav: :elixir)

      assert json = person |> Jason.encode!() |> Jason.decode!()

      assert json == %{
               "age" => 24,
               "fav" => "elixir",
               "name" => "Joe"
             }

      assert Person.cast(json) == {:ok, %{age: 24, fav: :elixir, name: "Joe"}}
    end

    test "validate/1" do
      assert {:error, error} = Person.validate(%{name: 42, age: -1, fav: :php})

      assert message = Exception.message(error)
      assert message =~ ~s|Value -1 is less than minimum value of 0, at [:age].|
      assert message =~ ~s|Value :php is not defined in enum, at [:fav].|
      assert message =~ ~s|Expected :string, got 42, at [:name].|
    end
  end
end
