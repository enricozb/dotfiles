#!/bin/bash
green="29BF12"
yellow="FF9914"
red="F21B3F"

i3lock \
  --ring-width=4 \
  --pass-media-keys \
  --separator-color=00000000 \
  --line-color=00000000 \
  --radius=200 \
  --ring-color=00000000 \
  --keyhl-color=${green}ff \
  --bshl-color=${red}ff \
  --inside-color=252525bb \
  --verif-color=00000000 \
  --insidever-color=${yellow}99 \
  --ringver-color=${yellow}99 \
  --wrong-color=00000000 \
  --insidewrong-color=${red}99 \
  --ringwrong-color=${red}99 \
  --image "/home/enricozb/.config/wallpapers/Carmine De Fazio-2560x1440.png"
