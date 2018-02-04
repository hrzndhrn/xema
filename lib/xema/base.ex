defmodule Xema.Base do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      @behaviour Xema.Base
      # def hello(name), do: "Hi, #{name}"
      alias Xema.Base

      @enforce_keys [:content]

      @type t :: %__MODULE__{
              content: Xema.Schema.t()
            }

      defstruct [
        :content
      ]

      @spec create(Xema.Schema.t()) :: __MODULE__.t()
      def create(schema), do: struct(__MODULE__, content: schema)
    end
  end

  @callback is_valid?(struct, any) :: boolean
  @callback validate(struct, any) :: Xema.Validator.result()
end
