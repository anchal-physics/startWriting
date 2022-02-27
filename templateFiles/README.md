# <repoName>

This is your repo for accomplishing your writing goal. Edit this description
to better motivate the purpose of this document. You should leave this following link though.

[!Latest_Compiled_<category>](<baseURL>/<outputFileName>)

## startWriting manual

Following are some useful things for you to remember:
* Every commit from this repo made on your local computer would first trigger a latex compilation to update your main pdf file.
* If the compillation fails, you would not be able to commit.
* If in future, you clone this repo elsewhere, run the following commands after cloning:
```
cp pre-commit ./.git/hooks/pre-commit
chmod +x ./.git/hooks/pre-commit
```
### If you used the full skim, tmux, ltmkpvc support:

* To use skim in continuous update state, on opening skim for the first time, go to Skim>Preferences on top left of your screen. Slect Sync tab on left top side and click on the checkboxes labelled "Check for file changes" and "Reload automatically".
* To work on your writing, come to this directory and run:
```
ltmkpvc <mainFileName>.tex
```
* You can checkout the tmux session name by:
```
tmux ls
```
* To kill the session when you are done:
```
tmux kill-session -t <session_name>
```
* To check log of latex comilation, it is best to see the file contents of <mainFileName>.log . But you can also see what's happening in the tmux session by going inside it:
```
tmux a -t <session_name>
```
* To get out of tmux session press Ctrl-b and then d.
