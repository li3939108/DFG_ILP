#  2014 by Chaofan Li <chaof@tamu.edu>
require 'mkmf'

CONFIG["CC"] = "gcc"
CONFIG["warnflags"] = ""

if have_library("fl" ) 
	create_makefile('parser/parser')
end
