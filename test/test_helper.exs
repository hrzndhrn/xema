Application.put_env(:xema, :loader, Test.RemoteLoader)
HttpServer.start(port: 1234, dir: "test/support/remote")

ExUnit.start(exclude: [])
