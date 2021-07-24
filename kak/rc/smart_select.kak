define-command try-surround -params 2 -docstring "try the next selection and intersect" %{
  try %{
    evaluate-commands -draft %{
      execute-keys "%arg{1}"
      evaluate-commands %sh{
        expansion_validity=$(\
          echo "$2 $kak_selection_desc" \
            | sed -e "s/[,\.]/ /g" \
            | awk '{print ((($1 > $5) || (($1 >= $5) && ($6 <= $2))) &&\
                           (($3 < $7) || (($3 <= $7) && ($8 >= $4)))) ?\
                           "valid" : "invalid"}'
        )
        if [[ "$expansion_validity" == "valid" && "$2" != "$kak_selection_desc" ]]; then
          if [ -z "$kak_reg_caret" ]; then
            # echo "echo -debug 'not inter $1'"
            echo "exec -save-regs '/\"|@' Z"
          else
            # echo "echo -debug 'yes inter $1 ($kak_selection_desc vs $2) '"
            echo "exec -save-regs '/\"|@' <a-z>iZ"
          fi
        else
          # echo "echo -debug 'equal sel on $1'"
          echo "fail 'invalid selection'"
        fi
      }
    }
  }
}

define-command smart-select %{ eval %sh{
  echo "reg ^ ''"
  # echo "echo -debug 'smart-select on $kak_selection_desc'"
  for surr in b B r a Q q g w "<a-w>" s p "<space>" i u n; do
    echo "try-surround '<a-i>$surr' '$kak_selection_desc'"
    echo "try-surround '<a-a>$surr' '$kak_selection_desc'"
  done
  echo "try-surround 'x' '$kak_selection_desc'"
  echo "exec z"
}}

map global normal <c-w> ': smart-select<ret>'


