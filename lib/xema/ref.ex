defmodule Xema.Ref do
  @moduledoc """
  TODO: doc
  """

  import Xema.Utils, only: [get_value: 2]

  alias Xema.Ref
  alias Xema.Schema

  @type t :: %Xema.Ref{pointer: String.t(), schema: Xema.t() | nil}

  defstruct pointer: "", schema: nil

  @spec new(keyword | String.t()) :: Ref.t()

  def new(pointer) when is_binary(pointer), do: %Ref{pointer: pointer}

  def new(opts), do: struct(Ref, opts)

  def new(%URI{} = uri, schema),
    do: %Ref{pointer: URI.to_string(uri), schema: nil}

  def new(pointer, schema), do: %Ref{pointer: pointer, schema: nil}


  def validate(%Ref{pointer: "#"}, value, opts) do
    Xema.validate(opts[:root].content, value, opts)
  end

  def validate(%Ref{pointer: "#/" <> pointer}, value, opts) do
    case do_get(pointer, opts[:root]) do
      {:ok, %Schema{} = schema} -> Xema.validate(schema, value, opts)
      {:ok, %Ref{} = ref} -> validate(ref, value, opts)
      _error -> {:error, :ref_not_found}
      #_error -> {:error, ref}
    end
  end

  def validate(%Ref{pointer: "http" <> _ = pointer}, value, opts) do
    xema = Map.get(opts[:root].refs, del_fragment(pointer))
    pointer = get_fragment(pointer)
    # schema = pointer |> get_fragment() |> do_get(xema)

    case do_get(pointer, xema) do
      {:ok, %Schema{} = schema} -> Xema.validate(schema, value, root: xema)
      {:ok, %Ref{} = ref} -> validate(ref, value, root: xema)
      _error -> {:error, :ref_not_found}
      #_error -> {:error, ref}
    end
    #Xema.validate(schema, value, root: xema)
  end



  def validate(ref, value, opts) do
    #IO.inspect opts
    #IO.inspect ref
    # raise "Ups"
    case get(ref, opts[:root], opts[:id]) do
      {:ok, %Schema{} = schema} -> Xema.validate(schema, value, opts)
      {:ok, %Ref{} = ref} -> validate(ref, value, opts)
      _error -> {:error, :ref_not_found}
      #_error -> {:error, ref}
    end
  end



  @spec get(Ref.t(), Xema.t() | Schema.t() | String.t() | nil) ::
          {:ok, Schema.t()} | {:error, atom}
  def get(ref, id) when is_binary(id), do: get(ref, ref.schema, id)

  def get(ref, schema), do: get(ref, schema, nil)

  @spec get(Ref.t(), Xema.t() | Schema.t(), String.t()) ::
          {:ok, Schema.t()} | {:error, atom}
  def get(ref, schema, id)

  def get(%Ref{pointer: "#"}, xema, _), do: {:ok, get_schema(xema)}

  def get(%Ref{pointer: "#/" <> pointer, schema: nil}, xema, _id) do
    #IO.puts("=========")
    #IO.inspect xema
    do_get(pointer, xema)
  end

  def get(%Ref{pointer: "#/" <> pointer, schema: xema}, _xema, _id) do
    do_get(pointer, xema)
  end

  def get(%Ref{pointer: "http" <> _ = pointer, schema: _x}, xema, _) do
    xema = Map.get(xema.refs, del_fragment(pointer))

    pointer
    |> get_fragment()
    |> do_get(xema)
  end

  def get(ref, xema, id) when not is_nil(id) do
    id =
      id
      |> URI.merge(ref.pointer)
      |> URI.to_string()

    case Map.get(xema.ids, id) do
      nil ->
        {:error, :not_found}

      id_ref ->
        get(id_ref, xema.content, nil)
    end
  end

  def get(_, _, _), do: {:error, :invalid_ref}

  defp do_get(_, nil), do: {:error, :not_found}

  defp do_get("#", xema), do: {:ok, get_schema(xema)}

  defp do_get("#" <> pointer, xema), do: do_get(pointer, xema)

  defp do_get(pointer, %Xema{} = xema)
       when is_binary(pointer),
       do: do_get(pointer, xema.content)

  defp do_get(pointer, schema)
       when is_binary(pointer),
       do:
         pointer
         |> String.trim("/")
         |> String.split("/")
         |> do_get(schema)

  defp do_get([], schema), do: {:ok, schema}

  defp do_get([step | steps], schema) when is_map(schema) do
    case get_value(schema, decode(step)) do
      {:ok, value} -> do_get(steps, value)
      {:error, _} -> {:error, :not_found}
    end
  end

  defp do_get([step | steps], schema) when is_list(schema) do
    with {:ok, index} <- to_integer(step) do
      case Enum.at(schema, index) do
        nil -> {:error, :not_found}
        value -> do_get(steps, value)
      end
    end
  end

  defp get_fragment(str) do
    case URI.parse(str) do
      %URI{fragment: nil} -> "#"
      %URI{fragment: fragment} -> fragment
    end
  end

  defp del_fragment(str),
    do: str |> URI.parse() |> Map.put(:fragment, nil) |> URI.to_string()

  defp get_schema(schema) do
    case schema do
      %Xema{content: schema} -> schema
      %Schema{} = schema -> schema
      %Ref{schema: schema} -> schema
    end
  end

  defp decode(str) do
    str
    |> String.replace("~0", "~")
    |> String.replace("~1", "/")
    |> URI.decode()
  rescue
    _ -> str
  end

  defp to_integer(str) do
    case Regex.run(~r/\d+/, str) do
      nil -> {:error, :not_found}
      [int] -> {:ok, String.to_integer(int)}
    end
  end

  def to_string(ref) do
    "{:ref, #{inspect(ref.pointer)}}"
  end
end

defimpl String.Chars, for: Xema.Ref do
  @spec to_string(Xema.Ref.t()) :: String.t()
  def to_string(ref), do: Xema.Ref.to_string(ref)
end