function fish_prompt
  set_color purple
  echo -n "["

  set_color red
  echo -n (whoami)

  set_color white
  echo -n " : "

  set_color green
  echo -n (prompt_pwd)

  set_color purple
  echo -n "] "

  set_color normal
end

