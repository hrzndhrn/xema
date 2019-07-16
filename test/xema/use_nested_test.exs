defmodule Xema.UseNestedTest do
  use ExUnit.Case, async: true

  defmodule Fake do
    def uuid4, do: "da6dc006-f8de-465d-bc6b-97ba4727f183"
  end

  defmodule Location do
    use Xema

    xema do
      field :city, [:string, nil]
      field :country, [:string, nil], min_length: 1
    end
  end

  defmodule KeyValue do
    use Xema

    xema do
      map(
        keys: :strings,
        additional_properties: [:number, :string],
        property_names: [pattern: ~r/^[a-z][a-z_]*$/],
        default: %{}
      )
    end
  end

  defmodule Grant do
    use Xema

    @ops [:foo, :bar, :baz]
    @permissions [:create, :read, :update, :delete]

    xema do
      field :op, :atom, enum: @ops
      field :permissions, :list, items: {:atom, enum: @permissions}
      required [:op, :permissions]
    end
  end

  defmodule User do
    use Xema

    alias Fake

    @regex_uuid ~r/^[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}$/

    xema do
      field :id, :string, default: {Fake, :uuid4}, pattern: @regex_uuid
      field :name, :string, min_length: 1
      field :age, [:integer, nil], minimum: 0
      field :location, Location
      field :grants, :list, items: Grant, default: []
      field :settings, KeyValue
      required [:age]
    end
  end

  describe "Location.cast/1" do
    test "returns %Location{} for valid data" do
      assert Location.cast(city: "Dortmund", country: "Germany") ==
               {:ok, %Location{city: "Dortmund", country: "Germany"}}
    end
  end

  describe "Grants.cast/1" do
    test "returns %Grants{} for valid data" do
      assert Grant.cast(%{"op" => "foo", "permissions" => ["create", "read"]}) ==
               {:ok, %Xema.UseNestedTest.Grant{op: :foo, permissions: [:create, :read]}}
    end
  end

  describe "User.cast/1" do
    test "returns %User{} for minimal valid minimal keyword list" do
      data = [
        name: "Fred",
        age: nil,
        location: [city: "Dortmund"]
      ]

      expected = %User{
        age: nil,
        grants: [],
        id: Fake.uuid4(),
        location: %Location{city: "Dortmund"},
        name: "Fred",
        settings: %{}
      }

      assert User.cast(data) == {:ok, expected}
    end

    test "returns %User{} for valid keyword list" do
      data = [
        name: "Fred",
        age: "66",
        location: [city: "Dortmund"],
        grants: [
          [op: "foo", permissions: ["create"]],
          [op: "bar", permissions: ["read", "delete"]]
        ],
        settings: [a_a: 5, b_b: "foo"]
      ]

      expected = %User{
        age: 66,
        grants: [
          %Grant{op: :foo, permissions: [:create]},
          %Grant{op: :bar, permissions: [:read, :delete]}
        ],
        id: Fake.uuid4(),
        location: %Location{
          city: "Dortmund",
          country: nil
        },
        name: "Fred",
        settings: %{"a_a" => 5, "b_b" => "foo"}
      }

      assert User.cast(data) == {:ok, expected}
    end

    test "returns %User{} for valid map with atom keys" do
      data = %{
        name: "Fred",
        age: 66,
        location: %{city: "Dortmund"},
        grants: [
          %{op: "foo", permissions: ["create"]},
          %{op: "bar", permissions: ["read", "delete"]}
        ]
      }

      expected = %User{
        age: 66,
        grants: [
          %Grant{op: :foo, permissions: [:create]},
          %Grant{op: :bar, permissions: [:read, :delete]}
        ],
        id: Fake.uuid4(),
        location: %Location{
          city: "Dortmund",
          country: nil
        },
        name: "Fred",
        settings: %{}
      }

      assert User.cast(data) == {:ok, expected}
    end

    test "returns %User{} for valid map with string keys" do
      data = %{
        "name" => "Fred",
        "age" => 66,
        "location" => %{"city" => "Dortmund"},
        "grants" => [
          %{"op" => "foo", "permissions" => ["create"]},
          %{"op" => "bar", "permissions" => ["read", "delete"]}
        ]
      }

      expected = %User{
        age: 66,
        grants: [
          %Grant{op: :foo, permissions: [:create]},
          %Grant{op: :bar, permissions: [:read, :delete]}
        ],
        id: Fake.uuid4(),
        location: %Location{
          city: "Dortmund",
          country: nil
        },
        name: "Fred",
        settings: %{}
      }

      assert User.cast(data) == {:ok, expected}
    end
  end

  describe "User.validate/1" do
    test "returns :ok for valid data" do
      assert User.validate(%User{
               age: 66,
               location: %Location{
                 city: "Dortmund",
                 country: nil
               },
               name: "Fred"
             })
    end
  end
end
