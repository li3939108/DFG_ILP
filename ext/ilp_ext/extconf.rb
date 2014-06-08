#
#  2014, Chaofan Li <chaof@tamu.edu>
#
require 'mkmf'
require 'fileutils'
require 'readline'
root_dir = File.expand_path( File.dirname(__FILE__) + "/../..")

ext_dir = root_dir + "/ext"
ilp_dir = ext_dir + "/ilp"
lib_dir = root_dir + "/lib"
include_dir = ext_dir + "/include"
lpsolve = 'lpsolve'
cplex = 'cplex'
gurobi = 'gurobi'
have_lpsolve = false
have_cplex = false
have_gurobi = false

Readline.completion_append_character = ""
Readline.completion_proc = Proc.new do |str|
  Dir[str+'*'].grep( /^#{Regexp.escape(str)}/ ) 
end
line = Readline.readline(
"The path to the CPLEX library file\n\
usrally named libcplex###.so:", true)
if( line.strip.include?("cplex") )
	FileUtils.ln_s( File.absolute_path( line.strip ), lib_dir )
end
line = Readline.readline(
"The path to the Gurobi library file\n\
usrally named libgurobi##.so:", true)
if( line.strip.include?("gurobi") )
	FileUtils.ln_s( File.absolute_path( line.strip ), lib_dir )
end
line = Readline.readline(
"The path to the Gurobi library file\n\
usrally named liblp_solve##.so:", true)
if( line.strip.include?("lpsolve") )
	FileUtils.ln_s( File.absolute_path( line.strip ), lib_dir )
end
Dir.entries(lib_dir).each{|file|
	if(File.exist?(lib_dir + "/" + file) and file[3, 7] == 'lpsolve')
		lpsolve = file.split('.')[0][3..-1]
	elsif(File.exist?(lib_dir + "/" + file) and file[3, 5] == 'cplex')
		cplex = file.split('.')[0][3..-1]
	elsif(File.exist?(lib_dir + "/" + file) and file[3, 6] == 'gurobi')
		gurobi = file.split('.')[0][3..-1]
	end
}
dir_config(lpsolve, include_dir, lib_dir) 
dir_config(cplex, include_dir, lib_dir) 
have_cplex =  have_library(lpsolve, 'strcpy') and have_header('lpsolve/lp_lib.h') 
have_lpsolve = have_library(cplex, 'CPXcopylp') and have_header('ilcplex/cplex.h') 
have_gurobi = have_library(gurobi, 'GRBnewmodel') and have_header('gurobi/gurobi_c.h') 
if	(have_lpsolve or have_cplex or have_gurobi) and
	have_library('pthread', 'pthread_create') and have_header('pthread.h') 

	RPATHFLAG << " -Wl,-rpath,"+lib_dir
	create_header
	create_makefile("dfg_ilp/ilp_ext")
else
	raise "no LP solver found, you must have at least one solver"
end
