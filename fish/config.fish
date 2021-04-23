# ---------------------- environment ---------------------
set fish_greeting                       # no greeting
set SHELL /usr/bin/fish
set -x VISUAL kak                       # editors
set -x EDITOR kak
set -x GIT_EDITOR kak
set -x TEXMFHOME "$HOME/.texmf"         # latex
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x FZF_OPEN_COMMAND "fd --no-ignore"
set -x FZF_DEFAULT_OPTS \
  "--color=16 --reverse \
   --preview 'bat --style=numbers --color=always --line-range :500 {}' \
   --tiebreak=length,end \
   --bind=tab:down,shift-tab:up"        # fzf
set -U FZF_LEGACY_KEYBINDINGS 0
set -x GOPATH "$HOME/.go"               # golang


# ------------------------- path -------------------------
set -x PATH $PATH "$HOME/.cargo/bin"        # rust
set -x PATH $PATH "$HOME/.elan/bin"         # lean
set -x PATH $PATH "$HOME/.go/bin/"          # golang
set -x PATH $PATH "$HOME/go/bin"            # golang
set -x PATH $PATH "$HOME/.local/bin/"       # personal scripts
set -x PATH $PATH "$HOME/.mathlib/bin"      # lean - mathlib
set -x PATH $PATH "$HOME/.node_modules/bin" # node
set -x PATH $PATH "$HOME/.poetry/bin"       # poetry python
set -x PATH $PATH "/opt/bin/"               # manual installs
set -x PATH $PATH "/usr/bin/vendor_perl/"   # exiftool


# ------------------------ aliases -----------------------
alias o "open"
alias l "ls"
alias cp "cp -p"
alias wiki "kak ~/wiki/_.md"
alias wg "wikigrep"
alias gg "lazygit"
alias tree "tree -C"

# force __fzf_open to use my `open`
alias xdg-open open


# ----------------------- functions ----------------------
function brave -w brave --description "open browser with specified profile"
  switch $argv
    case loretto
      command brave --profile-directory="Profile 1"
    case personal zoken
      command brave --profile-directory="Profile 2"
    case '*'
      command brave --profile-directory="Default"
  end
end


function work --description "default tmux session"
  tmux -2 new-session -A -s work
end


function wikigrep --description "grep wiki files for content"
  command rg -i -t md -t yaml \
    -g "!*/node_modules/*" \
    -g "!*/_target/*" \
    $argv ~/wiki
end


function wiki_find --description "find wiki filename with fzf"
  fd ".*\.(md|yuml)" \
    --base-directory ~/wiki \
    --exclude "*/node_modules/*" \
    --exclude "*/_target/*" \
    --no-ignore-vcs --follow | fzf
end


function wiki_open --description "find wiki filename with fzf"
  set -l file ~/wiki/(wiki_find)
  if [ -n "$file" ]
    command kak $file
  end
  commandline -f repaint
end


function wiki_insert --description "find wiki filename with fzf"
  commandline -it -- (wiki_find)
  commandline -it -- " "
end


function config --description "access configs"
  switch $argv
    case i3
      open "$HOME/.config/i3/config"
    case fish
      open "$HOME/.config/fish/config.fish"
    case kak sway
      cd "$HOME/.config/$argv"
    case ""
      set -l file ~/.config/(find -L ~/.config \
                   ! -path "*/lazygit/*/*" \
                   ! -path "*/BraveSoftware/*" \
                   -printf '%P\n' | fzf)
      if [ -n "$file" ]
        open $file
      end
    case "*"
      echo "Unknown arg '$argv'"
  end
end


function project_find --description "find a project dir with fzf"
  echo ~/wiki/activities/projects/(fd . \
      --base-directory ~/wiki/activities/projects \
      --type d \
      --follow \
    | fzf)
end


function project_open --description "cd into a project with fzf"
  set -l proj (project_find)

  if [ -n "$proj" ]
    cd $proj
    commandline -f repaint
    if test -e "pyproject.toml"
      # if a virtual env is set, deactivate before going into a new one
      if set -q VIRTUAL_ENV
        deactivate
      end
      echo -e "\n"(set_color yellow)"Found pyproject.toml"(set_color normal)
      source (poetry env list --full-path | awk '{ print $1 }')/bin/activate.fish
    end
  end
end


function project_insert --description "insert a project dir into the commandline"
  commandline -it -- (project_find)
  commandline -it -- " "
end


# Originally defined in /usr/share/fish/functions/__fish_prepend_sudo.fish @ line 1
# The modification here is so it has a toggling behavior on multiple presses.
function __fish_prepend_sudo -d "Prepend 'sudo ' to the beginning of the current commandline"
    set -l cmd (commandline -po)
    set -l cursor (commandline -C)
    if test "$cmd[1]" != sudo
        commandline -C 0
        commandline -i "sudo "
        commandline -C (math $cursor + 5)
    else
        commandline -r (string sub --start=6 (commandline -p))
        commandline -C -- (math $cursor - 5)
    end
end


function open
  switch (file -L -b --mime-type $argv[1])
    case 'application/pdf'
      zathura $argv & disown
    case 'text/*' 'inode/x-empty' 'application/octet-stream' 'application/json' 'application/csv'
      kak $argv
    case 'video/*'
      mpv $argv
    case 'inode/directory'
      cd $argv
    case 'image/*'
      sxiv $argv & disown
    case '*'
      command xdg-open $argv
  end
end

function man -w man -d "man with kak as the pager"
  kak -e "man $argv"
end


function ezb -d "ssh into main ezb machine"
  set -x TERM xterm-256color
  command ssh 192.168.2.147 -t fish
end


function mpv -w mpv -d "mpv with mpris"
  command mpv \
    --script=/home/enricozb/.config/mpv/scripts/mpris.so \
    --really-quiet $argv > /dev/null 2>&1 & disown
end


function __bound_nextd -w nextd -d "nextd with > binding"
  if [ -n (commandline) ]
    commandline -i ">"
  else
    nextd
    commandline -f repaint
  end
end

function __bound_prevd -w prevd -d "prevd with < binding"
  if [ -n (commandline) ]
    commandline -i "<"
  else
    prevd
    commandline -f repaint
  end
end


# ----------------------- bindings -----------------------
bind \ep project_open
bind \eP project_insert
bind \ew wiki_open
bind \eW wiki_insert
bind \eo __fzf_open
bind \eO __fzf_open_insert

bind \cw forward-word
bind \cb backward-kill-word
bind \cs __fish_prepend_sudo
bind \eC config
bind \> __bound_nextd
bind \< __bound_prevd


# ------------------------ source ------------------------
source "$HOME/.opam/opam-init/init.fish" > /dev/null 2> /dev/null or true

if [ -f "$HOME/.config/fish/config.local.fish" ]
  source "$HOME/.config/fish/config.local.fish"
end

# ephemeral configuration for tmux sessions that wrap kakoune clients
if [ ! -f /tmp/kak.tmux.conf ]
  echo "
    set -g mouse on
    set -g escape-time 0
    set -g default-terminal 'tmux-256color'
    set -g terminal-overrides ',*:Tc'
    set -g status off
  " > /tmp/kak.tmux.conf
end
