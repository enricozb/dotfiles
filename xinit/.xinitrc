xrdb ~/.Xresources
setxkbmap -option caps:escape
xinput set-prop "SYNA8006:00 06CB:CD8B Touchpad" "libinput Natural Scrolling Enabled" 1
exec dbus-launch i3
