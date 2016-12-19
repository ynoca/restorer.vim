## restorer.vim
A vim plugin which can back up and restore following information in session.

- empty windows
- buffers
- folds
- global variables
- the help window
- (local) options
- size of the window
- tab pages

## installation
####[neobundle.vim](https://github.com/Shougo/neobundle.vim)

    NeoBundle 'ynoca/restorer.vim'

####[dein.vim](https://github.com/Shougo/dein.vim)

    [[plugins]]
    repo = 'ynoca/restorer.vim'

## commands
- `RestorerSave [tag]`  
Backing up current session. If you set tag argument, the backup will be named tag, otherwise it will be named no_tag.

- `RestorerLoad [tag]`  
Restoring backed up session. If you set tag argument, the backup named tag will be restored. When there are some backup named tag or you don't set tag argument, the list of backup is displayed and you can choose.

- `RestorerRemove [tag]`  
Remove backup. If you set tag argument, the backup named tag will be removed. When there are some backup named tag or you don't set tag argument, the list of backup is displayed and you can choose.

## variables
- `g:restorer#dir`  
Directory to save backup. Default value is "$HOME/.cache/restorer"

- `g:restorer#tag`  
Backup name used when tag argument isn't set. Default value is "no_tag"

## screen shot
TODO

