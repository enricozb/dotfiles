# -------------------------------------- options --------------------------------------
set-option global autoreload true
set-option global scrolloff 3,0
set-option global ui_options ncurses_enable_mouse=false
set-option global ui_options ncurses_assistant=none

hook global InsertChar \t %{ exec -draft -itersel h@ }
set-option global tabstop 2
set-option global indentwidth 2


# --------------------------------------- style ----------------------------------------
add-highlighter global/numbers number-lines
add-highlighter global/trailing-whitespace regex ([^\S\n]+)\n 1:red,bright-red
add-highlighter global/todo-fixme regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+r
add-highlighter global/col-89 column 89 default,rgb:252525
colorscheme palernight


# --------------------------------------- remaps ---------------------------------------
# convenience
map -docstring 'case insensitive exact search' global normal / /(?i)\Q
map -docstring 'search' global normal ? /
map global normal <backspace> ': q<ret>'
map global normal  ': comment-line<ret>' # <c-/> or <c-_>, the unit separator
map global normal D <a-x>d
map global normal = ': format<ret>'

# jump
map global normal <c-o> <c-o>vv
map global normal <c-i> <c-i>vv
map global normal <c-f> "15j"
map global normal <c-b> "15k"

# surround
map global normal <a-I> <a-a>
map global normal ( i(<esc>a)<esc>
map global normal { i{<esc>a}<esc>
map global normal [ i[<esc>a]<esc>
map global normal '"' 'i"<esc>a"<esc>'
map global normal "'" "i'<esc>a'<esc>"
map global normal ` i`<esc>a`<esc>

# fzf
map global normal <c-p> ': fzf-mode<ret>' -docstring "fzf-mode"
map global normal <c-r> ': fzf-mode<ret>s' -docstring "fzf search"
map global normal <a-o> ': fzf-mode<ret>f' -docstring "fzf open file"
map global normal <c-s> ': fzf-mode<ret>b' -docstring "fzf switch buffer"


# -------------------------------------- commands --------------------------------------
define-command d "buffer *debug*"
define-command D "buffer *debug*"
define-command lower "exec `"
define-command upper "exec ~"
define-command W "write"


# ------------------------------------ file-specific -----------------------------------
hook global WinSetOption filetype=c %{
  set-option window formatcmd "clang-format -"
}

hook global WinSetOption filetype=go %{
  set-option window formatcmd "gofmt"
}

hook global WinSetOption filetype=python %{
  set-option window tabstop 4
  set-option window indentwidth 4
  set-option window formatcmd "isort - | black -"
  add-highlighter global/ show-whitespaces
}

hook global WinSetOption filetype=typescript %{
  set-option window formatcmd \
    "prettier --stdin-filepath=${kak_buffile} --parser typescript"
}

hook global WinSetOption filetype=man %{
  remove-highlighter global/col-89
  map buffer normal q :q<ret>
}

hook global BufCreate .*(sway)/config.d/[^\.]* %{
  set buffer filetype i3
}

hook global BufCreate .*i3/config.template %{
  set buffer filetype i3
}

hook global WinSetOption filetype=rust %{
  set-option window formatcmd "rustfmt"
}


# ----------------------------------- plugin options -----------------------------------
# fzf
require-module fzf
set-option global fzf_use_main_selection false
set-option global fzf_highlight_command bat
set-option global fzf_file_command \
  "find . \( -path '*/.svn*' -o -path '*/.git/*' \) -prune -o -type f -print"
set-option global fzf_default_opts "%sh{echo ""$FZF_DEFAULT_OPTS""}"

# smooth-scroll
# set-option global scroll_keys_normal \
#   <c-f> <c-b> <pageup> <pagedown> m M <a-semicolon> n <a-n> N <a-N>

# hook global WinCreate .* %{
#   hook -once window WinDisplay .* smooth-scroll-enable
# }
