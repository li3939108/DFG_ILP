require 'mkmf'


#ruby extconf.rb --with-DFG_ILP-dir=dir
#set the lib and include directory associated with DFG_ILP to dir/lib dir/include
#ruby extconf.rb
#will set the lib and include directory associated with DFG_ILP to ./lib and ./include
#ruby extconf.rb --with-DFG_ILP-lib=lib will set the lib directory to lib
#ruby extconf.rb --with-DFG_ILP-include=include will set the include directory to include
lpsolve_lib = './lib'
dir_config('lpsolve55', './include', lpsolve_lib)

#create it
#if find_header('lp_lib.h', './include') and find_library('lpsolve55', 'strcpy')  #For Debian 7 and packeged library
if have_header('lp_lib.h') and have_library('lpsolve55', 'strcpy') #For Ubuntu 13.04 and locally compiled library 
#	RPATHFLAG << " -Wl,-rpath,#{lpsolve_lib} "
	create_makefile('ILP')
end
