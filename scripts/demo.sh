#! /bin/bash

./scripts/init.sh

tmux new-session \; \
    send-keys './scripts/consul.sh' C-m \; \
    split-window -h \; \
    send-keys './scripts/artifacts.sh' C-m \; \
    split-window -v -p 66 \; \
    send-keys './scripts/registry.sh' C-m \; \
    split-window -v -p 50 \; \
    send-keys './scripts/cli.sh' C-m \;
