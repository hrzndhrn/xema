defmodule JsonSchemaTestSuite.Draft7.FormatTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of e-mail addresses| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "email"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of regexes| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "regex"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of IP addresses| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "ipv4"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of IPv6 addresses| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "ipv6"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of hostnames| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "hostname"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of date strings| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "date"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of date-time strings| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "date-time"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of time strings| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "time"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of JSON pointers| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "json-pointer"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of relative JSON pointers| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "relative-json-pointer"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of IRIs| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "iri"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of IRI references| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "iri-reference"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of URIs| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "uri"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of URI references| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "uri-reference"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|validation of URI templates| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "uri-template"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 12)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 13.7)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, false)
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end
end
