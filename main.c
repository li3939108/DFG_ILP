#include <stdio.h>
#include <stdlib.h>
#include "lp_lib.h"

#define DISPLAY

int main()
{
	lprec *lp;
	int column = 2;
	REAL row[1+column] ;

	lp = make_lp(0,column);
	set_verbose(lp,SEVERE);
	set_maxim(lp);

	if(lp == NULL) {
		perror("Unable to create new LP model\n");
		exit(EXIT_FAILURE);
	}

	set_add_rowmode(lp, true);

	row[1] = -1.0; row[2] = 1.0;
	add_constraint(lp, row, LE, 1.0); 
	row[1] =  3.0; row[2] = 2.0;
	add_constraint(lp, row, LE, 12.0); 
	row[1] =  2.0; row[2] = 3.0;
	add_constraint(lp, row, LE, 12.0); 

	set_add_rowmode(lp, false);
	
	set_int(lp, 1, true);	
	set_int(lp, 2, true);	

	row[1] = 0.0; row[2] = 1.0;
	set_obj_fn(lp, row);

	solve(lp);

	REAL result[1+get_Nrows(lp)+get_Ncolumns(lp)];
	int i;
	
	get_primal_solution(lp, result);

#ifdef DISPLAY
	for(i = 0; i < 1+get_Nrows(lp)+get_Ncolumns(lp); i++){
		if(i == 0){
			printf("obj: ");
		}else{if(i >= 1 && i <= get_Nrows(lp)){
			printf("constraints %d: ", i);
		}else{if(i >= 1 + get_Nrows(lp) && i <= get_Nrows(lp) + get_Ncolumns(lp)){
			printf("variable %d: ", i - get_Nrows(lp));
		}}}
		printf("%f\n", result[i]);
	}
#endif
	delete_lp(lp);
	return 0;
}
