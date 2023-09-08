#!/bin/sh

args="rnqknrpppppp............PPPPPPRNQKNR w"

j=0
while [ $j -le 40 ]; do
  args="$($1 $args)"
  echo "$args"
  j=$(( j + 1 ))
done
