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

function! s:walkerFirst()
  if &diff | execute 'normal! gg]c'
  elseif &ft == 'git'
    execute 'normal! gg'
    call s:diff('next')
  else | execute 'cfirst'
  endif
endfunction

function! s:walkerNext()
  if &diff | execute 'normal! ]c'
  elseif &ft == 'git' | call s:diff('next')
  else | execute 'cnext'
  endif
endfunction

function! s:walkerPrev()
  if &diff | execute 'normal! [c'
  elseif &ft == 'git' | call s:diff('prev')
  else | execute 'cprev'
  endif
endfunction

command! WalkerFirst call s:walkerFirst()
command! WalkerNext call s:walkerNext()
command! WalkerPrev call s:walkerPrev()