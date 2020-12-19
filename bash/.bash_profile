if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  PATH=$PATH:$HOME/.local/bin exec startx
fi
