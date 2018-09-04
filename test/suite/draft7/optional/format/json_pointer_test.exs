defmodule Draft7.Optional.Format.JsonPointerTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "validation of JSON-pointers (JSON String Representation)" do
    setup do
      %{schema: Xema.new(:format, :json_pointer)}
    end

    test "a valid JSON-pointer", %{schema: schema} do
      data = "/foo/bar~0/baz~1/%a"
      assert is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (~ not escaped)", %{schema: schema} do
      data = "/foo/bar~"
      refute is_valid?(schema, data)
    end

    test "valid JSON-pointer with empty segment", %{schema: schema} do
      data = "/foo//bar"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer with the last empty segment", %{schema: schema} do
      data = "/foo/bar/"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #1", %{schema: schema} do
      data = ""
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #2", %{schema: schema} do
      data = "/foo"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #3", %{schema: schema} do
      data = "/foo/0"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #4", %{schema: schema} do
      data = "/"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #5", %{schema: schema} do
      data = "/a~1b"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #6", %{schema: schema} do
      data = "/c%d"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #7", %{schema: schema} do
      data = "/e^f"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #8", %{schema: schema} do
      data = "/g|h"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #9", %{schema: schema} do
      data = "/i\\j"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #10", %{schema: schema} do
      data = "/k\"l"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #11", %{schema: schema} do
      data = "/ "
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer as stated in RFC 6901 #12", %{schema: schema} do
      data = "/m~0n"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer used adding to the last array position", %{
      schema: schema
    } do
      data = "/foo/-"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer (- used as object member name)", %{schema: schema} do
      data = "/foo/-/bar"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer (multiple escaped characters)", %{schema: schema} do
      data = "/~1~0~0~1~1"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer (escaped with fraction part) #1", %{schema: schema} do
      data = "/~1.1"
      assert is_valid?(schema, data)
    end

    test "valid JSON-pointer (escaped with fraction part) #2", %{schema: schema} do
      data = "/~0.1"
      assert is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (URI Fragment Identifier) #1", %{
      schema: schema
    } do
      data = "#"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (URI Fragment Identifier) #2", %{
      schema: schema
    } do
      data = "#/"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (URI Fragment Identifier) #3", %{
      schema: schema
    } do
      data = "#a"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (some escaped, but not all) #1", %{
      schema: schema
    } do
      data = "/~0~"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (some escaped, but not all) #2", %{
      schema: schema
    } do
      data = "/~0/~"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (wrong escape character) #1", %{
      schema: schema
    } do
      data = "/~2"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (wrong escape character) #2", %{
      schema: schema
    } do
      data = "/~-1"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (multiple characters not escaped)", %{
      schema: schema
    } do
      data = "/~~"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (isn't empty nor starts with /) #1", %{
      schema: schema
    } do
      data = "a"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (isn't empty nor starts with /) #2", %{
      schema: schema
    } do
      data = "0"
      refute is_valid?(schema, data)
    end

    test "not a valid JSON-pointer (isn't empty nor starts with /) #3", %{
      schema: schema
    } do
      data = "a/a"
      refute is_valid?(schema, data)
    end
  end
end
