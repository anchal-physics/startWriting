#!/bin/bash

prepTemplateFile() {
    file=$1
    sed -i .bak 's|<repoName>|'"$repoName"'|' $file
    sed -i .bak 's|<category>|'"$category"'|' $file
    sed -i .bak 's|<baseURL>|'"$baseURL"'|' $file
    sed -i .bak 's|<outputFileName>|'"$outputFileName"'|' $file
    sed -i .bak 's|<mainFileName>|'"$mainFileName"'|' $file
    rm $file.bak
}

getTemplateFile() {
    file=$1
    curl -LJO https://raw.githubusercontent.com/anchal-physics/startWriting/main/templateFiles/$file
}

gitPushTemplateFile() {
    file=$1
    git add $file
    git commit -m 'Adding template file'"$file"
    git push
}

strrep() {
    text=$1
    pattern=$2
    newstr=$3
    echo ${text/$pattern/$newstr}
}

echo 'Welcome to startWriting.'
echo 'We will get you to writing your paper/thesis/presentation in minutes'
echo 'Press ctrl+c anytime to exit the software.'
echo

if ! command -v gh &> /dev/null
then
  echo 'I did not finnd gh installed on your computer.'
  read -p 'I will attempt installing gh (github CLI), is that ok (y/n)?'
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      if ! command -v brew &> /dev/null
      then
          echo
          echo 'I did not find brew installed on your computer.'
          read -p 'I will attempt installing brew, is that ok (y/n)?'
          if [[ $REPLY =~ ^[Yy]$ ]]
          then
              echo 'Installing brew'
              /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi
      fi

      echo
      echo 'Installing gh...'
      echo 'Ensuring you have reading and writing permissions for required directories'
      sudo chown -R $(whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
      chmod u+w /usr/local/share/zsh /usr/local/share/zsh/site-functions
      brew install gh
  fi
fi

echo
echo 'Logging into Github'
gh auth login

echo
echo 'Choose a name for your writing project.'
read -p 'This will be the name of your repo: '
repoName=$REPLY

echo
read -p 'Describe a category of your project (eg. thesis, paper, talk etc).'
category=$REPLY
echo
echo 'Git repo will be created and cloned to current directory'
read -p 'Do you wish to initiate the git repo in a different location (y/n)?'
if [[ $REPLY =~ ^[Yy]$ ]]
then
    read -p 'Enter full or relative path of new location:'
    cd $REPLY
fi

echo
read -p 'Do you want your repo to be public (y) or private (n)?'
if [[ $REPLY =~ ^[Yy]$ ]]
then
    privacy="--public"
fi
if [[ $REPLY =~ ^[Nn]$ ]]
then
    privacy="--private"
fi

echo
echo 'Now creating your repo remotely on Github and cloning a local copy.'
repoURL="$(gh repo create $repoName $privacy)"

cloneURL=$(strrep $repoURL https:// git@)
cloneURL="$(strrep $cloneURL / :)".git

git clone $cloneURL

cd $repoName

branchName=$(git branch)
branchName=${branchName:2:50}
baseURL="$repoURL"/blob/"$branchName"

echo
read -p 'Please enter a filename for your main tex file without extension (eg. main):'
mainFileName=$REPLY
outputFileName="$mainFileName".pdf

if [ $category = "thesis" ];
then
    getTemplateFile thesis.tgz
    tar -xf thesis.tgz
    rm thesis.tgz
    cp -r ./thesis/* ./
    rm -r thesis
    mv thesis.tex "$mainFileName".tex
    prepTemplateFile Makefile
    git add .
    git commit -m "Adding template files for thesis writing"
    git push
fi

getTemplateFile README.md
prepTemplateFile README.md
gitPushTemplateFile README.md
