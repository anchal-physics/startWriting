# startWriting
This repo would contain scripts that can be called from any computer using curl command to initiate a git repo, create a remote end at github, and initialize hooks in your local repo so that at every commit you compile your latex code and publish a latest copy.

To use, copy and paste this command in your terminal:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/anchal-physics/startWriting/main/startWriting.sh)"
```

You would be prompted to tell a location for your project but it would be
simplest to just cd to the desired location first and then run the above
command.
