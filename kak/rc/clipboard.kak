declare-option bool clipboard_os false
declare-option bool clipboard_multiple_selections false
declare-option str clipboard_copy_cmd ""
declare-option str clipboard_paste_cmd ""

define-command -params 1 set_multiple_selections %{ set-option window clipboard_multiple_selections %sh{
  # only if there is just one cursor should we save the selections to the clipboard
  if [[ $kak_reg_hash = 1 ]]; then
    echo "false";
    if [[ $1 = yank ]]; then
      printf '%s' "$kak_main_reg_dquote" > ~/.clipboard;
      if [[ $kak_opt_clipboard_os ]]; then
        printf '%s' "$kak_main_reg_dquote" | $kak_opt_clipboard_copy_cmd > /dev/null 2>&1 &
      fi

      # sending OSC 52 to terminal, this might do the same thing as wl-copy, but
      # in a tmux session it will forward it I think? not super sure...
      encoded=$(printf %s "$kak_main_reg_dquote" | base64 | tr -d '\n')
      printf "\e]52;;%s\e\\" "$encoded" >/dev/tty
    fi
  else
    echo "true";
  fi
}}

hook global NormalKey '[ydc]' 'set_multiple_selections yank'

define-command sync-dquote-reg %{ eval %sh{
  if [[ $kak_opt_clipboard_os == true ]] && $kak_opt_clipboard_paste_cmd > /dev/null 2>&1; then
    $kak_opt_clipboard_paste_cmd > ~/.clipboard
  fi

  if [[ $kak_opt_clipboard_multiple_selections = false ]]; then
    dir=$(echo ~/.clipboard);
    printf "%s" "reg dquote %file{$dir}"
  fi
}}

evaluate-commands %sh{
  if wl-paste > /dev/null 2>&1; then
    echo "set global clipboard_copy_cmd 'wl-copy'"
    echo "set global clipboard_paste_cmd 'wl-paste --no-newline'"
    echo "set global clipboard_os true"
  elif xsel -bo > /dev/null 2>&1; then
    echo "set global clipboard_copy_cmd 'xsel -bi'"
    echo "set global clipboard_paste_cmd 'xsel -bo'"
    echo "set global clipboard_os true"
  else
    echo "echo -debug 'wl-copy and xclip both not found'"
  fi
}

map global normal p ': set_multiple_selections paste<ret>: sync-dquote-reg<ret>p'
map global normal P ': set_multiple_selections paste<ret>: sync-dquote-reg<ret>P'
map global normal R ': set_multiple_selections paste<ret>: sync-dquote-reg<ret>R'
