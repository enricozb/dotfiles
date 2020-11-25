if [[ $(hostname) == "carbon" ]]; then
  xrdb ~/.Xresources
  setxkbmap -option caps:escape
  xinput set-prop "SYNA8006:00 06CB:CD8B Touchpad" "libinput Natural Scrolling Enabled" 1
  xinput set-prop "SYNA8006:00 06CB:CD8B Touchpad" "libinput Click Method Enabled" 0 1
fi

setxkbmap -option caps:escape

exec dbus-launch i3
