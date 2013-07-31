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
    let b:bufnr_list = filter(range(1, bufnr('$')), 'buflisted(v:val)')


    " open selected buffer
    nmap <silent> <buffer> <CR>          :call <SID>loadSelectedBuffer()<CR>
    nmap <silent> <buffer> o             :call <SID>loadSelectedBuffer()<CR>
    nmap <silent> <buffer> <2-LeftMouse> :call <SID>loadSelectedBuffer()<CR>

    " close BufferSwitcher buffer
    nmap <silent> <buffer> q             :call <SID>closeWin()<CR>
    nmap <silent> <buffer> <ESC>         :call <SID>closeWin()<CR>
    nmap <silent> <buffer> <Tab>         :call <SID>closeWin()<CR>

    call s:updateBufferList()
    call s:selectCurrentBuffer()
endfunction

function s:selectCurrentBuffer()
    exe index(b:bufnr_list, b:bufnr) + 1
endfunction

function s:closeWin()
    if bufexists(b:bufnr)
        exe b:bufnr . 'buffer'
    else
        exe 'enew'
    endif
endfunction

function s:loadSelectedBuffer()
    if len(b:bufnr_list) > 0
        let b:bufnr = b:bufnr_list[line('.') - 1]
    endif

    call s:closeWin()
endfunction

function s:listedBuffers()
    let result = []
    for bufnr in b:bufnr_list
        let value = {}
        let value.bufnr = bufnr
        let value.buf_name = bufname(bufnr)
        let value.opened = bufwinnr(bufnr) == -1 ? ' ' : '*'
        let value.modified = getbufvar(bufnr, '&modified') ? '+' : ' '
        let value.file_name = empty(value.buf_name) ? g:noname_label : strpart(value.buf_name, strridx(value.buf_name, s:pathsp) + 1)

        call add(result, value)
    endfor

    return result
endfunction

function s:updateBufferList()
    setlocal modifiable
    exe "%delete _"

    let max_length = &ts
    for bufobj in s:listedBuffers()
        let disp_name = bufobj.opened . bufobj.modified . bufobj.file_name . "\t"
        let display_length = strlen(disp_name)
        let max_length = display_length > max_length ? display_length : max_length

        silent put = disp_name . s:strrpad('#'.bufobj.bufnr, 5) . bufobj.buf_name

    endfor

    exe 'setlocal ts=' . (max_length + 4)

    " go to the first line and delete this empty line without destroy 'unnamed' register
    0 | delete _
    setlocal nomodifiable
endfunction

command BufSwitcherOpen :call s:openWin()

nnoremap <silent> <Tab> :BufSwitcherOpen<CR>

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo
