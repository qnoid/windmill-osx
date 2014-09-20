#!/bin/bash

assert_exists ()
{
if [ -z "$1" ]; then
    echo "[windmill] [required] $2"
    exit 1
fi
}

if_string_is_empty ()
{
echo "[windmill] [debug] [$FUNCNAME] '$1'"
if [ -z "$1" ]; then
$2
fi
}

assert_file_exists_at_path ()
{
if [ ! -f "${1}" ]; then
    echo "[windmill] [required] $2"
    exit 1
fi
}

assert_directory_exists_at_path ()
{
if [ ! -d "${1}" ]; then
    echo "[windmill] [required] $2"
    exit 1
fi
}

file_does_not_exist_at_path ()
{
if [ ! -f "$1" ]; then
$2
fi
}

directory_does_not_exist_at_path ()
{
echo "[windmill] [debug] [$FUNCNAME] $1"
if [ ! -d "$1" ]; then
$2
fi
}

file_exist_at_path ()
{
if [ -f "$1" ]; then
$2
fi
}

function directory_exist_at_path ()
{
echo "[windmill] [debug] [$FUNCNAME] $1"
if [ -d "$1" ]; then
$2
else
$3
fi
}