require 'mkmf'


#have_library('lpsolve55') find_library('lpsolve55', '_make_lp', './lib') and 
	#ruby extconf.rb --with-DFG_ILP-dir=dir
	#set the lib and include directory associated with DFG_ILP to dir/lib dir/include
	#ruby extconf.rb
	#will set the lib and include directory associated with DFG_ILP to ./lib and ./include
	#ruby extconf.rb --with-DFG_ILP-lib=lib will set the lib directory to lib
	#ruby extconf.rb --with-DFG_ILP-include=include will set the include directory to include
	dir_config('DFG_ILP', './include', '/Domain/continuum.tamu.edu/Users/li3939108/lib/')

	#create it
	create_makefile('DFG_ILP')
