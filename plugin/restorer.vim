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



" Global variable

let g:restorer#dir = get(g:, 'restorer#dir', expand("$HOME/.cache/restorer"))
let g:restorer#tag = get(g:, 'restorer#tag', "no_tag")



" Utils

function! s:str2date(str) "{{{
  return a:str[0:3] . "/" . a:str[4:5] . "/". a:str[6:7] . " " . a:str[8:9] . ":" . a:str[10:11] . ":" . a:str[12:13]
endfunction "}}}

function! s:mkdir(dir) "{{{
  if !isdirectory(a:dir)
    try
      call mkdir(a:dir, 'p')
    catch
      " echoerr "Can not make a directory " . a:dir 
    endtry
  endif
endfunction "}}}

function! s:rmdir(dir) "{{{
  try
    execute "!rm -rf " . a:dir
  catch
    echoerr "This system can't execute rm command"
  endtry
endfunction "}}}

function! s:set_sessionoptions(...) "{{{
  setlocal sessionoptions=
  setlocal sessionoptions+=blank
  setlocal sessionoptions+=buffers
  setlocal sessionoptions+=curdir
  setlocal sessionoptions+=folds
  setlocal sessionoptions+=globals
  setlocal sessionoptions+=help
  setlocal sessionoptions+=localoptions
  setlocal sessionoptions+=options
  setlocal sessionoptions+=resize
  setlocal sessionoptions+=slash
  setlocal sessionoptions+=tabpages
  setlocal sessionoptions+=unix
  setlocal sessionoptions+=winpos
  setlocal sessionoptions+=winsize
endfunction "}}}



" Get snapshot 

function! s:get_snapshots(tag) "{{{
  let l:tag = a:tag == "" ? "" : "_" . a:tag
  let l:ret = []
  let l:dirs =  split(glob(g:restorer#dir . "/*" . l:tag), "\n")
  for l:dir in l:dirs
    call add(l:ret, fnamemodify(l:dir, ":t"))
  endfor
  return l:ret
endfunction "}}}

function! s:get_latest_snapshot(tag) "{{{
  return remove(s:get_snapshots(a:tag), -1) 
endfunction "}}}

function! s:select_snapshot(tag) "{{{
  let l:cnt = 1
  let l:tags = s:get_snapshots(a:tag)
  if len(l:tags) > 1
    let l:display = "list of restorable file \n"
    for l:tag in l:tags
      let l:splitpos = match(l:tag, "_")
      let l:date = s:str2date(l:tag[:l:splitpos+1])
      let l:tag = l:tag[l:splitpos+1:]
      let l:display = l:display . "    " . l:cnt . ": " . l:tag . " [" . l:date . "]\n"
      let l:cnt = l:cnt + 1
    endfor
    echo l:display
    let l:num = input("Enter the number: ")
    echo "\n"
    let l:num = str2nr(l:num, 10)
    if l:num >= 1 && l:num <= l:cnt
      return l:tags[l:num - 1]
    else
      echo "invalid argument"
      return ""
    endif
  elseif len(l:tags) == 1
    return l:tags[0]
  else
    echo a:tag . " not found."
    return ""
  endif
endfunction "}}}



" Save 

function! s:save_session(tag) "{{{
  call s:set_sessionoptions()
  let l:session = g:restorer#dir . "/" . a:tag . "/session.vim"
  try
    if !filewritable(l:session)
      execute "redir > " . l:session
    endif
    execute "mksession! " . l:session
  catch
    echoerr "Can't save session info to " . l:session
  endtry
endfunction "}}}

function! s:save_viminfo(tag) "{{{
  let l:viminfo = g:restorer#dir . "/" . a:tag . "/viminfo.vim"
  try
    if !filewritable(l:viminfo)
      execute "redir > " . l:viminfo
    endif
    execute "wviminfo!  " . l:viminfo
  catch
    echoerr "Can't save viminfo to " . l:viminfo
  endtry
endfunction "}}}

function! s:save(tag) "{{{
  let l:dir = g:restorer#dir . "/" . a:tag
  call s:mkdir(l:dir)
  call s:save_session(a:tag)
  call s:save_viminfo(a:tag)
endfunction "}}}



" Load 

function! s:load_session(dir) "{{{
  let l:session = a:dir . "/session.vim"
  try
    if filereadable(l:session)
      execute "source " . l:session
    endif
  catch
    echoerr "Can't load session info from " . l:session
  endtry
endfunction "}}}

function! s:load_viminfo(dir) "{{{
  let l:viminfo = a:dir . "/viminfo.vim"
  try
    if filereadable(l:viminfo)
      execute "rviminfo " . l:viminfo
    endif
  catch
    echoerr "Can't load viminfo from " . l:viminfo
  endtry
endfunction "}}}

function! s:load(tag) "{{{
  let l:dir = g:restorer#dir . "/" . a:tag
  if l:dir != ""
    call s:load_session(l:dir)
    call s:load_viminfo(l:dir)
  endif
endfunction "}}}



" Remove 

function! s:remove(tag) "{{{
  let l:dir = g:restorer#dir . "/" . a:tag
  if l:dir != ""
    call s:rmdir(l:dir)
  endif
endfunction "}}}

function! s:remove_all(tag) "{{{
  let l:tags = s:get_snapshots(l:tag)
  for l:tag in l:tags
    call s:remove(l:tag)
  endfor
endfunction "}}}


" Public function

function! restorer#save(...) "{{{
  let l:tag = strftime("%Y%m%d%H%M%S") . "_" . get(a:, 1, g:restorer#tag)
  call s:save(l:tag)
endfunction "}}}

function! restorer#save_latest(tag) "{{{
  call s:remove(s:get_latest_snapshot(a:tag))
  call restorer#save(a:tag)
endfunction "}}}

function! restorer#load(...) "{{{
  let l:tag = get(a:, 1, "")
  call s:load(s:select_snapshot(l:tag))
endfunction "}}}

function! restorer#load_latest(tag) "{{{
  let l:tag = get(a:, 1, "")
  call s:load(s:get_latest_snapshot(l:tag))
endfunction "}}}

function! restorer#remove(...) "{{{
  let l:tag = get(a:, 1, "")
  call s:remove(s:select_snapshot(l:tag))
endfunction "}}}

function! restorer#remove_all(tag) "{{{
  let l:tag = get(a:, 1, "")
  let l:tag = s:select_snapshot(l:tag)
  call s:remove_all(l:tag)
endfunction "}}}

function! restorer#list(...) "{{{
  let l:tag = get(a:, 1, "")
  return s:get_snapshots(l:tag)
endfunction "}}}



let &cpo = s:save_cpo
unlet s:save_cpo

