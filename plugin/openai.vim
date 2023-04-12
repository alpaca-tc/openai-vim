if exists('g:loaded_openai')
  finish
endif
let g:loaded_openai = 1

let s:save_cpo = &cpo
set cpo&vim

let g:openai_api_key = get(g:, "openai_api_key", "")

command! -range=% OpenaiExplain :call openai#commands#explain(<count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
