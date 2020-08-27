# Have special highlightings for grouping chars like {([

declare-option range-specs show_in_braces
declare-option range-specs show_in_parens
declare-option range-specs show_in_bracks

define-command -hidden -params 2 select_char %{
  evaluate-commands -draft -itersel %{ try %{
    execute-keys "<a-a>%arg{1}<a-S>"
    evaluate-commands -itersel %{
      set-option -add window "show_in_%arg{2}" "%val{selection_desc}|MatchingChar"
    }
  }}
}

define-command -hidden highlight_groups %{
  set-option window show_in_braces "%val{timestamp}"
  set-option window show_in_parens "%val{timestamp}"
  set-option window show_in_bracks "%val{timestamp}"
  select_char B braces
  select_char b parens
  select_char r bracks
}

add-highlighter global/ ranges show_in_braces
add-highlighter global/ ranges show_in_parens
add-highlighter global/ ranges show_in_bracks

hook global NormalIdle .* %{ highlight_groups }
hook global NormalKey .* %{ highlight_groups }
hook global InsertIdle .* %{ highlight_groups }
hook global InsertKey .* %{ highlight_groups }
