# ---------------------- environment ---------------------
set fish_greeting                       # no greeting
set SHELL /usr/bin/fish
set -x VISUAL kak                       # editors
set -x EDITOR kak
set -x GIT_EDITOR kak
set -x TEXMFHOME "$HOME/.texmf"         # latex
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x FZF_DEFAULT_OPTS \
  "--color=16 --reverse \
   --preview 'bat --style=numbers --color=always --line-range :500 {}' \
   --tiebreak=length,end \
   --bind=tab:down,shift-tab:up"        # fzf
set -U FZF_LEGACY_KEYBINDINGS 0

# ------------------------- path -------------------------
set -x PATH "$HOME/.cargo/bin" $PATH        # rust
set -x PATH "$HOME/.elan/bin" $PATH         # lean
set -x PATH "$HOME/.local/bin/" $PATH       # personal scripts
set -x PATH "$HOME/.mathlib/bin" $PATH      # lean - mathlib
set -x PATH "$HOME/.node_modules/bin" $PATH # node
set -x PATH "$HOME/.poetry/bin" $PATH       # poetry python
set -x PATH "/opt/bin/" $PATH               # manual installs

# ------------------------ aliases -----------------------
alias o "open"
alias l "ls"
alias cp "cp -p"
alias wiki "kak ~/wiki/index.md"
alias wg "wikigrep"
alias gg "lazygit"
alias tree "tree -C"

# ----------------------- functions ----------------------
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
  echo ~/wiki/(find -L ~/wiki \
               ! -path "*/node_modules/*" \
               ! -path "*/_target/*" \
               -regex ".*\.\(md\|yuml\)" -printf "%P\n" | fzf)
end


function wiki_open --description "find wiki filename with fzf"
  set -l file (wiki_find)
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
  echo ~/wiki/activities/projects/(find ~/wiki/activities/projects \
      -type d \
      -not -path '*/\.*' \
      -printf "%P\n" \
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
    case 'text/*' 'inode/x-empty' 'application/octet-stream' 'application/json'
      kak $argv
    case 'video/*'
      mpv $argv
    case 'inode/directory'
      cd $argv
    case 'image/*'
      sxiv $argv & disown
    case '*'
      xdg-open $argv
  end
end


function man -w man -d "man with kak as the pager"
  command kak -e "man $argv"
end


function ezb -d "ssh into main ezb machine"
  command ssh 192.168.2.101
end


function mpv -w mpv -d "mpv with mpris"
  command mpv \
    --script=/home/enricozb/.config/mpv/scripts/mpris.so \
    --really-quiet $argv > /dev/null 2>&1 & disown
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


# ------------------------ source ------------------------
source "$HOME/.opam/opam-init/init.fish" > /dev/null 2> /dev/null or true
