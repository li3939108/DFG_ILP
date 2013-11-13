require 'mkmf'

#have_library()

#ruby extconf.rb --with-DFG_ILP-dir=.
#set the lib and include directory associated with DFG_ILP to ./lib ./include
dir_config('DFG_ILP')

#create it
create_makefile('DFG_ILP')
