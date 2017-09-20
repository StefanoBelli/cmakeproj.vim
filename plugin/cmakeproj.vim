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

	let g:cmakeproj_project_build_dir = a:root_proj_dir."/build"
	
	execute "read!mkdir -p" g:cmakeproj_project_build_dir
	if v:shell_error != 0
		echom "Cannot create directory, wtf!"
		unlet g:cmakeproj_project_build_dir
		return 1
	endif

	let g:cmakeproj_conf_options = a:cmake_opts
	let g:cmakeproj_make_options = a:make_opts
	
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

let &cpo = s:keepcpo
unlet s:keepcpo
