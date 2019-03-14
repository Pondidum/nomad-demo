job "hello-api" {
  datacenters = ["dc1"]
  type = "service"

  group "api" {
    count = 1

    task "api" {
      driver = "exec"

      config {
        command = "/usr/bin/dotnet"
        args = [
          "local/HelloApi.dll",
          "urls=http://*:${NOMAD_PORT_http}"
        ]
      }

      resources {
        network {
          port "http" {}
        }
      }

      service {
        name = "api"
        tags = ["api"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      artifact {
        source = "http://172.17.25.113:3030/helloapi.zip"
      }
    }
  }
}
