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
  echo 'I did not find gh installed on your computer.'
  read -p 'I will attempt installing gh (github CLI), is that ok ?(y/n) '
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      if ! command -v brew &> /dev/null
      then
          echo
          echo 'I did not find brew installed on your computer.'
          read -p 'I will attempt installing brew, is that ok ?(y/n) '
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
read -p 'Do you wish to initiate the git repo in a different location ?(y/n) '
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

if ! ls /usr/local/texlive/20* 1> /dev/null 2>&1;
then
    echo 'I did not find MacTeX installed on your computer.'
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
fi

# if ls /Library/TeX/texbin/latexmk 1> /dev/null 2>&1;
# then
getPrepPush pre-commit
getTemplateFile setPreCommitAutoCompileHook.sh
chmod +x setPreCommitAutoCompileHook.sh
read -p "Press enter to continue"
./setPreCommitAutoCompileHook.sh
gitPushTemplateFile setPreCommitAutoCompileHook.sh
# fi

getPrepPush README.md

echo
echo "You are already ready to start writing. I do recommend installing "
echo "tmux as well and my function which would let you just type "
echo "ltmkpvc file.tex"
echo "And a tmux session continuosly compiling your tex file would start in "
echo "the background and if you are ok with installing a open source pdfviewer"
echo "called skim, you can continuosly monitor your updated pdf as well."
echo "In the end, it will give you option of using your faviourite editor to "
echo "to write tex in (like atom, visualcode, emacs) and see changes in real "
echo "time."
echo

if command -v "tmux -V" &> /dev/null;
then
    echo "I did not find tmux installed"
    read -p 'I will attempt installing tmux (terminal multiplexer), is that ok ?(y/n) '
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      if ! command -v brew &> /dev/null
      then
          echo
          echo 'I did not find brew installed on your computer.'
          read -p 'I will attempt installing brew, is that ok ?(y/n) '
          if [[ $REPLY =~ ^[Yy]$ ]]
          then
              echo 'Installing brew'
              /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi
      fi

      echo
      echo 'Installing tmux...'
      brew install tmux
    fi
fi

echo
if ! ls /Applications/Skim.app 1> /dev/null 2>&1;
then
    echo "I did not find Skim installed"
    read -p 'I will attempt installing Skim (continrous pdf viewer), is that ok ?(y/n) '
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        curl -LJO "https://sourceforge.net/projects/skim-app/files/Skim/Skim-1.6.9/Skim-1.6.9.dmg/download"
        sudo hdiutil attach Skim-1.6.9.dmg
        sudo cp -rf /Volumes/Skim/Skim.app /Applications
        sudo hdiutil detach /Volumes/Skim
        rm -rf Skim-1.6.9.dmg
    fi
fi

echo "With your permission now, I'll add a useful function tmuxmux to your "
echo "~/.bash_profile"
echo "This will allow you to open any command in tmux detached session, as "
echo "many number of times. The main use is where a software requires you to "
echo "keep the terminal open for it to run, like latexmk, jupyter notebook etc"
echo "I'll also add a function called ltmkpvc"
echo "In future, you'll be able to start compiling continuously by using "
echo "ltmkpvc "$mainFileName".tex"
read -p 'Do I have permission to setup the bash functions?(y/n) '
if [[ $REPLY =~ ^[Yy]$ ]]
then
  source ~/.bash_profile
  if ! command -v tmuxmux &> /dev/null
  then
      getTemplateFile tmuxmux.sh
      sudo cat tmuxmux.sh>>~/.bash_profile
      rm tmuxmux.sh
      source ~/.bash_profile
  else
      echo "Found tmuxmux already, skipping."
  fi
  if ! command -v ltmkpvc &> /dev/null
  then
      getTemplateFile ltmkpvc.sh
      sudo cat ltmkpvc.sh>>~/.bash_profile
      rm ltmkpvc.sh
      source ~/.bash_profile
  else
      echo "Found ltmkpvc already, skipping."
  fi
fi

if [ $privacy = "--public" ]
then
    echo 'For public repo, you can use server side continous integration for '
    echo 'free. I can setup a travis-ci file for you so that you can do this '
    read -p 'as well. Would you like me to do so?(y/n) '
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        getPrepPush .travis.yml
    fi
fi

echo "You are ready to start writing! Read your README.md for more details."
