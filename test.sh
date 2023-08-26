#!/bin/sh

args="rnqknrpppppp............PPPPPPRNQKNR w"

j=0
while [ $j -le 20 ]; do
  args="$($1 $args)"
  echo "$args"
  j=$(( j + 1 ))
done
