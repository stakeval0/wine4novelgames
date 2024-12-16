#!/bin/zsh
#PULSE_SERVER="/mnt/wslg/PulseServer"
PULSE_SERVER="/run/user/1000/pulse/native"
docker run --mount type=bind,src=$(pwd)/share,dst=/home/docker/share \
           --mount type=bind,src=/tmp/.X11-unix/,dst=/tmp/.X11-unix,readonly \
           --mount type=bind,src=$PULSE_SERVER,dst=/mnt/PulseServer,readonly \
           --security-opt=no-new-privileges:false \
           --net=bridge --env DISPLAY=$DISPLAY --env PULSE_SERVER=/mnt/PulseServer \
           -it --rm wine
