defmodule Xema.Cast.DefaultTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast!: 2]

  alias Xema.{ValidationError}

  @regex_uuid ~r/^[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}$/

  describe "cast/2 with a default constant" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              id: {:string, default: "00000000-0000-0000-0000-000000000000", pattern: @regex_uuid}
            }
          })
      }
    end

    test "from an empty map", %{schema: schema} do
      assert cast!(schema, %{}) == %{id: "00000000-0000-0000-0000-000000000000"}
    end

    test "from a map with invalid value", %{schema: schema} do
      message =
        ~s|Pattern ~r/#{Regex.source(@regex_uuid)}/ does not match value "asdf", at [:id].|

      assert_raise ValidationError, message, fn -> cast!(schema, %{id: "asdf"}) end
    end
  end

  describe "cast/2 with a default function" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              id: {:string, default: &UUID.uuid4/0, pattern: @regex_uuid}
            }
          })
      }
    end

    test "from an empty map", %{schema: schema} do
      assert %{id: _id} = cast!(schema, %{})
    end
  end

  describe "cast/2 with a default mf-tuple" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              id: {:string, default: {UUID, :uuid4}, pattern: @regex_uuid}
            }
          })
      }
    end

    test "from an empty map", %{schema: schema} do
      assert %{id: _id} = cast!(schema, %{})
    end
  end

  describe "cast/2 with a default mfa-tuple" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              id:
                {:string, default: {UUID, :uuid5, [:dns, "my.domain.com"]}, pattern: @regex_uuid}
            }
          })
      }
    end

    test "from an empty map", %{schema: schema} do
      assert %{id: _id} = cast!(schema, %{})
    end
  end
end
