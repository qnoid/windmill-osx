#!/bin/bash

assert_exists ()
{
if [ -z "$1" ]; then
        echo "[windmill] $2"
        exit 1
fi
}
