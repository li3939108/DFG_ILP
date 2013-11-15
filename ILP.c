#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "lp_lib.h"
#include "ruby.h"

//#define DISPLAY

static VALUE ILP(VALUE self, VALUE A, VALUE op, VALUE b, VALUE c, VALUE min){
	Check_Type(A, T_ARRAY) ;
	Check_Type(op, T_ARRAY) ;
	Check_Type(b, T_ARRAY) ;
	Check_Type(c, T_ARRAY) ;
	int Nrow = RARRAY_LEN(A); 
	int Ncolumn = RARRAY_LEN(c);
	int i;
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

	for(i = 0; i < Nrow; i++){
		VALUE row_v = rb_ary_entry(A, i);
		int j;
		REAL b_dbl;
		int constraint_type ;
		Check_Type(row_v, T_ARRAY);
		if(RARRAY_LEN(row_v) != Ncolumn){
			rb_raise(rb_eArgError, "Length of row %d doen not match that of c, i.e., the objective", i + 1);
		}
		for(j = 0; j < Ncolumn; j++){
			row[j + 1] = NUM2DBL(rb_ary_entry(row_v, j));
		}
		constraint_type = FIX2INT(rb_ary_entry(op,i));
		b_dbl = NUM2DBL(rb_ary_entry(b, i));
		add_constraint(lp, row, constraint_type, b_dbl); 
	}
	set_add_rowmode(lp, false);
	
	for(i = 0; i < Ncolumn; i++){
		row[i + 1] = NUM2DBL(rb_ary_entry(c, i));
		set_int(lp, i + 1, true);
	}
	
	set_obj_fn(lp, row);

	solve(lp);

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
	for(i = 1; i < 1 + get_Nrows(lp) + get_Ncolumns(lp); i++){
		if(i >= 1 && i <= get_Nrows(lp)){
			rb_ary_store(constraints, i - 1, rb_float_new(result[i]));
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
	rb_define_module_function( rb_const_get(rb_cObject, rb_intern("DFG_ILP")),"ILP", ILP, 5);
}
