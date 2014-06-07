#
#  2014, Chaofan Li <chaof@tamu.edu>
#
require 'mkmf'
root_dir = "/home/me/DFG_ILP"
ext_dir = root_dir + "/ext"
ilp_dir = ext_dir + "/ilp"

lib_dir = root_dir + "/lib"
relative_lib_dir = ".."
include_dir = ext_dir + "/include"
lpsolve = 'lpsolve'
cplex = 'cplex'
gurobi = 'gurobi'
have_lpsolve = false
have_cplex = false
have_gurobi = false
Dir.entries(lib_dir).each{|file|
	if(File.exist?(lib_dir + "/" + file) and file[3, 7] == 'lpsolve')
		lpsolve = file.split('.')[0][3..-1]
	elsif(File.exist?(lib_dir + "/" + file) and file[3, 5] == 'cplex')
		cplex = file.split('.')[0][3..-1]
	elsif(File.exist?(lib_dir + "/" + file) and file[3, 5] == 'gurobi')
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

	RPATHFLAG << " -Wl,-rpath,"+relative_lib_dir
	create_header
	create_makefile("dfg_ilp/ilp_ext")
else
	raise "no LP solver found, you must have at least one solver"
end
