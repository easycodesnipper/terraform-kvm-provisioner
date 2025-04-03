#!/bin/bash

# If running as root, drop privileges to tfuser
if [ "$(id -u)" = "0" ]; then
  exec gosu tfuser terraform "$@"
fi

# If not root, run terraform directly
exec terraform "$@"