let s:save_cpo = &cpo
set cpo&vim

if exists('g:bufswitcher_loaded')
  finish
endif

let g:bufswitcher_loaded = 1
let g:noname_label = 'No Name'

if has('win32') || has('win64')
  let s:pathsp = '\'
else
  let s:pathsp = '/'
endif

function s:strrpad(str, n)
    return a:str . repeat(' ', a:n - len(a:str))
endfunction

function s:openWin()
    let prevbufnr = bufnr('%')
    exe 'silent! e ' . 'BUFSWITCHER'
    set filetype=bufswitcher

    if bufnr('%') == prevbufnr
        silent! bdelete
        return
    end

    let b:bufnr = prevbufnr

    " open selected buffer
    nmap <silent> <buffer> <CR>          :call <SID>loadSelectedBuffer()<CR>
    nmap <silent> <buffer> o             :call <SID>loadSelectedBuffer()<CR>
    nmap <silent> <buffer> <2-LeftMouse> :call <SID>loadSelectedBuffer()<CR>

    " close BufferSwitcher buffer
    nmap <silent> <buffer> q             :call <SID>closeWin()<CR>
    nmap <silent> <buffer> <ESC>         :call <SID>closeWin()<CR>
    nmap <silent> <buffer> <Tab>         :call <SID>closeWin()<CR>

    call s:updateBufferList()
endfunction

function s:closeWin()
    if bufexists(b:bufnr)
        exe b:bufnr . 'buffer'
    else
        exe 'enew'
    endif
endfunction

function s:loadSelectedBuffer()
  if len(b:bufnumberlist) > 0
      let b:bufnr = b:bufnumberlist[line('.') - 1]
  endif

  call s:closeWin()
endfunction

function s:updateBufferList()
  setlocal modifiable
  exe "%delete _"

  let b:bufnumberlist = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let max_length = &ts

  for i in b:bufnumberlist
    let buf_name = bufname(i)
    let opened = bufwinnr(i) == -1 ? ' ' : '*'
    let modified = getbufvar(i, '&modified') ? '+' : ' '
    let file_name = empty(buf_name) ? g:noname_label : strpart(buf_name, strridx(buf_name, s:pathsp) + 1)
    let disp_name = opened . modified . file_name . "\t"
    let display_length = strlen(disp_name)
    let max_length = display_length > max_length ? display_length : max_length

    silent put = disp_name . s:strrpad('#'.i, 5) .buf_name
  endfor
  " update tabstop to better alignment
  exe 'setlocal ts=' . (max_length + 4)

  " go to the first line and delete this empty line without destroy 'unnamed' register
  0 | delete _
  setlocal nomodifiable

  exe index(b:bufnumberlist, b:bufnr) + 1
endfunction

command BufSwitcherOpen :call s:openWin()

nnoremap <silent> <Tab> :BufSwitcherOpen<CR>

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo
