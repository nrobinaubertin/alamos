#!/bin/sh

args="rnqknrpppppp............PPPPPPRNQKNR w"

j=0
while [ $j -le 20 ]; do
  args="$(./alamos.py $args)"
  echo "$args"
  j=$(( j + 1 ))
done

args="rnqknrpppppp............PPPPPPRNQKNR w"

j=0
while [ $j -le 20 ]; do
  args="$(./alamos $args)"
  echo "$args"
  j=$(( j + 1 ))
done
