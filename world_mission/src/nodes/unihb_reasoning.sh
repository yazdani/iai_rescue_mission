#!/bin/bash
"true";exec /usr/bin/env rosrun roslisp run-roslisp-script.sh --script "$0" "$@"

(ros-load:load-system "startup_mission" "startup-mission")
(in-package :startup-mission)

(start-mission)
