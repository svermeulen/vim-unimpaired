" unimpaired.vim - Pairs of handy bracket mappings
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.2
" GetLatestVimScripts: 1590 1 :AutoInstall: unimpaired.vim

if exists("g:loaded_unimpaired") || &cp || v:version < 700
  finish
endif
let g:loaded_unimpaired = 1

" Next and previous {{{1

function! s:MapNextFamily(map,cmd)
  let map = '<Plug>unimpaired'.toupper(a:map)
  let end = ' ".(v:count ? v:count : "")<CR>'
  execute 'nnoremap <silent> '.map.'Previous :<C-U>exe "'.a:cmd.'previous'.end
  execute 'nnoremap <silent> '.map.'Next     :<C-U>exe "'.a:cmd.'next'.end
  execute 'nnoremap <silent> '.map.'First    :<C-U>exe "'.a:cmd.'first'.end
  execute 'nnoremap <silent> '.map.'Last     :<C-U>exe "'.a:cmd.'last'.end
  execute 'nmap <silent> ['.        a:map .' '.map.'Previous'
  execute 'nmap <silent> ]'.        a:map .' '.map.'Next'
  execute 'nmap <silent> ['.toupper(a:map).' '.map.'First'
  execute 'nmap <silent> ]'.toupper(a:map).' '.map.'Last'
  if exists(':'.a:cmd.'nfile')
    execute 'nnoremap <silent> '.map.'PFile :<C-U>exe "'.a:cmd.'pfile'.end
    execute 'nnoremap <silent> '.map.'NFile :<C-U>exe "'.a:cmd.'nfile'.end
    execute 'nmap <silent> [<C-'.a:map.'> '.map.'PFile'
    execute 'nmap <silent> ]<C-'.a:map.'> '.map.'NFile'
  endif
endfunction

call s:MapNextFamily('a','')
call s:MapNextFamily('u','b')
call s:MapNextFamily('l','l')
"call s:MapNextFamily('d','t')

function! s:entries(path)
  let path = substitute(a:path,'[\\/]$','','')
  let files = split(glob(path."/.*"),"\n")
  let files += split(glob(path."/*"),"\n")
  call map(files,'substitute(v:val,"[\\/]$","","")')
  call filter(files,'v:val !~# "[\\\\/]\\.\\.\\=$"')

  " filter out &suffixes
  let filter_suffixes = substitute(escape(&suffixes, '~.*$^'), ',', '$\\|', 'g') .'$'
  call filter(files, 'v:val !~# filter_suffixes')

  return files
endfunction

function! s:FileByOffset(num)
    let file = expand('%:p')
    let num = a:num

    while num || isdirectory(file)
        let files = s:entries(fnamemodify(file,':h'))
        if len(files) == 1
            break
        endif
        if a:num < 0
            call reverse(sort(filter(files,'v:val < file')))
        else
            call sort(filter(files,'v:val > file'))
        endif
        let temp = get(files,0,'')

        if temp == ''
            " We are at the start/end of directory, jump to start/end
            let files = s:entries(fnamemodify(file,':h'))
            if a:num < 0
                call reverse(sort(files))
                let temp = get(files,0,'')
            else
                call sort(files)
                let temp = get(files,0,'')
            endif

            if temp == ''
                break
            endif
        endif

        let file = temp
        if num != 0
            let num += num > 0 ? -1 : 1
        endif
    endwhile
    return file
endfunction

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

nnoremap <silent> <Plug>unimpairedDirectoryNext     :<C-U>edit <C-R>=<SID>fnameescape(<SID>FileByOffset(v:count1))<CR><CR>
nnoremap <silent> <Plug>unimpairedDirectoryPrevious :<C-U>edit <C-R>=<SID>fnameescape(<SID>FileByOffset(-v:count1))<CR><CR>
nmap ]f <Plug>unimpairedDirectoryNext
nmap [f <Plug>unimpairedDirectoryPrevious

nmap <silent> <Plug>unimpairedONext     <Plug>unimpairedDirectoryNext:echohl WarningMSG<Bar>echo "]o is deprecated. Use ]f"<Bar>echohl NONE<CR>
nmap <silent> <Plug>unimpairedOPrevious <Plug>unimpairedDirectoryPrevious:echohl WarningMSG<Bar>echo "[o is deprecated. Use [f"<Bar>echohl NONE<CR>
nmap ]o <Plug>unimpairedONext
nmap [o <Plug>unimpairedOPrevious

" }}}1
" Line operations {{{1

function! s:BlankUp(count) abort
  put!=repeat(nr2char(10), a:count)
  ']+1
  silent! call repeat#set("\<Plug>unimpairedBlankUp", a:count)
endfunction

function! s:BlankDown(count) abort
  put =repeat(nr2char(10), a:count)
  '[-1
  silent! call repeat#set("\<Plug>unimpairedBlankDown", a:count)
endfunction

nnoremap <silent> <Plug>unimpairedBlankUp   :<C-U>call <SID>BlankUp(v:count1)<CR>
nnoremap <silent> <Plug>unimpairedBlankDown :<C-U>call <SID>BlankDown(v:count1)<CR>

nmap [<Space> <Plug>unimpairedBlankUp
nmap ]<Space> <Plug>unimpairedBlankDown

function! s:Move(cmd, count, map) abort
  normal! mz
  exe 'move'.a:cmd.a:count
  keepjumps normal! `z
  normal! ==
  silent! call repeat#set("\<Plug>unimpairedMove".a:map, a:count)
endfunction

function! s:MoveVisualMode(count)
    let oldYank = easyclip#GetCurrentYank()
    normal! gvygv"_d
    normal! k
    exec "normal \<plug>EasyClipPasteBefore"
    normal! `]m>
    normal! `[m<
    call easyclip#SetCurrentYank(oldYank)

    let fullPlugName = "\<plug>VisualModeUnimpairedMoveUp"
    silent! call repeat#set(fullPlugName, a:count)
endfunction

nnoremap <silent> <Plug>unimpairedMoveUp   :<C-U>call <SID>Move('--',v:count1,'Up')<CR>
nnoremap <silent> <Plug>unimpairedMoveDown :<C-U>call <SID>Move('+',v:count1,'Down')<CR>

nnoremap <silent> <Plug>VisualModeUnimpairedMoveUp   :call <SID>MoveVisualMode(v:count1)<CR>

xmap <silent> <Plug>unimpairedMoveUp <esc><Plug>VisualModeUnimpairedMoveUp

"xnoremap <silent> <Plug>unimpairedMoveDown :<C-U>call <SID>MoveVisualMode()<CR>

"xnoremap <silent> <Plug>unimpairedMoveUp   :<C-U>exe 'exe "normal! mz"<Bar>''<,''>move--'.v:count1<CR>`z
"xnoremap <silent> <Plug>unimpairedMoveDown :<C-U>exe 'exe "normal! mz"<Bar>''<,''>move''>+'.v:count1<CR>`z

nmap [e <Plug>unimpairedMoveUp
nmap ]e <Plug>unimpairedMoveDown
xmap [e <Plug>unimpairedMoveUp
xmap ]e <Plug>unimpairedMoveDown

" }}}1
" Option toggling {{{1

function! s:toggle(op)
  return eval('&'.a:op) ? 'no'.a:op : a:op
endfunction

function! s:option_map(letter, option)
  exe 'nnoremap [o'.a:letter.' :set '.a:option.'<CR>'
  exe 'nnoremap ]o'.a:letter.' :set no'.a:option.'<CR>'
  exe 'nnoremap co'.a:letter.' :set <C-R>=<SID>toggle("'.a:option.'")<CR><CR>'
endfunction

call s:option_map('c', 'cursorline')
call s:option_map('u', 'cursorcolumn')
nnoremap [od :diffthis<CR>
nnoremap ]od :diffoff<CR>
nnoremap cod :<C-R>=&diff ? 'diffoff' : 'diffthis'<CR><CR>
call s:option_map('h', 'hlsearch')
call s:option_map('i', 'ignorecase')
call s:option_map('l', 'list')
nnoremap [on :set <C-R>=(exists('+rnu') && &rnu ? 'norelativenumber ' : '')<CR>number<CR>
nnoremap ]on :set <C-R>=(exists('+rnu') && &rnu ? 'norelativenumber ' : '')<CR>nonumber<CR>
nnoremap con :set <C-R>=(exists('+rnu') && &rnu ? 'norelativenumber ' : '').<SID>toggle('number')<CR><CR>
call s:option_map('r', 'relativenumber')
"call s:option_map('s', 'spell')
call s:option_map('w', 'wrap')
nnoremap [ox :set cursorline cursorcolumn<CR>
nnoremap ]ox :set nocursorline nocursorcolumn<CR>
nnoremap cox :set <C-R>=&cursorline && &cursorcolumn ? 'nocursorline nocursorcolumn' : 'cursorline cursorcolumn'<CR><CR>

" }}}1

" vim:set sw=2 sts=2:
