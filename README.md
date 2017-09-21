# cmakeproj.vim
	
	* function! CMakeProject(root_proj_dir,cmake_opts,make_opts)
	* function! CMakeConfigure()
	* function! CMakeCompile()
	* function! CMakeClean()
	* function! CMakeProjectTargetExecutable(target)
	* function! CMakeProjectRun(args)
	* function! CMakeProjectMakeChanges()
	* function! CMakeProjectLoad(projpath)

### How-to
 * First time using cmakeproj
  
  You should call *CMakeProject()* first, this will setup the necessary variable to other functions,
  then you are able to use: *CMakeConfigure()*, *CMakeCompile()* and *CMakeClean()*.

  If you want to run your project, use *CMakeProjectTargetExecutable()* and specify your executable
  path, then you are able to use: *CMakeProjectRun()*
  
  (*read also below*)

 * if *cmakeproj.txt* is availible on filesystem
 
  cmakeproj will look for cmakeproj.txt and load it, if not found, then user should proceed as
  written above
  
  (*read also below*)

### cmakeproj.txt (and related functions)
cmakeproj uses a simple text file to keep info about:
 * Build directory
 * CMake flags
 * Make flags
 * (optional) executable path to use with *CMakeProjectRun()* function

To create this file, after you call'd *CMakeProject()* (at least) and *CMakeProjectTargetExecutable()*,
call *CMakeProjectMakeChanges()*, this will write (create or overwrite) a file called "cmakeproj.txt"

Next time you'll launch vim and load the plugin where the "cmakeproj.txt" file is placed, properties are automatically loaded, so you won't need to call *CMakeProject()* and *CMakeProjectTargetExecutable()* once again.

If not in the same directory, just call *CMakeProjectLoad()* and specify where the file is.

**Note that, if you make changes and you want to overwrite a specific cmakeproj.txt file, this won't happen.
Calling *CMakeProjectMakeChanges()* will create another cmakeproj.txt file in the current working directory, with current properties. (this is because cmakeproj won't track current loaded project file)**
