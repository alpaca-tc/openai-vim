let s:denops_initialized = v:false

function! s:initialize()
  if !s:denops_initialized
    call denops#request('openai', 'initialize', [s:api_key()])
    let s:denops_initialized = v:true
  endif

  return s:denops_initialized
endfunction

function! s:api_key()
  if !empty(g:openai_api_key)
    return g:openai_api_key
  elseif exists('$OPENAI_API_KEY')
    return $OPENAI_API_KEY
  elseif filereadable(expand("~/.config/openai"))
    return readfile(expand("~/.config/openai"))[0]
  endif

  return openai#error("g:openai_api_key is blank")
endfunction

function! s:denops_running()
  return 'g:loaded_denops'->exists()
        \ && denops#server#status() ==# 'running'
        \ && denops#plugin#is_loaded('openai')
endfunction

function! openai#notify(method, args)
  if s:denops_running()
    call s:initialize()
    call denops#notify('openai', a:method, a:args)
  endif
endfunction

function! openai#request(method, args)
  if s:denops_running()
    call s:initialize()
    call denops#request('openai', a:method, a:args)
  endif
endfunction

function! openai#error(message) abort
  echohl Error
  echomsg printf('[openai] %s', a:message)
  echohl None
endfunction
