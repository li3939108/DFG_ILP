DFG_ILP: main.c
	gcc -I./lp_solve_5.5.2.0_dev_osx64/ -L./lp_solve_5.5.2.0_dev_osx64/ -l lpsolve55 main.c -o DFG_ILP
