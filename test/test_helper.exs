Application.put_env(:xema, :loader, Test.RemoteLoaderJson)
HttpServer.start(port: 1234, dir: "test/support/remote")

ExUnit.start(exclude: [])
