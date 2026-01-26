-- avoid loading twice
if exists("current_compiler")
	finish
endif
let current_compiler = "shell"

if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=%
CompilerSet errorformat=%f:\ line\ %1:\ %m


