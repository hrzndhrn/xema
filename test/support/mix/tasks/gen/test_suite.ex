defmodule Mix.Tasks.Gen.TestSuite do
  use Mix.Task

  @url "https://github.com/json-schema-org/JSON-Schema-Test-Suite"
  @test_suite_path "JSON-Schema-Test-Suite"
  @test_path "test/json_schema_test_suite"
  @template File.read!("test/support/test.eex")
  @exclude [
    # Unsupported JSON Schema versions
    "draft3",
    "draft2019-08",
    # Unsupported optional features
    "ecmascript-regex.json",
    "json-pointer.json",
    "zeroTerminatedFloats.json",
    "iri.json",
    "iri-reference.json",
    "idn-hostname.json",
    "idn-email.json",
    "content.json"
  ]

  @exclude_test_case [
    # Unsupported feature. This test defines sub-schema outside `definitions`.
    "escaped pointer ref",
    "fragment within remote ref",
    "ref within remote ref",
    # will be supported soon
    "Location-independent identifier with absolute URI",
    "Location-independent identifier with base URI change in subschema"
  ]

  def run(_) do
    IO.puts("Generate JSON Schema test suite.")

    case File.dir?(@test_suite_path) do
      true ->
        gen_test_suite(@test_suite_path)

      false ->
        path = File.cwd!() |> Path.join(@test_suite_path)

        IO.puts(
          "Error: Can't find JSON Schema Test Suite at #{path}, " <>
            "please download test suite from: #{@url} ."
        )
    end
  end

  defp gen_test_suite(path) do
    File.cwd!() |> Path.join(@test_path) |> File.rm_rf!()

    path
    |> Path.join("tests")
    |> get_file_names()
    |> Enum.map(&read_json/1)
    |> Enum.map(&create_tests/1)
    |> Enum.map(&write_test_file/1)
  end

  defp get_file_names(path) do
    case File.dir?(path) do
      true ->
        path
        |> File.ls!()
        |> Enum.map(&Path.join(path, &1))
        |> Enum.filter(&include?/1)
        |> Enum.flat_map(&get_file_names/1)

      false ->
        case include?(path) do
          true -> [path]
          false -> []
        end
    end
  end

  defp write_test_file({file_name, code}) do
    path = File.cwd!() |> Path.join(file_name)
    path |> Path.dirname() |> File.mkdir_p!()
    File.write!(path, code)
  end

  defp include?(file), do: not Enum.any?(@exclude, &String.ends_with?(file, &1))

  defp read_json(file_name), do: {file_name, file_name |> File.read!() |> Jason.decode!()}

  defp create_tests({file_name, json}),
    do: {test_file_name(file_name), test_code(file_name, json)}

  defp test_file_name(file_name) do
    file_name
    |> String.replace(Path.join(@test_suite_path, "tests"), @test_path)
    |> ConvCase.to_snake_case()
    |> String.replace(~r/.json$/, "_test.exs")
  end

  defp test_code(file_name, test_cases) do
    test_cases =
      test_cases
      |> Enum.filter(fn test_case -> test_case["description"] not in @exclude_test_case end)
      |> update_descriptions()

    EEx.eval_string(@template,
      assigns: [module: module_name(file_name), test_cases: test_cases]
    )
    |> Code.format_string!()
  end

  defp module_name(file_name) do
    regex = ~r/#{@test_suite_path}\/tests\/(.*).json$/
    [_, name] = Regex.run(regex, file_name)
    module = name |> ConvCase.to_camel_case() |> Macro.camelize()
    "JsonSchemaTestSuite.#{module}"
  end

  defp update_descriptions(test_cases) do
    Enum.reduce(test_cases, [], fn test_case, acc ->
      [update_description(test_case, acc, 0) | acc]
    end)
    |> Enum.reverse()
  end

  defp update_description(test_case, test_cases, count) do
    description =
      case count do
        0 -> test_case["description"]
        n -> ~s|#{test_case["description"]} (#{n})|
      end

    Enum.any?(test_cases, fn
      %{"description" => ^description} -> true
      _ -> false
    end)
    |> case do
      false ->
        Map.put(test_case, "description", description)

      true ->
        update_description(test_case, test_cases, count + 1)
    end
  end
end
