# ---------------------- environment ---------------------
set fish_greeting                       # no greeting
set SHELL /usr/bin/fish
set -x VISUAL kak                       # editors
set -x EDITOR kak
set -x GIT_EDITOR kak
set -x TEXMFHOME "$HOME/.texmf"         # latex
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x FZF_OPTS \
  --color=16 \
  --reverse \
  --preview 'bat --style=numbers --color=always --line-range :500 {}' \
  --tiebreak=length,end \
  --bind=tab:down,shift-tab:up          # fzf
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
alias wg "wiki_grep"
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


function wiki_grep --description "grep wiki files for content"
  command rg $argv ~/wiki \
    --ignore-case \
    --type md \
    --glob '!*/node_modules/*' --glob '!*/_target/*' \
    --follow
end


function wiki_find --description "find wiki filename with fzf"
  command fd \
    --base-directory ~/wiki \
    --extension md \
    --exclude 'node_modules/' --exclude '_target/' \
    --no-ignore-vcs \
    --follow \
    | fzf
end


function wiki_open --description "find wiki filename with fzf"
  set -l file ~/wiki/(wiki_find)
  if [ -n "$file" ]
    command kak $file
  end
  commandline -f repaint
end


function wiki_insert --description "find wiki filename with fzf"
  commandline --insert --current-token -- (wiki_find)
  commandline --insert --current-token -- " "
end


function project_find --description "find a project dir with fzf"
  echo ~/wiki/activities/projects/(
    command fd \
      --type d \
      --base-directory ~/wiki/activities/projects \
      --exclude 'node_modules/' --exclude '_target/' \
      --follow \
      | fzf
    )
end


function project_open --description "cd into a project with fzf"
  set -l proj (project_find)

  if [ -n "$proj" ]
    cd $proj
    commandline -f repaint
    if test -e 'pyproject.toml'
      # if a virtual env is set, deactivate before going into a new one
      if set -q VIRTUAL_ENV
        deactivate
      end
      echo -e '\n'(set_color yellow)'Found pyproject.toml'(set_color normal)
      set -l venv_file (poetry env list --full-path | awk '{ print $1 }')/bin/activate.fish
      if [ -f "$venv_file" ]
        source "$venv_file"
      else
        echo -e (set_color red)'No virtualenv'(set_color normal)
      end
    end
  end
end


function project_insert --description "insert a project dir into the commandline"
  commandline -it -- (project_find)
  commandline -it -- " "
end


function fzf_open --description "open a file using the fzf prompt"
  set -l path (fd --no-ignore-vcs | fzf $FZF_OPTS)
  if [ -f "$path" ]
    open "$path"
  else if [ -d "$path" ]
    cd "$path"
  end
  commandline -f repaint
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
      set -l file ~/.config/(
        command fd \
          --base-directory ~/.config/ \
          --exclude '*/BraveSoftware/*' \
          --follow \
          | fzf
      )
      if [ -n "$file" ]
        open $file
      end
    case "*"
      echo "Unknown arg '$argv'"
  end
end


function open
  switch (file -L -b --mime-type $argv[1])
    case 'application/pdf'
      zathura $argv > /dev/null 2>&1 & disown
      commandline -f exit
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
  if [ -n "$argv" ]; and command man "$argv" > /dev/null 2>&1
    command kak -e "man $argv"
  else
    command man $argv
  end 
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
bind \eo fzf_open
bind \eO fzf_insert

bind \cw forward-word
bind \cb backward-kill-word
bind \cs __fish_prepend_sudo
bind \ec config
bind \> __bound_nextd
bind \< __bound_prevd


# ------------------------ source ------------------------
source "$HOME/.opam/opam-init/init.fish" > /dev/null 2> /dev/null or true

if [ -f "$HOME/.config/fish/config.local.fish" ]
  source "$HOME/.config/fish/config.local.fish"
end
