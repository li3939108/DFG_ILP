#  2014 by Chaofan Li <chaof@tamu.edu>
require 'mkmf'
root_dir = Dir.pwd 
lpsolve = 'lpsolve'
cplex = 'cplex'
gurobi = 'gurobi'
have_lpsolve = false
have_cplex = false
have_gurobi = false
Dir.entries("#{root_dir}/lib").each{|file|
	if(File.exist?("#{root_dir}/lib/" + file) and file[3, 7] == 'lpsolve')
		lpsolve = file.split('.')[0][3..-1]
	elsif(File.exist?("#{root_dir}/lib/" + file) and file[3, 5] == 'cplex')
		cplex = file.split('.')[0][3..-1]
	elsif(File.exist?("#{root_dir}/lib/" + file) and file[3, 5] == 'gurobi')
		gurobi = file.split('.')[0][3..-1]
	end
}
dir_config(lpsolve, './include', './lib') 
dir_config(cplex, './include', './lib') 
have_cplex =  have_library(lpsolve, 'strcpy') and have_header('lpsolve/lp_lib.h') 
have_lpsolve = have_library(cplex, 'CPXcopylp') and have_header('ilcplex/cplex.h') 
have_gurobi = have_library(gurobi, 'GRBnewmodel') and have_header('gurobi/gurobi_c.h') 
if	(have_lpsolve or have_cplex or have_gurobi) and
	have_library('pthread', 'pthread_create') and have_header('pthread.h') 

	RPATHFLAG << " -Wl,-rpath,#{root_dir}/lib"
	create_header
	create_makefile('ILP')
else
	raise "no LP solver found, you must have at least one solver"
end
