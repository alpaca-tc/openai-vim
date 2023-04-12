function! openai#util#remote_url()
  let remoteUrl = trim(system("git config --get remote.origin.url"))
  let remoteUrl = substitute(remoteUrl, ".*:", "", "")
  let splittedRemoteUrl = split(remoteUrl, "/")

  if len(splittedRemoteUrl) > 1
    let owner = splittedRemoteUrl[-2]
    let repo = splittedRemoteUrl[-1]

    if !empty(owner) && !empty(repo)
      return "https://github.com/" . owner . "/" . substitute(repo, "\.git$", "", "")
    endif
  endif

  throw "Could not get remote url"
endfunction

function! openai#util#is_public_git(url)
  let response = webapi#http#get(a:url)
  return response.status == 200
endfunction
