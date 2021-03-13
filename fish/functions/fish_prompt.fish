function fish_prompt
  set -l _status $status

  set_color magenta
  echo -n "["

  set_color red
  echo -n (whoami)

  set_color green
  echo -n "@"

  if [ $hostname = carbon ]
    set_color yellow
  else
    set_color cyan
  end
  echo -n "$hostname"

  set_color white
  echo -n " "

  set_color green
  echo -n (prompt_pwd)

  if [ $_status -ne 0 ]
    set_color -o red
    echo -n " $_status "
    set_color normal
  end

  set_color magenta
  echo -n "] "

  set_color normal
end

