#!/bin/sh

LIGHTFILE=/sys/class/leds/chromeos::kbd_backlight/brightness
total=$(expr $(cat $LIGHTFILE) $1 10)

if [ total -lt 0 ]; then
  total=0
fi

if [ total -gt 100 ]; then
  total=100
fi

echo $total > $LIGHTFILE
