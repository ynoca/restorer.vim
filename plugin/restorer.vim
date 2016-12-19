"=============================================================================
" File: restorer.vim
" Author: Akira Yoneoka
" Created: 2016-12-20
"=============================================================================

scriptencoding utf-8

if exists('g:loaded_restorer')
    finish
endif
let g:loaded_restorer = 1

let s:save_cpo = &cpo
set cpo&vim

let g:restorer#dir = get(g:, 'restorer#dir', expand("$HOME/.cache/restorer"))
let g:restorer#tag = get(g:, 'restorer#tag', "no_tag")

command! -nargs=? RestorerSave call restorer#save(<f-args>)
command! -nargs=? RestorerLoad call restorer#load(<f-args>)
command! -nargs=? RestorerRemove call restorer#remove(<f-args>)
command! -nargs=? RestorerSaveLatest call restorer#save_latest(<f-args>)
command! -nargs=? RestorerLoadLatest call restorer#load_latest(<f-args>)
command! -nargs=? RestorerRemoveAll call restorer#remove_all(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

