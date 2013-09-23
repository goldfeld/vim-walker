"" =============================================================================
"" File:          plugin/walker.vim
"" Description:   Walks through diffs and quicklists with a single interface.
"" Author:        Vic Goldfeld <vic@longstorm.org>
"" Version:       0.1
"" ReleaseDate:   2013-09-11
"" License:       MIT License (see below)
""
"" Copyright (C) 2013 Vic Goldfeld under the MIT License.
""
"" Permission is hereby granted, free of charge, to any person obtaining a 
"" copy of this software and associated documentation files (the "Software"), 
"" to deal in the Software without restriction, including without limitation 
"" the rights to use, copy, modify, merge, publish, distribute, sublicense, 
"" and/or sell copies of the Software, and to permit persons to whom the 
"" Software is furnished to do so, subject to the following conditions:
""
"" The above copyright notice and this permission notice shall be included in 
"" all copies or substantial portions of the Software.
""
"" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
"" OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
"" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
"" THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
"" OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
"" ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
"" OTHER DEALINGS IN THE SOFTWARE.
"" =============================================================================

if exists('g:loaded_walker') || &cp
	finish
endif
let g:loaded_walker = 1

function! s:diffCmpNext(curr, last, equals)
  return a:curr < a:last + a:equals
endfunction

function! s:diffCmpPrev(curr, last, equals)
  return a:curr > a:last - a:equals
endfunction

function! s:diff(direction)
  let line = line('.')
  let first = getline(l:line)[0]
  let next = l:first
  if a:direction == 'next'
         let [lastline, step, Cmp] = [line('$'), 1 , function('s:diffCmpNext')]
  else | let [lastline, step, Cmp] = [0,        -1 , function('s:diffCmpPrev')]
  endif

  if l:first == '+' || l:first == '-'
    let other = l:first == '+'? '-' : '+'
    while l:next == l:first && Cmp(l:line, l:lastline, 0)
      let l:line += l:step
      let l:next = getline(l:line)[0]
    endwhile

    if l:next == l:other
      execute 'normal!' l:line . 'G'
      return
    endif
  endif

  while l:next != '-' && l:next != '+' && Cmp(l:line, l:lastline, 0)
    let l:line += l:step
    let l:next = getline(l:line)[0]
  endwhile

  if Cmp(l:line, l:lastline, 1)
    execute 'normal!' l:line . 'G'
  endif
endfunction

" TODO add command to go back to file before quicklist navigation (for coming
" back to original when Gdiff'ing, can be coupled with CloseQFBufs)

" TODO keep line location across quicklist entries when it's the same file
" name (so be ablo te navigate 'line history' through vim-fugitive's Gdiff)

" TODO keep line locations of each diff for when person leaves diff mode but
" is still on the diffed file (unless there is a quicklist, and also let go of
" these diff locations as soon as person leaves the diffed file buffer the
" first time)

" TODO walk conflicts (top priority) when there are markers
" [ConflictMotions - Motions to and inside SCM conflict markers. : vim online](http://www.vim.org/scripts/script.php?script_id=3991)
" see 'Context' functions https://github.com/tpope/vim-unimpaired/blob/master/plugin/unimpaired.vim

let [s:cfirst, s:cnext, s:cprev, s:clast] = ['', '', '', '']
function! s:setKeepAlt(keepalt)
  let keepalt = (a:keepalt? 'keepalt ' : '')
  let s:cfirst = l:keepalt . 'cfirst'
  let s:cnext = l:keepalt . 'cnext'
  let s:cprev = l:keepalt . 'cprev'
  let s:clast = l:keepalt . 'clast'

  let s:keepalt = l:keepalt
  return a:keepalt
endfunction
let s:keepalt = s:setKeepAlt(get(g:, 'walker_keepalt', 0))

function! s:walkerFirst()
  if &diff | execute 'normal! gg]c'
  elseif &ft == 'git' || &ft == 'diff'
    execute 'normal! gg'
    call s:diff('next')
  else | execute s:cfirst
  endif
endfunction

function! s:walkerNext()
  if &diff | execute 'normal! ]c'
  elseif &ft == 'git' || &ft == 'diff' | call s:diff('next')
  else | execute s:cnext
  endif
endfunction

function! s:walkerPrev()
  if &diff | execute 'normal! [c'
  elseif &ft == 'git' || &ft == 'diff' | call s:diff('prev')
  else | execute s:cprev
  endif
endfunction

command! WalkerFirst call s:walkerFirst()
command! WalkerNext call s:walkerNext()
command! WalkerPrev call s:walkerPrev()

command! WalkerKeepAlt call s:setKeepAlt(1)
command! WalkerKeepAltOff call s:setKeepAlt(1)
command! WalkerKeepAltToggle call s:setKeepAlt(!s:keepalt)
