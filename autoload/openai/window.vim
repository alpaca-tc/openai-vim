function! openai#window#dispatch(text) "{{{
  call s:execute_buffer_command('vnew', a:text)
endfunction"}}}

function! s:execute_buffer_command(command, text)
  silent! execute a:command
  silent! 0put =a:text

  " Delete tail line
  $delete
endfunction
