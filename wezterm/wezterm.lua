local wezterm = require 'wezterm';

return {
  font_dirs = {"/usr/share/fonts"},
  font = wezterm.font("Terminus (TTF)"),
  font_size = 12.0,

  colors = {
    background = '#0A0E14',
    foreground = '#B3B1AD',

    ansi = {'#01060E', '#EA6C73', '#91B362', '#F9AF4F', '#53BDFA', '#CC7CD9', '#90E1C6', '#C7C7C7'},
    brights = {'#686868', '#F07178', '#C2D94C', '#FFB454', '#59C2FF', '#FFEE99', '#95E6CB', '#FFFFFF'},
  },

  window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  },

  exit_behavior = "Close",

  leader = { key="a", mods="CTRL", timeout_milliseconds=1000 },
  keys = {
    {key="|", mods="LEADER", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    {key="-", mods="LEADER", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    {key="v", mods="CTRL", action=wezterm.action{PasteFrom="Clipboard"}},
    {key="c", mods="CTRL", action=wezterm.action{CopyTo="Clipboard"}},
    {key="x", mods="CTRL", action=wezterm.action{SendString="\x03"}},
  },

  ssh_domains = {
    {
      name = "xibalba",
      remote_address = "10.0.0.67",
      username = "enricozb",
    }
  }
}
