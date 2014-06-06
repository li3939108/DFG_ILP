/*******************************************
   2014 by Chaofan Li <chaof@tamu.edu>
********************************************/

#include <string.h>

#include "ruby/version.h"
#include "as_possible.h"

extern VALUE cGraph ;
extern VALUE graph_obj ;
extern VALUE reverse_graph_obj ;

void get_graph(VALUE vlist, VALUE elist) {
	Graph *G, *Gt ;
	int i, elist_len = (int)RARRAY_LEN(elist), vlist_len = (int)RARRAY_LEN(vlist);
	Vertex *vertex_list[vlist_len] ;
	char vertices[vlist_len] ;
	Check_Type(vlist, T_ARRAY) ;
	Check_Type(elist, T_ARRAY) ;	
	memset(vertex_list, 0, sizeof vertex_list);
	for(i = 0; i < vlist_len; i++){
		#if RUBY_API_VERSION_MINOR == 8
		char operation[2] = {'\0','\0'} ;
		#endif
		VALUE op = rb_ary_entry(vlist, i) ;
		#if RUBY_API_VERSION_MINOR == 9 || RUBY_API_VERSION_MAJOR >= 2
		long t ;
		char *operation ;
		#endif
		Check_Type(op, T_STRING) ;
		#if RUBY_API_VERSION_MINOR == 8
		strncpy(operation, RSTRING_PTR(op), 1) ;
		#endif
		#if RUBY_API_VERSION_MINOR == 9 || RUBY_API_VERSION_MAJOR >= 2
		RSTRING_GETMEM(op, operation, t) ;
		#endif
		vertices[i] = operation[0] ;
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
	Gt = reverse(G) ;
	graph_obj = Data_Wrap_Struct(cGraph, 0, free_graph, G) ;
	reverse_graph_obj = Data_Wrap_Struct(cGraph, 0, free_graph, Gt) ;
}

int dfs(Graph *G, int s_label, int time[], VALUE delay){//no cycles
	int i ;
	char op[2] ;
	VALUE d_arr, d ;
	if(time[s_label] != -1){
		return time[s_label] ;
	}
	for(i = 0; i < G->adj_list[s_label]->degree; i++){
 		int *adj = (int *)G->adj_list[ s_label ]->list[ i ] ;
 		int time_step = dfs(G, adj[0], time, delay) ;
 		time[s_label] = time[s_label] < time_step ? time_step : time[s_label] ;
	}
	op[0] = G->adj_list[s_label]->op ;
	op[1] = '\0' ;
	d_arr = rb_hash_aref(delay, rb_str_new2(op) ) ;
	d = rb_funcall(d_arr, rb_intern("min"), 0) ;
/*
	if(asap_or_alap == 'S' || asap_or_alap == 's'){
*/
	time[s_label] = time[s_label] + FIX2INT( d );
/*
	}else if(asap_or_alap == 'L' || asap_or_alap == 'l'){
		
		time[s_label] = time[s_label] + FIX2INT( rb_funcall(d_arr, rb_intern("max"), 0) );
	}
*/
	return time[s_label] ;
}


int asap(Graph *Gt, int *time, VALUE delay){
	int i, max = 0 ;
	char op[2] ;
	VALUE d_arr ;
	for(i = 1; i <= Gt->V; i++){
		op[0] = Gt->adj_list[i]->op ;op[1] = '\0' ;
		d_arr = rb_hash_aref(delay, rb_str_new2(op) ) ;
		dfs(Gt, i, time, delay) ;
		time[i] = time[i] + 1 - FIX2INT( rb_ary_entry(d_arr, 0) ) ;
		max = max < time[i] ? time[i] : max ;
	}
	return max ;
}

int alap(Graph *G, int *time, VALUE delay, int Q){
	int i, max = 0 ;
	for(i = 1; i <= G->V; i++){
		dfs(G, i, time, delay) ;
	//	Q = new_Q > Q ? new_Q : Q ;
	}
	for(i = 1; i <= G->V; i++){
		time[i] = Q - 1 - time[i] ;
		max = max < time[i] ? time[i] : max ;
	}
	return max ;
}
void mobility(Graph *G, int *m, VALUE delay, int Q){
	Graph *Gt = NULL;
	int *time_s = NULL, *time_l = NULL, i;
	time_s = calloc(G->V + 1, sizeof *time_s);
	time_l = calloc(G->V + 1, sizeof *time_l);
	memset(time_s, 0xFF, (G->V + 1) * sizeof *time_s) ; //set all entry -1
	memset(time_l, 0xFF, (G->V + 1) * sizeof *time_l) ; //set all entry -1
	Data_Get_Struct(reverse_graph_obj, Graph, Gt) ;
	if(Gt == NULL){
		Gt = reverse(G);
	}
	asap (Gt, time_s, delay) ;
	alap (G, time_l, delay, Q) ;

	for(i = 1; i <= G->V; i++){
		m[i] = time_l[i] - time_s[i] ;
		printf("m[i]: %d, time_l[i]: %d, s: %d\n", m[i], time_l[i], time_s[i]) ;
	}
	free(time_s) ;
	free(time_l) ;
}