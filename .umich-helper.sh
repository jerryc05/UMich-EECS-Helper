um_uniqname=""
if [ -z $um_uniqname ]; then
  printf "Type your uniqname: "
  read um_uniqname
fi

caen_addr="login.engin.umich.edu"

if [ ! -f ~/.ssh/config ]; then
  mkdir -p ~/.ssh/
  touch ~/.ssh/config
fi

grep -q "Host  *caen" ~/.ssh/config || {
  echo "Host caen"                      >> ~/.ssh/config;
  echo "  HostName $caen_addr"          >> ~/.ssh/config;
  echo "  User $um_uniqname"            >> ~/.ssh/config;
  echo "  ControlMaster auto"           >> ~/.ssh/config;
  echo "  ControlPath ~/.ssh/_%r@%h:%p" >> ~/.ssh/config;
  echo "  ControlPersist 5h"            >> ~/.ssh/config;
  echo "  ServerAliveInterval 60"       >> ~/.ssh/config;
  echo "  ServerAliveCount 3"           >> ~/.ssh/config;
}



function um_rsync_fn() {
  local cmd=""

  git status &> /dev/null
  if [ $? -eq 0 ]; then
    local _clude_args="--include-from=- --exclude='*'"
    local cmd="git ls-files --exclude-standard | "
  else
    if [ -f .gitignore ]; then
      local _clude_args="--include='**.gitignore' --exclude='/.git' --filter=':- .gitignore'"
    else
      local _clude_args="--exclude '.git*'"
    fi
  fi
  local cmd="${cmd}rsync -hLrtvz --no-perms --no-owner --no-group --checksum --delete-after --inplace --no-whole-file --progress $_clude_args ./ $um_uniqname@caen:\"${PWD##*/}/\""
  echo $cmd
  echo
  eval $cmd
}

alias um-rsync=um_rsync_fn
