#!/bin/bash
if pidof -o %PPID -x “rclone_script.sh”; then
exit 1
fi
rclone copy /mnt/vault/lenovo/personal/ secret: -v --no-traverse --bwlimit 5M --min-age 15m
exit
