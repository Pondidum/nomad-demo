job "consumer" {
  datacenters = ["dc1"]
  type = "service"

  group "consumers" {
    count = 5

    task "consumer" {
      driver = "exec"

      config {
        command = "/usr/bin/dotnet"
        args = [
          "local/Consumer.dll"
        ]
      }

      artifact {
        source = "http://artifacts.service.consul:5050/.build/Consumer.zip"
      }
    }
  }
}
