defmodule Xema.UserTest do
  use ExUnit.Case

  alias Amex.User

  describe "cast/1" do
    test "with valid data" do
      assert user =
               User.cast!(
                 name: "Nick",
                 age: 21,
                 location: [
                   city: "Dortmud",
                   country: "Germany"
                 ],
                 grants: [%{op: :bar, permissions: [:read, :update]}],
                 settings: [foo: 44, bar: "baz"],
                 created: 1_567_922_779
               )

      assert user ==
               %Amex.User{
                 age: 21,
                 created: ~U[2019-09-08 06:06:19Z],
                 grants: [%Amex.Grant{op: :bar, permissions: [:read, :update]}],
                 id: user.id,
                 location: %Amex.Location{city: "Dortmud", country: "Germany"},
                 name: "Nick",
                 settings: %{"bar" => "baz", "foo" => 44},
                 updated: nil
               }
    end
  end
end
