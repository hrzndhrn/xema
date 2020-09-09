Application.put_env(:xema, :loader, Test.RemoteLoaderJson)
HttpServer.start(port: 1234, dir: "test/fixtures/remote")

ExUnit.start(exclude: [])
