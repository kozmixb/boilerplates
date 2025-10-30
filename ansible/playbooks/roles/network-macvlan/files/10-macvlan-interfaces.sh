#!/bin/bash

ip link add macvlan link eth0 type macvlan mode bridge
