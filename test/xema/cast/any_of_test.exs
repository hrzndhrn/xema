defmodule Xema.Cast.AnyOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2]

  alias Xema.CastError

  describe "cast/2 with any_of schema with types" do
    setup do
      %{
        schema: Xema.new(any_of: [:integer, :string, nil])
      }
    end

    test "from an integer", %{schema: schema} do
      assert cast(schema, 6) == {:ok, 6}
    end

    test "from an integer string", %{schema: schema} do
      assert cast(schema, "9") == {:ok, 9}
    end

    test "from a string", %{schema: schema} do
      assert cast(schema, "nine") == {:ok, "nine"}
    end

    test "from a nil", %{schema: schema} do
      assert cast(schema, nil) == {:ok, nil}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 5.5) == {:ok, "5.5"}
    end

    test "from an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, [])

      assert error == %CastError{
               path: [],
               to: [
                 %{path: [], to: :integer, value: []},
                 %{path: [], to: :string, value: []},
                 %{path: [], to: nil, value: []}
               ],
               value: []
             }

      assert Exception.message(error) ==
               """
               cannot cast [] to any of:
                 cannot cast [] to :integer
                 cannot cast [] to :string
                 cannot cast [] to nil\
               """
    end
  end

  describe "cast/2 with any_of schema with properties" do
    setup do
      %{
        schema:
          Xema.new(
            any_of: [
              [properties: %{a: :string}],
              [properties: %{b: :integer}]
            ]
          )
      }
    end

    test "from a map", %{schema: schema} do
      assert cast(schema, %{a: 1, b: "2"}) == {:ok, %{a: "1", b: 2}}
    end

    test "from a map with an invalid value", %{schema: schema} do
      assert cast(schema, %{a: 1, b: 1.5}) == {:ok, %{a: "1", b: 1.5}}
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, a: 1, b: "2") == {:ok, [a: "1", b: 2]}
    end
  end

  describe "cast/2 with any_of schema with multiple properties" do
    setup do
      %{
        schema:
          Xema.new(
            any_of: [
              [properties: %{a: :integer}],
              [properties: %{a: :string}],
              [properties: %{a: nil}]
            ]
          )
      }
    end

    test "from a map with an integer", %{schema: schema} do
      assert cast(schema, %{a: 1}) == {:ok, %{a: 1}}
    end

    test "from a map with an integer string", %{schema: schema} do
      assert cast(schema, %{a: "2"}) == {:ok, %{a: 2}}
    end

    test "from a map with a string", %{schema: schema} do
      assert cast(schema, %{a: "three"}) == {:ok, %{a: "three"}}
    end

    test "from a map with a nil", %{schema: schema} do
      assert cast(schema, %{a: nil}) == {:ok, %{a: nil}}
    end

    test "from a map with an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, %{a: []})

      assert error == %CastError{
               error: nil,
               key: nil,
               message: nil,
               path: [],
               to: [
                 %{path: [:a], to: :integer, value: []},
                 %{path: [:a], to: :string, value: []},
                 %{path: [:a], to: nil, value: []}
               ],
               value: %{a: []}
             }

      message = """
      cannot cast %{a: []} to any of:
        cannot cast [] to :integer at [:a]
        cannot cast [] to :string at [:a]
        cannot cast [] to nil at [:a]\
      """

      assert Exception.message(error) == message
    end
  end

  describe "cast/2 with any_of schema with items" do
    setup do
      %{
        schema:
          Xema.new(
            any_of: [
              [items: :integer],
              [items: :string]
            ]
          )
      }
    end

    test "from a list of integers", %{schema: schema} do
      assert cast(schema, [1, 2, 3]) == {:ok, [1, 2, 3]}
    end
  end

  describe "cast/2 with any_of schema in property" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: [any_of: [:integer, :string, nil]]
            }
          )
      }
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, %{foo: 5.5}) == {:ok, %{foo: "5.5"}}
    end

    test "from an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, %{foo: []})

      assert error == %CastError{
               path: [:foo],
               to: [
                 %{path: [], to: :integer, value: []},
                 %{path: [], to: :string, value: []},
                 %{path: [], to: nil, value: []}
               ],
               value: []
             }

      assert Exception.message(error) ==
               """
               cannot cast [] at [:foo] to any of:
                 cannot cast [] to :integer
                 cannot cast [] to :string
                 cannot cast [] to nil\
               """
    end
  end

  describe "cast/2 with any_of schema with multiple properties in property" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: [
                any_of: [
                  [properties: %{a: :integer}],
                  [properties: %{a: :string}],
                  [properties: %{a: nil}]
                ]
              ]
            }
          )
      }
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, %{foo: %{a: 5.5}}) == {:ok, %{foo: %{a: "5.5"}}}
    end

    test "from an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, %{foo: %{a: []}})

      assert error == %CastError{
               path: [:foo],
               to: [
                 %{path: [:a], to: :integer, value: []},
                 %{path: [:a], to: :string, value: []},
                 %{path: [:a], to: nil, value: []}
               ],
               value: %{a: []}
             }

      assert Exception.message(error) ==
               """
               cannot cast %{a: []} at [:foo] to any of:
                 cannot cast [] to :integer at [:a]
                 cannot cast [] to :string at [:a]
                 cannot cast [] to nil at [:a]\
               """
    end
  end

  describe "cast/2 with a bigger schema" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              bar: [
                properties: %{
                  bas: [
                    any_of: [
                      [
                        properties: %{baz: [any_of: [:integer, nil]]}
                      ],
                      [
                        properties: %{bax: [any_of: [:integer, nil]]}
                      ]
                    ]
                  ]
                }
              ],
              foo: [
                any_of: [
                  [properties: %{faa: :integer}],
                  [properties: %{faa: nil}]
                ]
              ]
            }
          )
      }
    end

    test "from valid data", %{schema: schema} do
      assert cast(schema, %{foo: %{faa: "1"}, bar: %{bas: %{baz: "2", bax: "3"}}}) ==
               {:ok, %{foo: %{faa: 1}, bar: %{bas: %{bax: 3, baz: 2}}}}
    end

    @tag :only
    test "from data causing a deep nested cast error", %{schema: schema} do
      assert {:error, error} =
               cast(schema, %{foo: %{faa: "one"}, bar: %{bas: %{baz: "two", bax: "three"}}})

      assert Exception.message(error) ==
               """
               cannot cast %{bax: "three", baz: "two"} at [:bar, :bas] to any of:
                 cannot cast "two" at [:baz] to any of:
                   cannot cast "two" to :integer
                   cannot cast "two" to nil
                 cannot cast "three" at [:bax] to any of:
                   cannot cast "three" to :integer
                   cannot cast "three" to nil\
               """
    end
  end
end
