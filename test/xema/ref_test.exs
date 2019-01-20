defmodule Xema.RefTest do
  use ExUnit.Case, async: true

  doctest Xema.Ref

  import Xema, only: [valid?: 2, validate: 2]

  describe "schema with ref root pointer" do
    setup do
      %{
        schema:
          Xema.new({
            :any,
            properties: %{
              foo: {:ref, "#"}
            },
            additional_properties: false
          })
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      assert validate(schema, %{foo: 1}) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      assert validate(schema, %{bar: 1}) ==
               {:error, %{properties: %{bar: %{additional_properties: false}}}}
    end

    test "validate/2 with recursive valid data", %{schema: schema} do
      assert validate(schema, %{foo: %{foo: %{foo: 3}}}) == :ok
    end

    test "validate/2 with recursive invalid data", %{schema: schema} do
      assert validate(schema, %{foo: %{foo: %{bar: 3}}}) ==
               {:error,
                %{
                  properties: %{
                    foo: %{
                      properties: %{
                        foo: %{
                          properties: %{bar: %{additional_properties: false}}
                        }
                      }
                    }
                  }
                }}
    end
  end

  describe "schema with a ref to property" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: :integer,
              bar: {:ref, "#/properties/foo"}
            },
            additional_properties: false
          )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      assert validate(schema, %{foo: 42}) == :ok
      assert validate(schema, %{bar: 42}) == :ok
      assert validate(schema, %{foo: 21, bar: 42}) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      assert validate(schema, %{foo: "42"}) ==
               {:error, %{properties: %{foo: %{type: :integer, value: "42"}}}}

      assert validate(schema, %{bar: "42"}) ==
               {:error, %{properties: %{bar: %{type: :integer, value: "42"}}}}

      assert validate(schema, %{foo: "21", bar: "42"}) ==
               {:error,
                %{
                  properties: %{
                    bar: %{type: :integer, value: "42"},
                    foo: %{type: :integer, value: "21"}
                  }
                }}
    end
  end

  describe "schema with a ref to property (string key)" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              "foo" => :integer,
              "bar" => {:ref, "#/properties/foo"}
            },
            additional_properties: false
          )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      assert validate(schema, %{"foo" => 42}) == :ok
      assert validate(schema, %{"bar" => 42}) == :ok
      assert validate(schema, %{"foo" => 21, "bar" => 42}) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      assert validate(schema, %{"foo" => "42"}) ==
               {:error,
                %{properties: %{"foo" => %{type: :integer, value: "42"}}}}

      assert validate(schema, %{"bar" => "42"}) ==
               {:error,
                %{properties: %{"bar" => %{type: :integer, value: "42"}}}}

      assert validate(schema, %{"foo" => "21", "bar" => "42"}) ==
               {:error,
                %{
                  properties: %{
                    "bar" => %{type: :integer, value: "42"},
                    "foo" => %{type: :integer, value: "21"}
                  }
                }}
    end
  end

  describe "ref ignores any sibling" do
    setup do
      %{
        schema:
          Xema.new(
            definitions: %{
              reffed: :list
            },
            properties: %{
              foo: [
                max_items: 2,
                ref: "#/definitions/reffed"
              ]
            }
          )
      }
    end

    test "with valid value", %{schema: schema} do
      assert Xema.valid?(schema, %{foo: []})
    end

    test "with invalid value", %{schema: schema} do
      refute Xema.valid?(schema, %{foo: 1})
    end

    test "with valid value ignoring max items", %{schema: schema} do
      assert Xema.valid?(schema, [1, 2, 3, 4])
    end
  end

  describe "schema with ref and definitions" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: {:ref, "#/definitions/pos"},
              bar: {:ref, "#/definitions/neg"}
            },
            definitions: %{
              pos: {:integer, minimum: 0},
              neg: {:integer, maximum: 0}
            }
          )
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, %{foo: 5, bar: -1}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert validate(schema, %{foo: -1, bar: 1}) ==
               {:error,
                %{
                  properties: %{
                    bar: %{maximum: 0, value: 1},
                    foo: %{minimum: 0, value: -1}
                  }
                }}
    end
  end

  describe "schema with ref to custom data" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: {:ref, "#/abc/def/pos"},
              bar: {:ref, "#/abc/neg"}
            },
            abc: %{
              def: %{
                pos: {:integer, minimum: 0}
              },
              neg: {:integer, maximum: 0}
            }
          )
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, %{foo: 5, bar: -1}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert validate(schema, %{foo: -1, bar: 1}) ==
               {:error,
                %{
                  properties: %{
                    bar: %{maximum: 0, value: 1},
                    foo: %{minimum: 0, value: -1}
                  }
                }}
    end
  end

  describe "schema with ref chain" do
    setup do
      %{
        schema:
          Xema.new(
            properties: %{
              foo: {:ref, "#/definitions/bar"}
            },
            definitions: %{
              bar: {:ref, "#/definitions/pos"},
              pos: {:integer, minimum: 0}
            }
          )
      }
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, %{foo: 42}) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert validate(schema, %{foo: -21}) ==
               {:error, %{properties: %{foo: %{minimum: 0, value: -21}}}}
    end
  end

  describe "schema with ref as keyword" do
    setup do
      %{
        schema:
          Xema.new(
            ref: "#/definitions/pos",
            definitions: %{
              pos: {:integer, minimum: 0}
            }
          )
      }
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, 42) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert validate(schema, -42) == {:error, %{minimum: 0, value: -42}}
    end
  end

  describe "schema with ref to id" do
    setup do
      %{
        schema:
          Xema.new(
            id: "http://foo.com",
            ref: "pos",
            definitions: %{
              pos: {:integer, minimum: 0, id: "http://foo.com/pos"}
            }
          )
      }
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, 42) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert validate(schema, -42) == {:error, %{minimum: 0, value: -42}}
    end
  end

  describe "schema with ref to a list item" do
    setup do
      %{
        schema:
          Xema.new(
            items: [
              :integer,
              {:ref, "#/items/0"},
              {:ref, "#/items/1"}
            ]
          )
      }
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, [1, 2]) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert validate(schema, [1, "2"]) ==
               {:error, %{items: [{1, %{type: :integer, value: "2"}}]}}
    end
  end

  describe "schema with ref for additional items" do
    setup do
      %{
        schema:
          Xema.new(
            definitions: %{
              str: :string
            },
            items: [:integer],
            additional_items: {:ref, "#/definitions/str"}
          )
      }
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, [1, "foo"]) == :ok
    end

    test "validate/2 with invalid value", %{schema: schema} do
      assert validate(schema, [1, 2]) ==
               {:error, %{items: [{1, %{type: :string, value: 2}}]}}
    end
  end

  describe "schema with escaped refs" do
    setup do
      %{
        schema:
          Xema.new(
            definitions: %{
              "tilda~field": :integer,
              "slash/field": :integer,
              "percent%field": :integer
            },
            properties: %{
              tilda_1: {:ref, "#/definitions/tilda~field"},
              tilda_2: {:ref, "#/definitions/tilda~0field"},
              tilda_3: {:ref, "#/definitions/tilda%7Efield"},
              percent: {:ref, "#/definitions/percent%25field"},
              slash_1: {:ref, "#/definitions/slash~1field"},
              slash_2: {:ref, "#/definitions/slash%2Ffield"}
            }
          )
      }
    end

    test "validate/2 tilda_1 with valid value", %{schema: schema} do
      assert validate(schema, %{tilda_1: 1}) == :ok
    end

    test "validate/2 tilda_1 with invalid value", %{schema: schema} do
      assert validate(schema, %{tilda_1: "1"}) ==
               {:error,
                %{properties: %{tilda_1: %{type: :integer, value: "1"}}}}
    end

    test "validate/2 tilda_2 with valid value", %{schema: schema} do
      assert validate(schema, %{tilda_2: 1}) == :ok
    end

    test "validate/2 tilda_3 with valid value", %{schema: schema} do
      assert validate(schema, %{tilda_3: 1}) == :ok
    end

    test "validate/2 percent with valid value", %{schema: schema} do
      assert validate(schema, %{percent: 1}) == :ok
    end

    test "validate/2 slash_1 with valid value", %{schema: schema} do
      assert validate(schema, %{slash_1: 1}) == :ok
    end

    test "validate/2 slash_2 with valid value", %{schema: schema} do
      assert validate(schema, %{slash_2: 1}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert validate(schema, %{
               tilda_1: "1",
               tilda_2: "1",
               tilda_3: "1",
               slash_1: "1",
               slash_2: "1",
               percent: "1"
             }) ==
               {:error,
                %{
                  properties: %{
                    percent: %{type: :integer, value: "1"},
                    slash_1: %{type: :integer, value: "1"},
                    slash_2: %{type: :integer, value: "1"},
                    tilda_1: %{type: :integer, value: "1"},
                    tilda_2: %{type: :integer, value: "1"},
                    tilda_3: %{type: :integer, value: "1"}
                  }
                }}
    end
  end

  describe "schema with recursive refs" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            id: "http://localhost:1234/tree",
            description: "tree of nodes",
            properties: %{
              meta: :string,
              nodes: {:list, items: {:ref, "node"}}
            },
            required: [:meta, :nodes],
            definitions: %{
              node:
                {:map,
                 id: "http://localhost:1234/node",
                 description: "node",
                 properties: %{
                   value: :number,
                   subtree: {:ref, "tree"}
                 },
                 required: [:value]}
            }
          })
      }
    end

    test "validate/2 with a valid root", %{schema: schema} do
      tree = %{
        meta: "root",
        nodes: []
      }

      assert validate(schema, tree) == :ok
    end

    test "refs", %{schema: schema} do
      assert schema.refs == %{
               "http://localhost:1234/node" => %Xema.Schema{
                 description: "node",
                 id: "http://localhost:1234/node",
                 properties: %{
                   subtree: %Xema.Schema{
                     ref: %Xema.Ref{
                       pointer: "tree",
                       uri: %URI{
                         authority: "localhost:1234",
                         fragment: nil,
                         host: "localhost",
                         path: "/tree",
                         port: 1234,
                         query: nil,
                         scheme: "http",
                         userinfo: nil
                       }
                     }
                   },
                   value: %Xema.Schema{type: :number}
                 },
                 required: MapSet.new([:value]),
                 type: :map
               },
               "http://localhost:1234/tree" => :root
             }
    end

    test "validate/2 with a valid tree", %{schema: schema} do
      tree = %{
        meta: "root",
        nodes: [
          %{
            value: 5,
            subtree: %{
              meta: "sub",
              nodes: [
                %{
                  value: 42
                },
                %{
                  value: 21,
                  subtree: %{
                    meta: "foo",
                    value: 667,
                    nodes: []
                  }
                }
              ]
            }
          }
        ]
      }

      assert validate(schema, tree) == :ok
    end

    test "validate/2 with a missing nodes property", %{schema: schema} do
      tree = %{
        meta: "root",
        nodes: [
          %{
            value: 5,
            subtree: %{
              meta: "sub",
              nodes: [
                %{
                  value: 42
                },
                %{
                  value: 21,
                  subtree: %{
                    meta: "foo",
                    value: 667
                  }
                }
              ]
            }
          }
        ]
      }

      assert validate(schema, tree) ==
               {:error,
                %{
                  properties: %{
                    nodes: %{
                      items: [
                        {0,
                         %{
                           properties: %{
                             subtree: %{
                               properties: %{
                                 nodes: %{
                                   items: [
                                     {1,
                                      %{
                                        properties: %{
                                          subtree: %{required: [:nodes]}
                                        }
                                      }}
                                   ]
                                 }
                               }
                             }
                           }
                         }}
                      ]
                    }
                  }
                }}
    end
  end

  describe "location-independent identifier" do
    setup do
      %{
        schema:
          Xema.new({
            :any,
            definitions: %{
              foo: {:integer, id: "#num"}
            },
            ref: "#num"
          })
      }
    end

    test "with valid data", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end
  end

  describe "escaped pointer ref" do
    setup do
      %{
        schema:
          Xema.new([
            {:properties,
             %{
               percent: {:ref, "#/percent%25field"},
               slash: {:ref, "#/slash~1field"},
               tilda: {:ref, "#/tilda~0field"}
             }},
            "percent%field": :integer,
            "slash/field": :integer,
            "tilda~field": :integer
          ])
      }
    end

    test "slash invalid", %{schema: schema} do
      data = %{slash: "aoeu"}
      refute valid?(schema, data)
    end

    test "tilda invalid", %{schema: schema} do
      data = %{tilda: "aoeu"}
      refute valid?(schema, data)
    end

    test "percent invalid", %{schema: schema} do
      data = %{percent: "aoeu"}
      refute valid?(schema, data)
    end

    test "slash valid", %{schema: schema} do
      data = %{slash: 123}
      assert valid?(schema, data)
    end

    test "tilda valid", %{schema: schema} do
      data = %{tilda: 123}
      assert valid?(schema, data)
    end

    test "percent valid", %{schema: schema} do
      data = %{percent: 123}
      assert valid?(schema, data)
    end
  end
end
