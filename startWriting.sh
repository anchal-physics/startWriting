echo 'Welcome to start writing.'
echo 'We will get you to writing your paper/thesis/presentation in minutes'

if ! command -v gh &> /dev/null
then
  echo 'gh not found.'
  read -p 'I will attempt installing gh (github CLI), is that ok (y/n)?'
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      if ! command -v brew &> /dev/null
      then
          echo 'brew not found'
          read -p 'I will attempt installing brew, is that ok (y/n)?'
          if [[ $REPLY =~ ^[Yy]$ ]]
          then
              echo 'Installing brew'
              /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi
      fi
      echo 'Installing gh...'
      echo 'Ensuring you have reading and writing permissions for required directories'
      sudo chown -R $(whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
      chmod u+w /usr/local/share/zsh /usr/local/share/zsh/site-functions
      brew install gh
  fi
fi
echo 'Logging into Github'
gh auth login
echo 'Choose a name for your writing project.'
read -p 'This will be the name of your repo: '
repo_name=$REPLY
echo 'Git repo will be created and cloned to current directory'
read -p 'Do you wish to initiate the git repo in a different location (y/n)?'
if [[ $REPLY =~ ^[Yy]$ ]]
then
    read -p 'Enter full path of new location:'
    cd $REPLY
fi
read -p 'Do you want your repo to be public (y) or private (n)?'
if [[ $REPLY =~ ^[Yy]$ ]]
then
    privacy="--public"
fi
if [[ $REPLY =~ ^[Nn]$ ]]
then
    privacy="--private"
fi
gh repo create $repo_name $privacy --clone
