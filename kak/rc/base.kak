# -------------------------------------- options --------------------------------------
set-option global autoreload true
set-option global scrolloff 3,0
set-option -add global ui_options ncurses_enable_mouse=false
set-option -add global ui_options ncurses_assistant=none
set-option -add global ui_options ncurses_status_on_top=yes

hook global InsertChar \t %{ exec -draft -itersel h@ }
set-option global tabstop 2
set-option global indentwidth 2


# --------------------------------------- style ----------------------------------------
add-highlighter global/ number-lines
add-highlighter global/ show-whitespaces
add-highlighter global/trailing-whitespace regex ([^\S\n]+)\n 1:red,bright-red
add-highlighter global/todo-fixme regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+r
colorscheme palernight


# --------------------------------------- remaps ---------------------------------------
# convenience
map -docstring 'case insensitive exact search' global normal / /(?i)\Q
map -docstring 'search' global normal ? /
map global normal <c-w> ': delete-buffer<ret>'
map global normal <backspace> ': delete-buffer-or-quit<ret>'
map global normal <c-_> ': comment-line<ret>' # <c-/> or <c-_>, the unit separator
map global normal D <a-x>d
map global normal = ': format<ret>'

# casing
map global normal ^ ': upper<ret>'
map global normal _ ': lower<ret>'

# jump
map global normal <c-o> <c-o>vv
map global normal <c-i> <c-i>vv
map global normal <c-f> "15j"
map global normal <c-q> "15k"

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

# lsp
map global normal <c-l> ': enter-user-mode lsp<ret>' -docstring "enter lsp mode"
map global lsp R        ': lsp-rename-prompt<ret>' -docstring "rename identifier"

# -------------------------------------- commands --------------------------------------
define-command where 'echo %val{buffile}'
define-command lower 'exec `'
define-command upper 'exec ~'
define-command W 'write'

define-command delete-buffer-or-quit %{
  evaluate-commands %sh{
      eval "set -- $kak_quoted_buflist"

      if [ "$kak_bufname" = '*debug*' ] ; then
        printf 'buffer-previous\n';
        exit;
      fi

      for buf; do
        # if there is a non-debug buffer other than the current buffer, just delete buffer
        if [ "$buf" != '*debug*' ] && [ "$buf" != "$kak_bufname" ]; then
          printf 'delete-buffer\n';
          exit;
        fi
      done

      printf "quit\n";
  }
}

# --------------------------------------- hooks ---------------------------------------
# enable flag-lines hl for git diff
hook global WinCreate .* %{
    add-highlighter window/git-diff flag-lines Default git_diff_flags
}

# trigger update diff if inside git dir
hook global BufOpenFile .* %{
    evaluate-commands -draft %sh{
        cd $(dirname "$kak_buffile")
        if [ $(git rev-parse --git-dir 2>/dev/null) ]; then
            for hook in WinCreate BufReload BufWritePost; do
                printf "hook buffer -group git-update-diff %s .* 'git update-diff'\n" "$hook"
            done
        fi
    }
}

# ------------------------------------ file-specific -----------------------------------
hook global WinSetOption filetype=c %{
  set-option window formatcmd "clang-format -"
}

hook global WinSetOption filetype=go %{
  set-option window formatcmd "goimports -local $(go mod edit -print | head -n 1 | awk '{print $2}')"

  hook -group golang-format-on-write window BufWritePre .* %{
    format
  }

  hook window -once -always WinSetOption filetype=.* %{
    unset-option window formatcmd
    remove-hooks window golang-format-on-write
  }
}

hook global WinSetOption filetype=python %{
  set-option window tabstop 4
  set-option window indentwidth 4
  set-option window formatcmd "isort - | yapf"
}

hook global WinSetOption filetype=typescript %{
  set-option window formatcmd \
    "npx prettier --stdin-filepath=${kak_buffile} --parser typescript"
}

hook global WinSetOption filetype=swift %{
  set-option window formatcmd "swiftformat --config %val{config}/.swiftformat"
}

hook global WinSetOption filetype=svelte %{
  set-option window formatcmd \
    "npx prettier --stdin-filepath=${kak_buffile} --parser svelte"
}

hook global WinSetOption filetype=latex %{
  map global normal ` i`<esc>a'<esc>
  map global normal "'" i`<esc>a'<esc>
  map global normal '"' i``<esc>a''<esc>
  map global normal $ i$<esc>a$<esc>

  set-option window formatcmd %{latexindent --yaml="defaultIndent: '  '"}
}

hook global BufCreate .*(sway)/config.d/[^\.]* %{
  set buffer filetype i3
}

hook global BufCreate .*i3/config.template %{
  set buffer filetype i3
}

hook global BufCreate .*\.(xm|x) %{
  set buffer filetype objc
}

hook global WinSetOption filetype=rust %{
  set-option window formatcmd "rustfmt"

  hook -group rust-format-on-write window BufWritePre .* %{
    format
  }

  hook window -once -always WinSetOption filetype=.* %{
    unset-option window formatcmd
    remove-hooks window rust-format-on-write
  }
}

hook global WinSetOption filetype=man %{
  remove-highlighter global/show-whitespaces
  map buffer normal <backspace> ': q<ret>'
}

# ----------------------------------- plugin options -----------------------------------
# fzf
require-module fzf
require-module fzf-file
# set-option global fzf_terminal_command 'nop %sh{wezterm cli split-pane ''kak -c %val{session} -e "%arg{@}"''}'
set-option global fzf_use_main_selection false
set-option global fzf_highlight_command bat
set-option global fzf_file_command "find . \( -path '*/.svn*' -o -path '*/.git/*' \) -prune -o -type f -print"
set-option global fzf_default_opts "%sh{echo ""$FZF_DEFAULT_OPTS""}"

# lsp
set-option global lsp_server_configuration pyls.configurationSources=["flake8"]
hook global WinSetOption filetype=(rust|go|javascript|typescript|python|svelte) %{
  lsp-enable-window
}

# smooth-scroll
# set-option global scroll_keys_normal \
#   <c-f> <c-b> <pageup> <pagedown> m M <a-semicolon> n <a-n> N <a-N>

# hook global WinCreate .* %{
#   hook -once window WinDisplay .* smooth-scroll-enable
# }
