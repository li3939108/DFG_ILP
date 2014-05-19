#include "ruby.h"

static VALUE ASAP(VALUE self, VALUE vlist, VALUE elist){
	int i, elist_len = RARRAY_LEN(elist);
	check_type(vlist, T_ARRAY) ;
	check_type(elist, T_ARRAY) ;	
	for(i = 0; i < elist_len; i++){
		VALUE edge = rb_ary_entry(elist, i) ;
		int e1, e2 ;
		check_type(edge, T_ARRAY) ;
		e1 = rb_ary_entry(edge, 1) ;
		e2 = rb_ary_entry(edge, 0) ;
		
	}
	
}
void Init_ASAP(){
	rb_define_module_function( rb_const_get(rb_cObject, rb_intern("DFG_ILP")),"ASAP", ASAP, 5);
}
