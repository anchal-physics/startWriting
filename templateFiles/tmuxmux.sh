#------------------------------------------------------------------------------
# Function added by startWriting

tmuxmux() {
  session=$1
  command=$2
  sessionMult='x'
  tmux has-session -t $session 2>/dev/null
  if [ $? != 0 ]
  then
    tmux new -d -s "$session"
    tmux send -t "$session" "$command" Enter
    echo 'Made new session: '"$session"
    echo 'With command: '"$command"
  else
    echo 'Session '"$session"' already exists'
    while ! [ $? != 0 ]
    do
      session+=$sessionMult
      tmux has-session -t $session 2>/dev/null
    done
    tmux new -d -s "$session"
    tmux send -t "$session" "$command" Enter
    echo 'Made new session: '"$session"
    echo 'With command: '"$command"
  fi
}

#------------------------------------------------------------------------------
