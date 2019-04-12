#! /bin/bash

set -e

box_name=nomad-demo.box

rm -f $box_name

vagrant up

vagrant package --output $box_name
vagrant box add --force --name local/nomad $box_name

vagrant destroy -f
