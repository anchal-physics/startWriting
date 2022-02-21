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
    git commit -m 'Adding template file '"$file"
    git push
}

getPrepPush() {
    file=$1
    getTemplateFile $file
    prepTemplateFile $file
    gitPushTemplateFile $file
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
baseURL="$repoURL"/blob/master

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

if ! command -v "latexmk -h" &> /dev/null
then
    echo 'I did not find latexmk installed on your computer.'
    read -p 'I will attempt installing latexmk, is that ok (y/n)?'
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        if ! command -v tlmgr &> /dev/null
        then
            echo
            echo 'I did not find TeX Live Utility installed on your computer.'
            echo 'You need a latex distribution installed. Full distribution '
            echo 'is called MacTex which is about 5 Gb and a smaller one is '
            echo 'is called BasicTex but it lacks in many packages.'
            echo 'You can also choose to exit setup now and use your own Tex '
            echo 'compiler. However, you will be missing out on automatic '
            echo 'compilation hook for your git repo this way.'
            read -p 'What should I install, MacTex(a), BasicTex(b) or nothing(n)?'
            if [[ $REPLY =~ ^[Aa]$ ]]
            then
                curl -LJO "https://mirror.ctan.org/systems/mac/mactex/MacTeX.pkg"
                mv MacTeX.pkg /Users/$(whoami)/Desktop/
                echo "Go to Desktop and double-click on MacTeX.pkg and follow all the instructions."
                read -p "Press enter when you have installed MacTex."
                # sudo installer -pkg MacTeX.pkg -target /Applications/Tex
                echo "Removing installation file..."
                rm /Users/$(whoami)/Desktop/MacTeX.pkg
            elif [[ $REPLY =~ ^[Bb]$ ]]
            then
                curl -LJO "https://mirror.ctan.org/systems/mac/mactex/BasicTeX.pkg"
                mv BasicTeX.pkg /Users/$(whoami)/Desktop/
                echo "Go to Desktop and double-click on BasicTeX.pkg and follow all the instructions."
                read -p "Press enter when you have installed BasicTeX."
                # sudo installer -pkg MacTeX.pkg -target /Applications/Tex
                echo "Removing installation file..."
                rm /Users/$(whoami)/Desktop/BasicTeX.pkg
                echo 'Installing latexmk...'
                sudo tlmgr install latexmk
            fi
        else
            echo
            echo 'Installing latexmk...'
            sudo tlmgr install latexmk
        fi
    fi
fi

if ! command -v "latexmk -h" &> /dev/null
then
    getPrepPush pre-commit
    getTemplateFile setPreCommitAutoCompileHook.sh
    chmod +x setPreCommitAutoCompileHook.sh
    ./setPreCommitAutoCompileHook.sh
    gitPushTemplateFile setPreCommitAutoCompileHook.sh
fi

getPrepPush README.md
# if [ $privacy = "--public" ]
# then
#     echo 'For public repo, you can use server side continous integration for '
#     echo 'free. I can setup a travis-ci file for you so that you can do this '
#     echo 'as well. Would you like me to do so?(y/n)'
# fi

# curl -LJO "https://github.com/macports/macports-base/releases/download/v2.7.1/MacPorts-2.7.1.tar.gz"
# cd MacPorts-2.7.1
# ./configure && make && sudo make install
# cd ../
# rm -rf MacPorts-2.7.1*
