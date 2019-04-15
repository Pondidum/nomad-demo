#! /bin/bash

./scripts/init.sh

tmux new-session \; \
    send-keys './scripts/consul.sh' C-m \; \
    split-window -h \; \
    send-keys './scripts/host.sh' C-m \;
