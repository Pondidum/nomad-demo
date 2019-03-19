#! /bin/bash

tmux new-session \; \
    split-window -h \; \
    send-keys './scripts/artifacts.sh' C-m \; \
    split-window -v -p 66 \; \
    send-keys './scripts/registry.sh' C-m \; \
    split-window -v -p 50 \; \
    send-keys './scripts/consul.sh' C-m \; \
    select-pane -t 0 \; \
    send-keys './scripts/cli.sh' C-m \;