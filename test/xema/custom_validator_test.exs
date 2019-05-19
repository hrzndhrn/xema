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

    xema :strings,
         map(
           properties: %{
             short: string(max_length: 3),
             long: string(min_length: 5),
             palindrome: string(validator: {Palindrome, :check}),
             three: string(validator: ThreeWords)
           }
         )

    xema :timespan,
         map(
           properties: %{
             from: strux(NaiveDateTime),
             to: strux(NaiveDateTime)
           },
           validator: &Schemas.timespan_validator/1
         )

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
      message = """
      Expected minimum length of 5, got "foo", at [:long].
      Validator fails with :no_palindrome for value "cats live on no evil star", at [:palindrome].
      Expected maximum length of 3, got "foobar", at [:short].
      Validator fails with :not_three_words for value "one", at [:three].\
      """

      assert Schemas.validate(:strings, %{
               short: "foobar",
               long: "foo",
               palindrome: "cats live on no evil star",
               three: "one"
             }) ==
               {:error,
                %ValidationError{
                  message: message,
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
                }}
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

      message =
        String.replace(
          """
          Validator fails with :to_before_from
          for value %{from: ~N[2019-01-03 12:05:42],
          to: ~N[2019-01-01 12:05:42]}.\
          """,
          "\n",
          " "
        )

      assert Schemas.validate(:timespan, %{from: from, to: to}) ==
               {:error,
                %ValidationError{
                  message: message,
                  reason: %{
                    validator: :to_before_from,
                    value: %{
                      from: ~N[2019-01-03 12:05:42],
                      to: ~N[2019-01-01 12:05:42]
                    }
                  }
                }}
    end

    test "with invalid data" do
      from = ~N[2019-03-03 12:05:42.328849]
      {:ok, to, 0} = DateTime.from_iso8601("2015-01-23T23:50:07Z")

      assert Schemas.validate(:timespan, %{from: from, to: to}) ==
               {:error,
                %ValidationError{
                  message:
                    "Expected NaiveDateTime, got #DateTime<2015-01-23 23:50:07Z>, at [:to].",
                  reason: %{properties: %{to: %{value: to, module: NaiveDateTime}}}
                }}
    end
  end
end
