define-command clip-yank %{
  evaluate-commands %sh{
    if [ "$kak_reg_hash" = 1 ]; then
      printf '%s' "$kak_main_reg_dquote" | clip >/dev/null

      # send OSC 52
      b64selection=$(printf '%s' "$kak_main_reg_dquote" | base64 | tr -d '\n')
      printf "\e]52;;%s\e\\" "$b64selection" >/dev/tty
    fi
  }
}

define-command clip-paste %{
  evaluate-commands %sh{
    if [ "$kak_reg_hash" = 1 ]; then
      tmp=$(mktemp)
      clip > "$tmp"
      printf '%s\n' "reg dquote %file{$tmp}"
    fi
  }
}

hook global NormalKey '[ydc]' clip-yank

map global normal p ': clip-paste<ret>p'
map global normal P ': clip-paste<ret>P'
map global normal R ': clip-paste<ret>R'
