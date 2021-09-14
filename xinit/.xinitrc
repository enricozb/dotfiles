if [ $(hostname) = "carbon" ]; then
  if [ $(cat /sys/class/drm/card0-HDMI-A-1/status) = "connected" ]; then
    xft_dpi=""
    xrandr --output eDP-1 --off
  else
    xft_dpi="Xft.dpi: 144"
  fi

  echo "$xft_dpi" > ~/.Xresources
  xrdb ~/.Xresources

  xinput set-prop "SYNA8006:00 06CB:CD8B Touchpad" "libinput Natural Scrolling Enabled" 1
  xinput set-prop "SYNA8006:00 06CB:CD8B Touchpad" "libinput Click Method Enabled" 0 1
fi

setxkbmap -option caps:escape

exec dbus-launch i3
