require 'mkmf'

#have_library()

#ruby extconf.rb --with-DFG_ILP-dir=dir
#set the lib and include directory associated with DFG_ILP to dir/lib dir/include
#ruby extconf.rb
#will set the lib and include directory associated with DFG_ILP to ./lib and ./include
dir_config('DFG_ILP', '.')

#create it
create_makefile('DFG_ILP')
