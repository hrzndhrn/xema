defmodule HttpServer do
  @moduledoc false

  @spec start(keyword) :: {:ok, any}
  def start(opts) do
    dispatch =
      :cowboy_router.compile([
        {:_,
         [
           {"/[...]", :cowboy_static, {:dir, opts[:dir]}}
         ]}
      ])

    ranch_opts = [{:port, opts[:port]}]
    cowboy_opts = %{env: %{dispatch: dispatch}}

    {:ok, _} = :cowboy.start_clear("http_server", ranch_opts, cowboy_opts)
  end
end
