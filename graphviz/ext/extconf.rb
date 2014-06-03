#  2014 by Chaofan Li <chaof@tamu.edu>
require 'mkmf'
if have_library("fl" ) 
	create_header
	create_makefile('Parser')
end
