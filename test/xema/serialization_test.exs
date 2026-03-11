defmodule Xema.SerializationTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  describe "schema with string pattern survives serialization" do
    setup do
      %{schema: Xema.new({:string, pattern: "^[a-z]+$"})}
    end

    test "validates matching string after round-trip", %{schema: schema} do
      assert validate(roundtrip(schema), "abc") == :ok
    end

    test "rejects non-matching string after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), "123")
    end
  end

  describe "schema with regex pattern survives serialization" do
    setup do
      %{schema: Xema.new({:string, pattern: ~r/^[a-z]+$/})}
    end

    test "validates matching string after round-trip", %{schema: schema} do
      assert validate(roundtrip(schema), "abc") == :ok
    end

    test "rejects non-matching string after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), "123")
    end
  end

  describe "schema with regex options survives serialization" do
    setup do
      %{schema: Xema.new({:string, pattern: ~r/^[a-z]+$/i})}
    end

    test "validates case-insensitively after round-trip", %{schema: schema} do
      assert validate(roundtrip(schema), "ABC") == :ok
    end

    test "rejects non-matching string after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), "123")
    end
  end

  describe "schema with string pattern_properties survives serialization" do
    setup do
      schema =
        Xema.new({
          :map,
          pattern_properties: %{"^s_" => :string, "^i_" => :number}, additional_properties: false
        })

      %{schema: schema}
    end

    test "validates matching properties after round-trip", %{schema: schema} do
      assert validate(roundtrip(schema), %{"s_1" => "foo", "i_1" => 42}) == :ok
    end

    test "rejects mismatched types after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), %{"s_1" => 42})
    end

    test "rejects additional properties after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), %{"x_1" => 44})
    end
  end

  describe "schema with regex pattern_properties survives serialization" do
    setup do
      schema =
        Xema.new({
          :map,
          pattern_properties: %{~r/^s_/ => :string, ~r/^i_/ => :number},
          additional_properties: false
        })

      %{schema: schema}
    end

    test "validates matching properties after round-trip", %{schema: schema} do
      assert validate(roundtrip(schema), %{s_1: "foo", i_1: 42}) == :ok
    end

    test "rejects mismatched types after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), %{s_1: 42})
    end
  end

  describe "JSON schema with pattern survives serialization" do
    setup do
      schema =
        Xema.from_json_schema(
          %{"type" => "string", "pattern" => "^[a-z]+$"},
          draft: "draft7",
          atom: :force
        )

      %{schema: schema}
    end

    test "validates matching string after round-trip", %{schema: schema} do
      assert validate(roundtrip(schema), "abc") == :ok
    end

    test "rejects non-matching string after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), "123")
    end
  end

  describe "JSON schema with patternProperties survives serialization" do
    setup do
      schema =
        Xema.from_json_schema(
          %{
            "type" => "object",
            "patternProperties" => %{"^f.*o$" => %{"type" => "integer"}}
          },
          draft: "draft7",
          atom: :force
        )

      %{schema: schema}
    end

    test "validates matching property after round-trip", %{schema: schema} do
      assert validate(roundtrip(schema), %{"foo" => 1}) == :ok
    end

    test "rejects mismatched type after round-trip", %{schema: schema} do
      refute valid?(roundtrip(schema), %{"foo" => "bar"})
    end
  end

  if :erlang.system_info(:otp_release) >= ~c"28" do
    describe "OTP 28+: patterns are compiled with :export for portability" do
      test "string pattern produces exported regex" do
        schema = Xema.new({:string, pattern: "^[a-z]+$"})
        assert exported_pattern?(schema.schema.pattern)
      end

      test "regex pattern without E is upgraded to exported" do
        schema = Xema.new({:string, pattern: ~r/^[a-z]+$/})
        assert exported_pattern?(schema.schema.pattern)
      end

      test "regex pattern with E stays exported" do
        regex_with_export = Regex.compile!("^[a-z]+$", "E")
        schema = Xema.new({:string, pattern: regex_with_export})
        assert exported_pattern?(schema.schema.pattern)
      end

      test "regex pattern with options is upgraded to exported" do
        schema = Xema.new({:string, pattern: ~r/^[a-z]+$/i})
        pattern = schema.schema.pattern
        assert exported_pattern?(pattern)
        assert :caseless in pattern.opts
      end

      test "exported regex does not leak E modifier into inspect" do
        schema = Xema.new({:string, pattern: "^[a-z]+$"})
        refute inspect(schema.schema.pattern) =~ "/E"
      end

      test "string pattern_properties keys are exported" do
        schema =
          Xema.new({
            :map,
            pattern_properties: %{"^s_" => :string}
          })

        keys = Map.keys(schema.schema.pattern_properties)
        assert Enum.all?(keys, &exported_pattern?/1)
      end

      test "regex pattern_properties keys are upgraded to exported" do
        schema =
          Xema.new({
            :map,
            pattern_properties: %{~r/^s_/ => :string}
          })

        keys = Map.keys(schema.schema.pattern_properties)
        assert Enum.all?(keys, &exported_pattern?/1)
      end

      test "schema with stale re_pattern raises without fix" do
        # Simulate a regex deserialized from another VM with a stale reference
        stale_ref = make_ref()
        stale_re_pattern = {:re_pattern, 0, 0, 0, stale_ref}
        stale_regex = %Regex{source: "^[a-z]+$", opts: [], re_pattern: stale_re_pattern}

        # Directly using the stale regex fails
        assert_raise ArgumentError, ~r/neither an iodata term/, fn ->
          Regex.match?(stale_regex, "abc")
        end
      end

      test "Xema.new/1 recompiles stale regex passed as pattern" do
        # Simulate a regex deserialized from another VM with a stale reference
        stale_ref = make_ref()
        stale_re_pattern = {:re_pattern, 0, 0, 0, stale_ref}
        stale_regex = %Regex{source: "^[a-z]+$", opts: [], re_pattern: stale_re_pattern}

        # pattern/1 recompiles the stale regex with :export during schema creation
        schema = Xema.new({:string, pattern: stale_regex})

        assert exported_pattern?(schema.schema.pattern)
        assert Xema.valid?(schema, "abc")
        refute Xema.valid?(schema, "123")
      end

      test "Xema.new/1 recompiles stale regex passed as pattern_properties key" do
        stale_ref = make_ref()
        stale_re_pattern = {:re_pattern, 0, 0, 0, stale_ref}
        stale_regex = %Regex{source: "^s_", opts: [], re_pattern: stale_re_pattern}

        # pattern_property/1 delegates to pattern/1 for %Regex{} keys
        schema =
          Xema.new({
            :map,
            pattern_properties: %{stale_regex => :string}, additional_properties: false
          })

        keys = Map.keys(schema.schema.pattern_properties)
        assert Enum.all?(keys, &exported_pattern?/1)
        assert Xema.valid?(schema, %{"s_foo" => "bar"})
        refute Xema.valid?(schema, %{"s_foo" => 42})
      end

      @tag :tmp_dir
      test "schema with pattern survives cross-VM serialization", %{tmp_dir: tmp_dir} do
        schema = Xema.new({:string, pattern: "^[a-z]+$"})
        path = Path.join(tmp_dir, "schema.bin")
        File.write!(path, :erlang.term_to_binary(schema))

        assert {output, 0} = run_in_subprocess(path)
        assert output =~ "PASS:valid"
        assert output =~ "PASS:invalid"
      end

      @tag :tmp_dir
      test "schema with pattern_properties survives cross-VM serialization", %{tmp_dir: tmp_dir} do
        schema =
          Xema.new({
            :map,
            pattern_properties: %{"^s_" => :string, "^i_" => :number},
            additional_properties: false
          })

        path = Path.join(tmp_dir, "schema.bin")
        File.write!(path, :erlang.term_to_binary(schema))

        script = """
        bin = File.read!(#{inspect(path)})
        schema = :erlang.binary_to_term(bin)

        case Xema.validate(schema, %{"s_1" => "foo", "i_1" => 42}) do
          :ok -> IO.write("PASS:valid_props ")
          {:error, _} -> IO.write("FAIL:valid_props ")
        end

        case Xema.validate(schema, %{"s_1" => 42}) do
          :ok -> IO.write("FAIL:type_mismatch ")
          {:error, _} -> IO.write("PASS:type_mismatch ")
        end
        """

        assert {output, 0} = System.cmd("mix", ["run", "-e", script], stderr_to_stdout: true)
        assert output =~ "PASS:valid_props"
        assert output =~ "PASS:type_mismatch"
      end
    end
  end

  defp roundtrip(schema) do
    schema
    |> :erlang.term_to_binary()
    |> :erlang.binary_to_term()
  end

  if :erlang.system_info(:otp_release) >= ~c"28" do
    defp exported_pattern?(%Regex{re_pattern: {:re_exported_pattern, _, _, _, _}}), do: true
    defp exported_pattern?(_), do: false

    defp run_in_subprocess(schema_path) do
      script = """
      bin = File.read!(#{inspect(schema_path)})
      schema = :erlang.binary_to_term(bin)

      case Xema.validate(schema, "abc") do
        :ok -> IO.write("PASS:valid ")
        {:error, _} -> IO.write("FAIL:valid ")
      end

      case Xema.validate(schema, "123") do
        :ok -> IO.write("FAIL:invalid ")
        {:error, _} -> IO.write("PASS:invalid ")
      end
      """

      System.cmd("mix", ["run", "-e", script], stderr_to_stdout: true)
    end
  end
end
