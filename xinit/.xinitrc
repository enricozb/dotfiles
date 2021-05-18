if [ $(hostname) = "carbon" ]; then
  if [ $(cat /sys/class/drm/card0-HDMI-A-1/status) = "connected" ]; then
    xft_dpi=""
    rofi_dpi="rofi.dpi: 56"
  else
    xft_dpi="Xft.dpi: 144"
    rofi_dpi="rofi.dpi: 92"
  fi

  echo "\
    $xft_dpi
    $rofi_dpi

    rofi.run-command: fish -c '{cmd}'
    rofi.run-list-command: 'fish -c functions'" > ~/.Xresources

  xrdb ~/.Xresources
  xinput set-prop "SYNA8006:00 06CB:CD8B Touchpad" "libinput Natural Scrolling Enabled" 1
  xinput set-prop "SYNA8006:00 06CB:CD8B Touchpad" "libinput Click Method Enabled" 0 1
fi

setxkbmap -option caps:escape

exec dbus-launch i3
