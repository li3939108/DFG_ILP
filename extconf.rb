require 'mkmf'


#ruby extconf.rb --with-DFG_ILP-dir=dir
#set the lib and include directory associated with DFG_ILP to dir/lib dir/include
#ruby extconf.rb
#will set the lib and include directory associated with DFG_ILP to ./lib and ./include
#ruby extconf.rb --with-DFG_ILP-lib=lib will set the lib directory to lib
#ruby extconf.rb --with-DFG_ILP-include=include will set the include directory to include
#dir_config('DFG_ILP', '.')


#create it
if find_header('lp_lib.h', './include') and find_library('lpsolve55', 'strcpy','./lib') 
	create_makefile('ILP')
end
