* can an artifact be a local path?
    * can I use `/vagrant/app/.build/consumer.zip`
    * nope!
* is hyperv network adaptor stable yet?!?!
    * on LAN it is so far...
* test service discovery within app in nomad
    * 1x rmq node
    * 1x app
    * consuuuume
    * publish from localhost?
* can I link a localhost consul instance to nomad server?
    ```shell
    consul agent \
        -client 0.0.0.0 \
        -bind "$(cat machine_ip)" \
        -join "$(cat server_ip)" \
        -data-dir /d/tmp/consul/ \
        -ui
    ```


