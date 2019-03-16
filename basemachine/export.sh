#! /bin/bash

set -e

vagrant up
vagrant package --name nomad-demo.box
vagrant box add --name local/nomad nomad-demo.box
vagrant destroy -f
