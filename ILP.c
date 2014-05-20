#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "lp_lib.h"
#include "ruby.h"

#include "graph.h"

#include <string.h>

VALUE cGraph ;
VALUE graph_obj ;

void get_graph(VALUE vlist, VALUE elist) {
	Graph *G ;
	int i, elist_len = RARRAY_LEN(elist), vlist_len = RARRAY_LEN(vlist);
	Vertex *vertex_list[vlist_len] ;
	char vertices[vlist_len] ;
	Check_Type(vlist, T_ARRAY) ;
	Check_Type(elist, T_ARRAY) ;	
	memset(vertex_list, 0, sizeof vertex_list);
	for(i = 0; i < vlist; i++){
		int t ;
		VALUE op = rb_ary_entry(vlist, i) ;
		char *opreation ;
		Check_Type(op, T_STRING) ;
		RSTRING_GETMEM(op, opreation, t) ;
		vertices[i] = opreation[0] ;
	}
	for(i = 0; i < elist_len; i++){
		VALUE edge = rb_ary_entry(elist, i) ;
		int e1, e2 ;
		Check_Type(edge, T_ARRAY) ;
		e1 = FIX2INT(rb_ary_entry(edge, 1) ) ;
		e2 = FIX2INT(rb_ary_entry(edge, 0) );
		if(vertex_list[e1] == NULL){
			vertex_list[e1] = new_vertex(e1 + 1) ;
			vertex_list[e1]->op = vertices[e1] ;
		}
		if(vertex_list[e2] == NULL){
			vertex_list[e2] = new_vertex(e2 + 1) ;
			vertex_list[e2]->op = vertices[e2] ;
		};
		add_adjacency_vertex(vertex_list[e1], e2 + 1, vertices[e2]) ;
	}
	G = new_graph(vlist_len, vertex_list);
	graph_obj = Data_Wrap_Struct(cGraph, 0, free_graph, G) ;
}
static VALUE ASAP(VALUE self, VALUE vlist, VALUE elist){
	Graph *G ;
	Data_Get_Struct(graph_obj, Graph, G) ;
	if(G == NULL){
		get_graph(vlist, elist) ;
		Data_Get_Struct(graph_obj, Graph, G) ;
	}

}

//#define DISPLAY

/*
 * min(max_bar)      c x
 *               A x op  b
 */
static VALUE ILP(VALUE self, VALUE A, VALUE op, VALUE b, VALUE c, VALUE min){
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
	printf("number of constraints: %d\n", Nrow);
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
	printf("number of variables: %d\n", Ncolumn);
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
	cGraph = rb_define_class("Graph", rb_cObject) ;
	graph_obj = Data_Wrap_Struct(cGraph, NULL, free_graph, NULL) ;
	rb_define_module_function( rb_const_get(rb_cObject, rb_intern("DFG_ILP")),"ILP", ILP, 5);
	rb_define_method(rb_const_get(rb_cObject, rb_intern("GRAPH")),"ASAP", ASAP, 5);
}

