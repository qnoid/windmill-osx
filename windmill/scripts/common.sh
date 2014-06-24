#!/bin/bash

assert_exists ()
{
if [ -z "$1" ]; then
        echo $2
        exit 1
fi
}
