#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <ilcplex/cplex.h>
#include <lp_lib.h>
#include <string.h>
#include "ruby.h"

#include "as_possible.h"

#define round(x) ((x)>=0?(long)((x)+0.5):(long)((x)-0.5))

#ifndef HEADER_lp_lib
#define LE 1
#define GE 2
#define EQ 3
#endif

#define DEBUG


VALUE cGraph ;
VALUE graph_obj ;
VALUE reverse_graph_obj ;

static VALUE ASAP(VALUE self, VALUE delay){
	Graph *G, *Gt ;
	VALUE vlist = rb_ivar_get(self, rb_intern("@vertex") );
	VALUE elist = rb_ivar_get(self, rb_intern("@edge") );
	//VALUE delay = rb_ivar_get(self, rb_intern("@d") ) ;
	VALUE ret = rb_ary_new();
	int *time, i;

	Data_Get_Struct(graph_obj, Graph, G) ;
	Data_Get_Struct(reverse_graph_obj, Graph, Gt) ;
	if(G == NULL || Gt == NULL){
		get_graph(vlist, elist) ;
		Data_Get_Struct(graph_obj, Graph, G) ;
		Data_Get_Struct(reverse_graph_obj, Graph, Gt) ;
	}
	time = calloc(G->V + 1, sizeof *time);
	memset(time, 0xFF, (G->V + 1) * sizeof *time) ; //set all entry -1
	asap(Gt, time, delay ) ;
	for(i = 1; i <= G->V; i++){
		//rb_hash_aset(sch, ID2SYM(rb_intern("id")), INT2FIX( i ) );
		//rb_hash_aset(sch, ID2SYM(rb_intern("op") ), rb_str_new2(op ) ) ;
		//rb_hash_aset(sch, ID2SYM(rb_intern("time") ), INT2FIX(time[i] ) ) ;
		//rb_hash_aset(sch, ID2SYM(rb_intern("type") ), INT2FIX( (int)0 ) );
		//rb_hash_aset(sch, ID2SYM(rb_intern("delay") ), INT2FIX(  FIX2INT( rb_ary_entry(d_arr, 0 ) ) ) );
		#ifdef DEBUG
		char op[2] ;
		VALUE d_arr ;
		op[0] = G->adj_list[i]->op ;op[1] = '\0' ;
		d_arr = rb_hash_aref(delay, rb_str_new2(op) ) ;
		printf("(%d %c\ttype:%d delay:%d)->  \t %d)\n", i, G->adj_list[i]->op, 0, FIX2INT( rb_ary_entry(d_arr, 0) ), time[i] ) ;
		#endif
		rb_ary_push(ret, INT2FIX(time[i] ) ) ;
	}
	#ifdef DEBUG
	printf("------------\n") ;
	#endif

	free(time) ;
	return ret ;
}

static VALUE ALAP(VALUE self, VALUE delay){
	Graph *G, *Gt ;
	VALUE vlist = rb_ivar_get(self, rb_intern("@vertex") );
	VALUE elist = rb_ivar_get(self, rb_intern("@edge") );
	//VALUE delay = rb_ivar_get(self, rb_intern("@d") ) ;
	int *time, i ;
	VALUE ret = rb_ary_new();

	Data_Get_Struct(graph_obj, Graph, G) ;
	Data_Get_Struct(reverse_graph_obj, Graph, Gt) ;
	if(G == NULL || Gt == NULL){
		get_graph(vlist, elist) ;
		Data_Get_Struct(graph_obj, Graph, G) ;
		Data_Get_Struct(reverse_graph_obj, Graph, Gt) ;
	}
	time = calloc(G->V + 1, sizeof *time);
	memset(time, 0xFF, (G->V + 1) * sizeof *time) ; //set all entry -1
	alap(G, time, delay) ;

	for(i = 1; i <= G->V; i++){
		//rb_hash_aset(sch, ID2SYM(rb_intern("id")), INT2FIX( i ) );
		//rb_hash_aset(sch, ID2SYM(rb_intern("op") ), rb_str_new2(op ) ) ;
		//rb_hash_aset(sch, ID2SYM(rb_intern("time") ), INT2FIX(time[i] ) ) ;
		//rb_hash_aset(sch, ID2SYM(rb_intern("type") ), INT2FIX( (int)( RARRAY_LEN(d_arr) - 1 ) ) );
		//rb_hash_aset(sch, ID2SYM(rb_intern("delay") ), INT2FIX(  FIX2INT( rb_ary_entry(d_arr, RARRAY_LEN(d_arr) - 1  ) ) ) );
		#ifdef DEBUG
		VALUE d_arr;
		char op[2] ;
		op[0] = G->adj_list[i]->op ;op[1] = '\0' ;
		d_arr = rb_hash_aref(delay, rb_str_new2(op) ) ;
		VALUE d = rb_funcall(d_arr, rb_intern("max"), 0) ;
		printf("(%d %c\ttype:%d delay:%d)->  \t %d)\n", i, G->adj_list[i]->op, FIX2INT( rb_funcall(d_arr, rb_intern("index"), 1, d) )  , FIX2INT( d ), time[i] ) ;
		#endif
		rb_ary_push(ret, INT2FIX(time[i]  ) ) ;
	}
	#ifdef DEBUG
	printf("------------\n") ;
	#endif
	
	free(time) ;
	return ret ;
}

static VALUE M(VALUE self, VALUE delay){
	Graph *G, *Gt ;
	VALUE vlist = rb_ivar_get(self, rb_intern("@vertex") );
	VALUE elist = rb_ivar_get(self, rb_intern("@edge") );
	//VALUE delay = rb_ivar_get(self, rb_intern("@d") ) ;
	int *m, i ;
	VALUE ret = rb_ary_new() ;
	Data_Get_Struct(graph_obj, Graph, G) ;
	Data_Get_Struct(reverse_graph_obj, Graph, Gt) ;
	if(G == NULL || Gt == NULL){
		get_graph(vlist, elist) ;
		Data_Get_Struct(graph_obj, Graph, G) ;
		Data_Get_Struct(reverse_graph_obj, Graph, Gt) ;
	}
	m = calloc(G->V + 1, sizeof *m);
	memset(m, 0xFF, (G->V + 1) * sizeof *m) ; //set all entry -1
	mobility(G, m, delay) ;
	for(i = 1; i <= G->V; i++){
		rb_ary_push(ret, INT2FIX(m[i] ) ) ;
		#ifdef DEBUG
		printf("%dm%d  ", i, m[i] );
		#endif
	}
	free(m) ;
	return ret ;
}


static void free_and_null (char **ptr){
	if ( *ptr != NULL ) {
		free (*ptr);
		*ptr = NULL;
	}
}
static VALUE cplex(VALUE self, VALUE A, VALUE op, VALUE b, VALUE c, VALUE min){
	Check_Type(A, T_ARRAY) ;
	Check_Type(op, T_ARRAY) ;
	Check_Type(b, T_ARRAY) ;
	Check_Type(c, T_ARRAY) ;
	int Nrow = RARRAY_LEN(A); 
	int Ncolumn = RARRAY_LEN(c);
	int i ;
	
	VALUE ret_hash = rb_hash_new();
	VALUE constraints = rb_ary_new2(Nrow);
	VALUE variables = rb_ary_new2(Ncolumn);

	bool error_set = false ;
	VALUE error_type = rb_eFatal ;
	char *error_msg = NULL ;
	

	char *zprobname = "scheduling" ;
	int objsen      = 0;
	double *zobj    = (double *) malloc(Ncolumn * sizeof(double));
	double *zrhs    = (double *)malloc(Nrow * sizeof *zrhs);
	char *zsense    = (char *)malloc(Nrow * sizeof *zsense) ;
	int *zmatbeg    = (int *)malloc(Ncolumn * sizeof *zmatbeg) ;
	int *zmatcnt    = (int *)malloc(Ncolumn * sizeof *zmatcnt) ;
	int *zmatind    = (int *)malloc(Nrow * Ncolumn * sizeof *zmatind) ;
	double *zmatval = (double *)malloc(Nrow * Ncolumn * sizeof *zmatval) ;
	double *zlb     = (double *) malloc(Ncolumn * sizeof *zlb);
	double *zub     = (double *) malloc(Ncolumn * sizeof *zub);
	char *zctype    = (char *)malloc(Ncolumn * sizeof * zctype) ;
	int status      = 0 ;

	/* Declare and allocate space for the variables and arrays where we will
	   store the optimization results including the status, objective value,
	   variable values, and row slacks. */

	int      solstat;
	double   objval;
	double *x       = (double *)malloc(Ncolumn * sizeof *x);
	double *slack   = (double *)malloc(Nrow * sizeof *slack) ;
	int cur_numrows, cur_numcols ;

	CPXENVptr     env = NULL;
	CPXLPptr      lp = NULL;


	if(TYPE(min) == T_TRUE){
		objsen = CPX_MIN ;
	}else{if(TYPE(min) == T_FALSE){
		objsen = CPX_MAX ;
	}}
	
	if(RARRAY_LEN(op) != Nrow){
		error_set = true ;error_type = rb_eFatal; error_msg ="arguments does not match: op != Nrow";
		goto TERMINATE ;
	}

	if(RARRAY_LEN(b) != Nrow){
		error_set = true ;error_type = rb_eFatal; error_msg ="arguments does not match: b != Nrow";
		goto TERMINATE ;
	}

	for(i = 0; i < Nrow; i++){
		VALUE row_v = rb_ary_entry(A, i);
		int j;
		int constraint_type ;
		Check_Type(row_v, T_ARRAY);
		if(RARRAY_LEN(row_v) != Ncolumn){
			error_set = true ;error_type = rb_eFatal; error_msg ="arguments does not match: row_v != Ncolumn";
			goto TERMINATE ;
		}
		for(j = 0; j < Ncolumn; j++){
			zmatind[j * Nrow + i] = i ;
			zmatval[j * Nrow + i] = NUM2DBL(rb_ary_entry(row_v, j));
			
		}
		constraint_type = FIX2INT(rb_ary_entry(op,i));
		switch(constraint_type){
			case LE : 
			zsense[i] = 'L' ;
			break;
			
			case EQ :
			zsense[i] = 'E' ;
			break ;
			
			case GE :
			zsense[i] = 'G' ;
			break ;
			
			default :
			error_set = true ;error_type = rb_eFatal; error_msg ="unknow contstraint type";
			goto TERMINATE ;
			break ;
		}
		zrhs[i] = NUM2DBL(rb_ary_entry(b, i));
	}
	for(i = 0; i < Ncolumn; i++){
		zmatbeg[i] = i * Nrow ;
		zmatcnt[i] = Nrow ;
		zlb[i] = 0.0 ;
		zub[i] = CPX_INFBOUND ;
		zctype[i] = 'I' ;
		zobj[i] = NUM2DBL(rb_ary_entry(c, i));
	}
	
	env = CPXopenCPLEX (&status);

	 /* If an error occurs, the status value indicates the reason for
	    failure.  A call to CPXgeterrorstring will produce the text of
	    the error message.  Note that CPXopenCPLEX produces no output,
	    so the only way to see the cause of the error is to use
	    CPXgeterrorstring.  For other CPLEX routines, the errors will
	    be seen if the CPXPARAM_ScreenOutput indicator is set to CPX_ON.  */

	if ( env == NULL ) {
		char  errmsg[CPXMESSAGEBUFSIZE];
		CPXgeterrorstring (env, status, errmsg);
		fprintf(stderr, "%s", errmsg) ;
		error_set = true ;error_type = rb_eFatal; error_msg ="Could not open CPLEX environment";
		goto TERMINATE ;
	 }

	/* Turn on output to the screen */
	#ifdef DEBUG
	status = CPXsetintparam (env, CPXPARAM_ScreenOutput, CPX_ON);
	#else
	status = CPXsetintparam (env, CPXPARAM_ScreenOutput, CPX_OFF);
	#endif
	if ( status ) {
		error_set = true ;error_type = rb_eFatal; error_msg ="Failure to turn on screen indicator, error";
		goto TERMINATE ;
	}

	/* Create the problem. */   
	lp = CPXcreateprob (env, &status, zprobname);

	/* A returned pointer of NULL may mean that not enough memory
           was available or there was some other problem.  In the case of
           failure, an error message will have been written to the error
           channel from inside CPLEX.  In this example, the setting of
           the parameter CPXPARAM_ScreenOutput causes the error message to
           appear on stdout.  */
	if ( lp == NULL ) {
		error_set = true ;error_type = rb_eFatal; error_msg ="Failed to create LP";
		goto TERMINATE ;
	}

	/* Now copy the problem data into the lp */
	status = CPXcopylp	(env, lp, Ncolumn, Nrow, objsen, zobj, zrhs, zsense, 
				zmatbeg, zmatcnt, zmatind, zmatval, zlb, zub, NULL) ;
	if(status){
		error_set = true ;error_type = rb_eFatal; error_msg = "Failed to copy problem data" ;
		goto TERMINATE ;
	}
	/* Now copy the ctype array */ 
	status = CPXcopyctype (env, lp, zctype);
	if ( status ) {
		error_set = true ;error_type = rb_eFatal; error_msg = "Failed to copy ctype" ;
		goto TERMINATE ;
	}
	/* Optimize the problem and obtain solution. */
	status = CPXmipopt (env, lp); 
	if ( status ) { 
		error_set = true ;error_type = rb_eFatal; error_msg = "Failed to optimize MIP" ;
		goto TERMINATE ;
	}
	solstat = CPXgetstat (env, lp);
	/* Write the output to the screen. */  
	#ifdef DEBUG
	printf ("\nSolution status = %d\n", solstat);
	#endif
	status = CPXgetobjval (env, lp, &objval);
	if ( status && solstat ) {  
		error_set = true ;error_type = rb_eFatal; error_msg = "No MIP objective value available.  Exiting..." ;
		goto TERMINATE ;
	}
	#ifdef DEBUG
	printf ("Solution value  = %f\n\n", objval);
	#endif
	rb_hash_aset(ret_hash, ID2SYM(rb_intern("o")), rb_float_new( objval) ); 
	/* The size of the problem should be obtained by asking CPLEX what
           the actual size is, rather than using what was passed to CPXcopylp.
           cur_numrows and cur_numcols store the current number of rows and
           columns, respectively.  */
	cur_numrows = CPXgetnumrows (env, lp);
	cur_numcols = CPXgetnumcols (env, lp);
	status = CPXgetx (env, lp, x, 0, cur_numcols-1);
	if ( status ) { 
		error_set = true ;error_type = rb_eFatal; error_msg = "Failed to get optimal integer x." ;
		goto TERMINATE ;
	}
	status = CPXgetslack (env, lp, slack, 0, cur_numrows-1); 
	if ( status ) {      
		error_set = true ;error_type = rb_eFatal; error_msg = "Failed to get optimal slack values" ;
		goto TERMINATE ;
	}
	for (i = 0; i < cur_numrows; i++) {
		rb_ary_store(constraints, i , INT2FIX( round(slack[i] ) ) );
		#ifdef DEBUG
		printf ("Row %d:  Slack = %f\n", i, slack[i]); 
		#endif
	}
	rb_hash_aset(ret_hash, ID2SYM(rb_intern("c")), constraints);
	for (i = 0; i < cur_numcols; i++){
		rb_ary_store(variables, i, INT2FIX( round(x[i])  ) ) ;
		#ifdef DEBUG
		printf ("Column %d:  Value = %f\n", i, x[i]); 
		#endif
	}
	rb_hash_aset(ret_hash, ID2SYM(rb_intern("v")), variables);
	/* Finally, write a copy of the problem to a file. */
	status = CPXwriteprob (env, lp, "cplex.lp", NULL);  
	if ( status ) {
		#ifdef DEBUG
		fprintf (stderr, "Failed to write LP to disk.\n");
		#endif
	}
	
	/* Free up the problem as allocated by CPXcreateprob, if necessary */
TERMINATE:
	if ( lp != NULL ) {
		status = CPXfreeprob (env, &lp);
		if ( status ) {
			fprintf (stderr, "CPXfreeprob failed, error code %d.\n", status);
		}
	}

	/* Free up the CPLEX environment, if necessary */

	if ( env != NULL ) {
		status = CPXcloseCPLEX (&env);

		/* Note that CPXcloseCPLEX produces no output,
		   so the only way to see the cause of the error is to use
		   CPXgeterrorstring.  For other CPLEX routines, the errors will
		   be seen if the CPXPARAM_ScreenOutput indicator is set to CPX_ON. */

		if ( status ) {
			char  errmsg[CPXMESSAGEBUFSIZE];
			CPXgeterrorstring (env, status, errmsg);
			fprintf(stderr, "%s", errmsg) ;
			error_set = true ;error_type = rb_eFatal; error_msg = "Could not close CPLEX environment" ;
		}
	}


	/* Free up the problem data arrays, if necessary. */

	free_and_null ((char **) &zobj);
	free_and_null ((char **) &zrhs);
	free_and_null ((char **) &zsense);
	free_and_null ((char **) &zmatbeg);
	free_and_null ((char **) &zmatcnt);
	free_and_null ((char **) &zmatind);
	free_and_null ((char **) &zmatval);
	free_and_null ((char **) &zlb);
	free_and_null ((char **) &zub);
	free_and_null ((char **) &zctype);
	
	free_and_null ((char **) &x) ;
	free_and_null ((char **) &slack) ;

	if(error_set == true){
		rb_raise(error_type, "%s", error_msg);
	}else{
		return ret_hash ;
	}
}

/*
 * min(max_bar)      c x
 *               A x op  b
 */
static VALUE lpsolve(VALUE self, VALUE A, VALUE op, VALUE b, VALUE c, VALUE min){
	Check_Type(A, T_ARRAY) ;
	Check_Type(op, T_ARRAY) ;
	Check_Type(b, T_ARRAY) ;
	Check_Type(c, T_ARRAY) ;
	int Nrow = RARRAY_LEN(A); 
	int Ncolumn = RARRAY_LEN(c);
	int i;
	int ret ;
	lprec *lp = NULL;
	REAL row[1 + Ncolumn] ;
	REAL result[1 + Nrow + Ncolumn];

	VALUE ret_hash = rb_hash_new();
	VALUE constraints = rb_ary_new2(Nrow);
	VALUE variables = rb_ary_new2(Ncolumn);

	lp = make_lp(0, Ncolumn);
	set_verbose(lp, SEVERE);

	if(TYPE(min) == T_TRUE){
		set_minim(lp);
	}else{if(TYPE(min) == T_FALSE){
		set_maxim(lp);
	}}
	
	if(RARRAY_LEN(op) != Nrow){
		rb_raise(rb_eArgError, "Length of op does not match that of A");
	}

	if(RARRAY_LEN(b) != Nrow){
		rb_raise(rb_eArgError, "Length of b does not match that of A");
	}

	set_add_rowmode(lp, true);
	#ifdef DEBUG
	printf("number of constraints: %d\n", Nrow);
	#endif
	for(i = 0; i < Nrow; i++){
		VALUE row_v = rb_ary_entry(A, i);
		int j;
		REAL b_dbl;
		int constraint_type ;
		Check_Type(row_v, T_ARRAY);
		if(RARRAY_LEN(row_v) != Ncolumn){
			rb_raise(rb_eArgError, "Length of row %d :%ld doen not match that of c:%d, i.e., the objective", i + 1, RARRAY_LEN(row_v) ,Ncolumn);
		}
		for(j = 0; j < Ncolumn; j++){
			row[j + 1] = NUM2DBL(rb_ary_entry(row_v, j));
		}
		constraint_type = FIX2INT(rb_ary_entry(op,i));
		b_dbl = NUM2DBL(rb_ary_entry(b, i));
		add_constraint(lp, row, constraint_type, b_dbl); 
	}
	set_add_rowmode(lp, false);
	#ifdef  DEBUG
	printf("number of variables: %d\n", Ncolumn);
	#endif
	for(i = 0; i < Ncolumn; i++){
		row[i + 1] = NUM2DBL(rb_ary_entry(c, i));
		set_int(lp, i + 1, true);
	}
	
	set_obj_fn(lp, row);
	printf("start solve\n");
	ret = solve(lp);
	printf("solve return value: %d \n", ret);
	switch(ret){
		case 2: rb_raise(rb_eFatal, "no solution");
		break ;

		default:
		break;
	}
	get_primal_solution(lp, result);
	#ifdef DEBUG

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
	for(i = 1; i < 1 + get_Nrows(lp) + get_Ncolumns(lp); i++){
		if(i >= 1 && i <= get_Nrows(lp)){
			rb_ary_store(constraints, i - 1, INT2NUM((int)result[i]));
		}else{if(i >= 1 + get_Nrows(lp) && i <= get_Nrows(lp) + get_Ncolumns(lp)){
			rb_ary_store(variables, i - 1 - get_Nrows(lp), INT2NUM((int)result[i]));
		}}
	}

	rb_hash_aset(ret_hash, ID2SYM(rb_intern("o")), rb_float_new(result[0]));
	rb_hash_aset(ret_hash, ID2SYM(rb_intern("c")), constraints);
	rb_hash_aset(ret_hash, ID2SYM(rb_intern("v")), variables);
	
	delete_lp(lp);
	return ret_hash;

}
void Init_ILP(){
	VALUE DFG_ILP_mod = rb_const_get(rb_cObject, rb_intern("DFG_ILP")) ;
	cGraph = rb_define_class_under(DFG_ILP_mod, "Graph", rb_cObject) ;
	graph_obj = Data_Wrap_Struct(cGraph, NULL, free_graph, NULL) ;
	reverse_graph_obj = Data_Wrap_Struct(cGraph, NULL, free_graph, NULL) ;
	rb_define_module_function(DFG_ILP_mod, "lpsolve", lpsolve, 5);
	rb_define_module_function(DFG_ILP_mod, "cplex", cplex, 5);
	rb_define_method(rb_const_get(DFG_ILP_mod, rb_intern("GRAPH")),"ASAP", ASAP, 1);
	rb_define_method(rb_const_get(DFG_ILP_mod, rb_intern("GRAPH")),"ALAP", ALAP, 1);
	rb_define_method(rb_const_get(DFG_ILP_mod, rb_intern("GRAPH")),"M", M, 1);
	rb_global_variable(&graph_obj) ;
	rb_global_variable(&reverse_graph_obj) ;
}
