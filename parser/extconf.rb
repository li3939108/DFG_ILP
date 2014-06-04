#  2014 by Chaofan Li <chaof@tamu.edu>
require 'mkmf'

if have_library("fl" ) 
	create_makefile('Parser')
end
