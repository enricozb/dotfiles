#!/bin/bash
green="29BF12"
yellow="FF9914"
red="F21B3F"

i3lock \
  --ring-width=4 \
  --pass-media-keys \
  --separatorcolor=00000000 \
  --linecolor=00000000 \
  --radius=200 \
  --ringcolor=00000000 \
  --keyhlcolor=${green}ff \
  --bshlcolor=${red}ff \
  --insidecolor=252525bb \
  --verifcolor=00000000 \
  --insidevercolor=${yellow}99 \
  --ringvercolor=${yellow}99 \
  --wrongcolor=00000000 \
  --insidewrongcolor=${red}99 \
  --ringwrongcolor=${red}99 \
  --image "/home/enricozb/.config/wallpapers/Carmine De Fazio-2560x1440.png"
