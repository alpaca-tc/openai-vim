function! openai#commands#explain(...) range
  let filePath = expand("%:p")
  let range = s:parse_range(a:000)

  if range.is_range
    let content = s:get_content(range.startline, range.endline)
  else
    let content = s:get_content(0, '$')
  endif

  let remoteUrl = openai#util#remote_url()

  call openai#notify('explain', [remoteUrl, filePath, content])
endfunction

function! s:get_content(start, end)
  return join(getline(a:start, a:end), "\n")
endfunction

function! s:parse_range(args)
  return {
        \ 'count' : a:args[0],
        \ 'startline' : a:args[1],
        \ 'endline' : a:args[2],
        \ 'is_range' : (a:args[0] != -1)
        \ }
endfunction
