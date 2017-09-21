" CMake project support for vim
" Copyleft <(C)

if exists("g:loaded_cmakeproj")
	finish
endif

let g:loaded_cmakeproj = 1
let s:keepcpo = &cpo
set cpo&vim

function! CMakeProject(root_proj_dir, cmake_opts, make_opts)
	if !isdirectory(a:root_proj_dir) 
		echom "Cannot find root project dir: ".a:root_proj_dir
		return 1
	endif 
	
	if !filereadable(a:root_proj_dir."/CMakeLists.txt")
		echom "Cannot find CMakeList.txt inside of: ".a:root_proj_dir
		return 1
	endif

	let g:cmakeproj_project_build_dir = fnamemodify(a:root_proj_dir."/build",":p")
	
	execute "read!mkdir -p" g:cmakeproj_project_build_dir
	if v:shell_error != 0
		echom "Cannot create directory, wtf!"
		unlet g:cmakeproj_project_build_dir
		return 1
	endif

	let g:cmakeproj_conf_options = a:cmake_opts
	let g:cmakeproj_make_options = a:make_opts

	echom "CMake project setup done!"
	return 0
endfunction

function! CMakeConfigure()
	if !exists("g:cmakeproj_project_build_dir")
		echom "You must call CMakeProject first"
		return 1
	endif

	if !exists("g:cmakeproj_conf_options")
		echom "cmakeproj_conf_option (global) unlet'd, setting to empty value"
		let g:cmakeproj_conf_option = ""
	endif

	let l:current_pwd = getcwd()
	execute "lcd" g:cmakeproj_project_build_dir
	execute "!cmake .." g:cmakeproj_conf_options

	execute "lcd" l:current_pwd
	return 0
endfunction

function! CMakeCompile()
	if !exists("g:cmakeproj_project_build_dir")
		echom "You must call CMakeProject first"
		return 1
	endif

	if !exists("g:cmakeproj_make_options")
		echom "cmakeproj_make_option (global) unlet'd, setting to empty value"
		let g:cmakeproj_make_option = ""
	endif
	
	let l:current_pwd = getcwd()
	execute "lcd" g:cmakeproj_project_build_dir

	if filereadable("Makefile")
		execute "!make" g:cmakeproj_make_options
	else
		echom "Cannot find any Makefile :("
	endif

	execute "lcd" l:current_pwd
	return 0
endfunction

function! CMakeClean()
	if !exists("g:cmakeproj_project_build_dir")
		echom "You must call CMakeProject first"
		return 1
	endif

	let l:current_pwd = getcwd()
	execute "lcd" g:cmakeproj_project_build_dir
	
	if filereadable("Makefile")
		execute "!make clean"
	else
		echom "Cannot find any Makefile :("
	endif

	execute "lcd" l:current_pwd
	return 0
endfunction

function! CMakeProjectTargetExecutable(target)
	if !filereadable(a:target)
		echom "Cannot find executable"
		return 1
	endif

	let g:cmakeproj_project_target = fnamemodify(a:target,":p")
	echom "Added target executable"
	return 0
endfunction

function! CMakeProjectRun(args)
	if !exists("g:cmakeproj_project_target")
		echom "CMake project target not set"
		return 1
	endif

	if a:args != ""
		execute "!".g:cmakeproj_project_target a:args
	else
		execute "!" g:cmakeproj_project_target
	endif

	return 0
endfunction

function! CMakeProjectMakeChanges()
	if !exists("g:cmakeproj_project_build_dir") || !exists("g:cmakeproj_conf_options") || !exists("g:cmakeproj_make_options")
		echom "Unable to make change: missing properties"
		return 1
	endif

	redir!> cmakeproj.txt
	echo g:cmakeproj_project_build_dir
	echo g:cmakeproj_conf_options
	echo g:cmakeproj_make_options
	if exists("g:cmakeproj_project_target")
		echo g:cmakeproj_project_target
	endif
	redir END

	return 0
endfunction

function! CMakeProjectLoad(projpath)
	if !filereadable(a:projpath)
		return 1
	endif

	let l:infile = readfile(a:projpath,'',5)

	if !isdirectory(l:infile[1])
		execute "read!mkdir -p" l:infile[1]
		if v:shell_error != 0
			echom "Cannot create directory, wtf!"
			return 1
		endif
	endif

	if !exists("l:infile[1]") || !exists("l:infile[2]") || !exists("l:infile[3]")
		return 1
	endif

	let g:cmakeproj_project_build_dir = l:infile[1]
	let g:cmakeproj_conf_options = l:infile[2]
	let g:cmakeproj_make_options = l:infile[3]

	if exists("l:infile[4]")
		call CMakeProjectTargetExecutable(l:infile[4])
	endif

	return 0
endfunction

"Load CWD's cmakeproj.txt
call CMakeProjectLoad("cmakeproj.txt")

let &cpo = s:keepcpo
unlet s:keepcpo
