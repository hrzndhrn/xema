defmodule Xema.CustomValidatorTest do
  use ExUnit.Case, async: true

  alias Xema.ValidationError

  defmodule Palindrome do
    def check(str) do
      case str == String.reverse(str) do
        true -> :ok
        false -> {:error, :no_palindrome}
      end
    end
  end

  defmodule ThreeWords do
    @behaviour Xema.Validator

    @impl true
    def validate(str) do
      case length(String.split(str, " ")) do
        3 -> :ok
        _ -> {:error, :not_three_words}
      end
    end
  end

  defmodule Schemas do
    use Xema, multi: true

    xema :strings do
      map(
        properties: %{
          short: string(max_length: 3),
          long: string(min_length: 5),
          palindrome: string(validator: {Palindrome, :check}),
          three: string(validator: ThreeWords)
        }
      )
    end

    xema :timespan do
      map(
        properties: %{
          from: strux(NaiveDateTime),
          to: strux(NaiveDateTime)
        },
        validator: &Schemas.timespan_validator/1
      )
    end

    def timespan_validator(%{from: from, to: to}) do
      case NaiveDateTime.diff(from, to) < 0 do
        true -> :ok
        false -> {:error, :to_before_from}
      end
    end
  end

  describe "strings schema" do
    test "with valid data" do
      assert Schemas.valid?(:strings, %{
               short: "foo",
               long: "foobar",
               palindrome: "rats live on no evil star",
               three: "one two three"
             })
    end

    test "with invalid data" do
      assert {:error,
              %ValidationError{
                reason: %{
                  properties: %{
                    long: %{min_length: 5, value: "foo"},
                    short: %{max_length: 3, value: "foobar"},
                    three: %{validator: :not_three_words, value: "one"},
                    palindrome: %{
                      validator: :no_palindrome,
                      value: "cats live on no evil star"
                    }
                  }
                }
              } = error} =
               Schemas.validate(:strings, %{
                 short: "foobar",
                 long: "foo",
                 palindrome: "cats live on no evil star",
                 three: "one"
               })

      assert message = Exception.message(error)

      assert message =~ ~s|Expected minimum length of 5, got "foo", at [:long].|

      assert message =~
               ~s|Validator fails with :no_palindrome for value "cats live on no evil star", at [:palindrome].|

      assert message =~ ~s|Expected maximum length of 3, got "foobar", at [:short].|
      assert message =~ ~s|Validator fails with :not_three_words for value "one", at [:three].|
    end
  end

  describe "timespan schema" do
    test "with valid data" do
      from = ~N[2019-01-03 12:05:42]
      to = ~N[2019-03-03 12:05:42]

      assert Schemas.validate(:timespan, %{from: from, to: to}) == :ok
    end

    test "with to before from" do
      from = ~N[2019-01-03 12:05:42]
      to = ~N[2019-01-01 12:05:42]

      assert {:error,
              %ValidationError{
                reason: %{
                  validator: :to_before_from,
                  value: %{
                    from: ~N[2019-01-03 12:05:42],
                    to: ~N[2019-01-01 12:05:42]
                  }
                }
              } = error} = Schemas.validate(:timespan, %{from: from, to: to})

      assert Exception.message(error) =~ "Validator fails with :to_before_from"
    end

    test "with invalid data" do
      from = ~N[2019-03-03 12:05:42.328849]
      {:ok, to, 0} = DateTime.from_iso8601("2015-01-23T23:50:07Z")

      assert {:error,
              %ValidationError{
                reason: %{properties: %{to: %{value: ^to, module: NaiveDateTime}}}
              } = error} = Schemas.validate(:timespan, %{from: from, to: to})

      assert Exception.message(error) =~
               ~r/Expected.NaiveDateTime,.got.*2015-01-23.23:50:07.*,.at..:to../
    end
  end
end
