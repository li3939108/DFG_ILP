/*******************************************
   2014 by Chaofan Li <chaof@tamu.edu>
********************************************/

#include <string.h>
#include <stdlib.h>

#include "ruby/version.h"
#include "as_possible.h"

extern VALUE cGraph ;
extern VALUE graph_obj ;
extern VALUE reverse_graph_obj ;

void get_graph(VALUE vlist, VALUE elist) {
	Graph *G, *Gt ;
	int i, elist_len =( Check_Type(elist, T_ARRAY), (int)RARRAY_LEN(elist)), 
		vlist_len = ( Check_Type(vlist, T_ARRAY), (int)RARRAY_LEN(vlist) );
	Vertex *vertex_list[vlist_len] ;
	char *vertices[vlist_len] ;
	memset(vertex_list, 0, sizeof vertex_list);
	for(i = 0; i < vlist_len; i++){
		VALUE op = rb_ary_entry(vlist, i) ;
		Check_Type(op, T_STRING) ;
		vertex_list[i] = new_vertex(i + 1) ;
		vertex_list[i]->op = RSTRING_PTR(op) ;
	}
	for(i = 0; i < elist_len; i++){
		VALUE edge = rb_ary_entry(elist, i) ;
		int e1, e2 ;
		Check_Type(edge, T_ARRAY) ;
		e1 = FIX2INT(rb_ary_entry(edge, 1) ) ;
		e2 = FIX2INT(rb_ary_entry(edge, 0) );

		add_adjacency_vertex(vertex_list[e1], e2 + 1, (long)vertices[e2]) ;
	}
	G = new_graph(vlist_len, vertex_list);
	Gt = reverse(G) ;
	graph_obj = Data_Wrap_Struct(cGraph, 0, free_graph, G) ;
	reverse_graph_obj = Data_Wrap_Struct(cGraph, 0, free_graph, Gt) ;
}

int dfs(Graph *G, int s_label, int time[], VALUE delay){//no cycles
	int i ;
	char *op ;
	VALUE d_arr, d ;
	if(time[s_label] != -1){
		return time[s_label] ;
	}
	for(i = 0; i < G->adj_list[s_label]->degree; i++){
 		int *adj = (int *)G->adj_list[ s_label ]->list[ i ] ;
 		int time_step = dfs(G, adj[0], time, delay) ;
 		time[s_label] = (time[s_label] < time_step ? time_step : time[s_label] );
	}
	op = G->adj_list[s_label]->op ;
	d_arr = rb_hash_aref(delay, rb_str_new2(op) ) ;
	d = rb_funcall(d_arr, rb_intern("min"), 0) ;
	time[s_label] = time[s_label] + FIX2INT( d );
	return time[s_label] ;
}


int asap(Graph *Gt, int *time, VALUE delay){
	int i, max = 0 ;
	char *op ;
	for(i = 1; i <= Gt->V; i++){
		dfs(Gt, i, time, delay) ;
	}
	for(i = 1; i <= Gt->V; i++){
		VALUE d_arr, d ;
		op = Gt->adj_list[i]->op ;
		d_arr = rb_hash_aref(delay, rb_str_new2(op) ) ;
		d = rb_funcall(d_arr, rb_intern("min"), 0) ;
		max = (max < time[i] ? time[i] : max );
		time[i] = time[i] + 1 - FIX2INT( d ) ;
	}
	return max+1 ;
}

int alap(Graph *G, int *time, VALUE delay, int Q){
	int i, min = Q ;
	for(i = 1; i <= G->V; i++){
		dfs(G, i, time, delay) ;
	}
	for(i = 1; i <= G->V; i++){
		time[i] = Q - 1 - time[i] ;
		min = (min > time[i] ? time[i] : min) ;
	}
	return min ;
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
int dfs_paths(Graph *G, int s_label){//dfs only for DAG 
	int number_of_paths = G->adj_list[s_label]->paths ;
	if( number_of_paths != 0){	
		return number_of_paths ;
	}else{
		int sum = 0, i = 0  ;
		for(i = 0; i < G->adj_list[s_label]->degree; i++){
	 		int *adj = (int *)G->adj_list[ s_label ]->list[ i ] ;
			int allPO = dfs_paths(G, adj[0]) ;
			Internal *current = G->adj_list[adj[0] ]->in_count ;
			while (current != NULL){
				Internal *previous = NULL ;
				Internal *in = G->adj_list[s_label]->in_count ;
				while (in != NULL ){
					if( in->PO_label == current->PO_label){
						in->count += current->count ;
						break ;
					}
					previous = in ;
					in = in->next ;
				}
				if(in == NULL){
					if( previous == NULL){
						G->adj_list[s_label]->in_count = 
						new_internal(current->PO_label, current->count) ;
					}else{
						previous->next = 
						new_internal(current->PO_label, current->count ) ;
					}
				}
				current = current->next ;
			}
			sum += allPO ;
			
		}
		if(sum == 0 && i == 0){ 
		 	G->adj_list[s_label]->PO = 1 ;
			G->adj_list[s_label]->in_count = new_internal(s_label, 1 ) ;
			G->adj_list[s_label]->paths = 1 ;
			return 1;
		}else{
			G->adj_list[s_label]->paths = sum ;
			return sum ;
		}
	}
}

int compare(Vertex **a, Vertex **b){
	return ((*a)->paths - (*b)->paths) ;
}
Graph *sort(Graph *G){
	qsort(G->adj_list + 1, G->V, sizeof(Vertex *), (int(*)(const void*,const void*))compare ) ;
	return G ;
}

void number_of_distinct_paths(Graph *G){
	int i = 1 ;
	for ( i = 1; i <= G->V; i++){
		dfs_paths(G, i) ;
	}
	
/*
	sort (G_sorted) ;
	pg(G_sorted, stdout) ;
	pg(G, stdout) ;
	for ( i = 1; i <= G->V; i++){
		Internal *current = G->adj_list[i]->in_count ;
		printf("\n%d: \n", i) ;
		while (current != NULL){
			printf("[%d]: %d    ", current->PO_label, current->count) ;
			current = current->next ;
		}
	}
*///for test
}



void binder(Graph *G, int gap  ){
	Graph *G_sorted = sort( new_graph (G->V, G->adj_list + 1) );
	int i;
	for (i = 1; i <= G_sorted->V  ; i++){
		if(	strcmp (G_sorted->adj_list[i]->op, "+") == 0 || 
			strcmp(G_sorted->adj_list[i]->op, "x") == 0 ||
			strcmp(G_sorted->adj_list[i]->op, "ALU") == 0 ){
	
			Internal *current = G_sorted->adj_list[ i ]->in_count ;
			while(current != NULL){
				if(G->adj_list[ current->PO_label ]->PO_count + current->count > gap ){
					break ;
				}
				current = current->next ;
			}
			if(current == NULL){
				Internal *current = G_sorted->adj_list[ i ]->in_count ;
				G_sorted->adj_list[i]->implementation = 1 ;
				while(current != NULL){
					G->adj_list[ current->PO_label ]->PO_count += current->count * 1 ; 
					current = current->next ;
				}
			}else{
				G_sorted->adj_list[i]->implementation = 0 ;
			}
		}else{//Operations other than Addition and Multiply have no approximate implementations
				G_sorted->adj_list[i]->implementation = 0 ;
		}
	}
	if(G_sorted->adj_list != NULL){
		free(G_sorted->adj_list) ;
	}
	if(G_sorted->edge_list != NULL){
		free(G_sorted->edge_list) ;
	}
	if(G_sorted->edge_pair != NULL){
		free(G_sorted->edge_pair) ;
	}
	free(G_sorted);
	//Debug
	for(i = 1; i <= G->V; i++){
		printf("imple_%d: %d\n", i, G->adj_list[i]->implementation ) ;
	}
	//*/////////////////////
}


int dfs_post_binding(Graph *G, int s_label, int time[], VALUE delay){//no cycles
	int i ;
	char *op ;
	VALUE d_arr, d ;
	if(time[s_label] != -1){
		return time[s_label] ;
	}
	for(i = 0; i < G->adj_list[s_label]->degree; i++){
 		int *adj = (int *)G->adj_list[ s_label ]->list[ i ] ;
 		int time_step = dfs_post_binding(G, adj[0], time, delay) ;
 		time[s_label] = (time[s_label] < time_step ? time_step : time[s_label] );
	}
	op = G->adj_list[s_label]->op ;
	d_arr = rb_hash_aref(delay, rb_str_new2(op) ) ;
	//d = rb_funcall(d_arr, rb_intern("min"), 0) ;
	if(G->adj_list[s_label]->implementation == 0){
		d = rb_ary_entry(d_arr, 1) ;
	}else if(G->adj_list[s_label]->implementation == 1){
		d = rb_ary_entry(d_arr, 0) ;
	}else{
		d = INT2FIX(0) ;
	}
	time[s_label] = time[s_label] + FIX2INT( d );
	return time[s_label] ;
}


int alap_post_binding(Graph *G, int *time, VALUE delay, int Q){
	int i, min = Q ;
	for(i = 1; i <= G->V; i++){
		dfs_post_binding(G, i, time, delay) ;
	}
	for(i = 1; i <= G->V; i++){
		time[i] = Q - 1 - time[i] ;
		min = (min > time[i] ? time[i] : min) ;
	}
	return min ;
}
int cmp(int *a, int *b, int *time){
	return time[*a] - time[*b] ;
}



void list_scheduling(Graph *G, Graph *Gt, int *time, VALUE delay, int Q, int gap) {
	int *time_alap ;
	int *time_alap_index ;
	int *finished ;
	int nadd = 1, nmul = 1,nadd_appr = 1, nmul_appr = 1, i, j, t;//initial resource :1 adder and 1 multiplier
	int *add_ready_time, *mul_ready_time, *add_appr_ready_time, *mul_appr_ready_time ;


	add_ready_time = calloc(nadd, sizeof *add_ready_time) ;
	memset(add_ready_time, 0, nadd * sizeof *add_ready_time) ;
	
	mul_ready_time = calloc(nmul, sizeof *mul_ready_time) ;
	memset(mul_ready_time, 0, nmul * sizeof *mul_ready_time) ;

	add_appr_ready_time = calloc(nadd_appr, sizeof *add_appr_ready_time) ;
	memset(add_appr_ready_time, 0, nadd_appr * sizeof *add_appr_ready_time) ;
	
	mul_appr_ready_time = calloc(nmul_appr, sizeof *mul_appr_ready_time) ;
	memset(mul_appr_ready_time, 0, nmul_appr * sizeof *mul_appr_ready_time) ;

	time_alap = calloc(G->V + 1, sizeof *time_alap);
	memset(time_alap, 0xFF, (G->V + 1) * sizeof *time_alap) ; //set all entry -1
	time_alap_index = calloc(G->V , sizeof *time_alap);


	for(i = 0; i < G->V ; i++){
		time_alap_index[i]= i+1 ;
	}

	number_of_distinct_paths(G) ;
	binder(G, gap) ;
	alap_post_binding(G, time_alap, delay, Q ) ;

	qsort_r( time_alap_index, G->V, sizeof(int ),  (int(*)(const void*,const void*, void *))cmp, time_alap) ;
	//alap_post_binding(G, time, delay, Q ) ;
	for(i = 0; i < G->V; i++){
		printf("%d ", time_alap[ i + 1] ) ;
	}
	printf("\n") ;
/*
	for(i = 0; i < G->V; i++){
		printf("%d ", time_alap[ time_alap_index[i] ] ) ;
	}
*/
	for (t = 0; t < Q; t++ ){
		for (i = 0; i < G->V; i++){
			int ready_to_schedule = 1;
			if( time[ time_alap_index[i] ] >= 0){ //has been scheduled
				continue ;
			}
			
			for(j = 0; j < Gt->adj_list[ time_alap_index[i] ]->degree; j++){
	 			int *adj = (int *)Gt->adj_list[ time_alap_index[i] ]->list[ j ] ;
				VALUE d_arr = rb_hash_aref(delay, rb_str_new2(G->adj_list[ adj[0] ]->op) ) ;
				int imp =G->adj_list[ adj[0] ]->implementation; 
				int  d = FIX2INT(rb_ary_entry(d_arr, imp == 0 ? 1 : 0) ); 
				if(time [ adj[ 0 ] ] + d > t || time[ adj[0] ] < 0){
					ready_to_schedule = 0 ;
					break ;
				}
			}
			if(ready_to_schedule == 1 ){
				if(G->adj_list[ time_alap_index[i] ]->implementation == 0){
					VALUE d_arr = rb_hash_aref(delay, rb_str_new2(G->adj_list[time_alap_index[i] ]->op) ) ;
					int d = FIX2INT(rb_ary_entry(d_arr, 1) );
					if(strcmp(G->adj_list[time_alap_index[i] ]->op, "+")  == 0||
					   strcmp(G->adj_list[time_alap_index[i] ]->op, "ALU") == 0){
						for(j = 0; j < nadd; j++){
							if(add_ready_time[j] <= t && time[time_alap_index[i] ] <0){
								time[time_alap_index[i] ] = t ;
								add_ready_time[j] = t + d ;
							}
						}
						if(time[ time_alap_index[i] ] < 0 && t >= time_alap[ time_alap_index[i] ]){
							time[ time_alap_index[i] ] = t ;
							nadd += 1;
							add_ready_time = realloc(add_ready_time, nadd * sizeof *add_ready_time);
							add_ready_time[nadd - 1] = t + d ;
						}
						
					}else if(strcmp(G->adj_list[time_alap_index[i] ]->op, "x") == 0){
						for (j = 0; j<nmul; j++){
							if(mul_ready_time[j] <= t && time[time_alap_index[i] ] <0){
								time[time_alap_index[i]] = t ;
								mul_ready_time[j] = t + d ;
							}
						}
						if(time[ time_alap_index[i] ] < 0 && t >= time_alap[ time_alap_index[i] ]){
							time[ time_alap_index[i] ] = t ;
							nmul += 1;
							mul_ready_time = realloc(mul_ready_time, nmul * sizeof *mul_ready_time);
							mul_ready_time[nmul - 1] = t + d ;
						}
					}else{
						time[time_alap_index[i] ] = t;
					}
				}else if(G->adj_list[time_alap_index[i]]->implementation == 1){//approximate
					VALUE d_arr = rb_hash_aref(delay, rb_str_new2(G->adj_list[time_alap_index[i] ]->op) ) ;
					int d = FIX2INT(rb_ary_entry(d_arr, 0) );
					if(strcmp(G->adj_list[time_alap_index[i] ]->op, "+") == 0 ||
					   strcmp(G->adj_list[time_alap_index[i] ]->op, "ALU")  == 0){
						for(j = 0; j<nadd_appr; j++){
							if(add_appr_ready_time[j] <= t && time[time_alap_index[i] ] <0){
								time[time_alap_index[i] ] = t ;
								add_appr_ready_time[j] = t + d ;
							}
						}
						if(time[ time_alap_index[i] ] < 0 && t >= time_alap[ time_alap_index[i] ]){
							time[ time_alap_index[i] ] = t ;
							nadd_appr += 1;
							add_appr_ready_time = realloc(add_appr_ready_time, nadd_appr * sizeof *add_appr_ready_time);
							add_appr_ready_time[nadd_appr - 1] = t + d ;
						}
						
					}else if(strcmp(G->adj_list[time_alap_index[i] ]->op, "x") == 0){
						for (j = 0; j<nmul_appr; j++){
							if(mul_appr_ready_time[j] <= t && time[time_alap_index[i] ] <0){
								time[time_alap_index[i]] = t ;
								mul_appr_ready_time[j] = t + d ;
							}
						}
						if(time[ time_alap_index[i] ] < 0 && t >= time_alap[ time_alap_index[i] ]){
							time[ time_alap_index[i] ] = t ;
							nmul_appr += 1;
							mul_appr_ready_time = realloc(mul_appr_ready_time, nmul_appr * sizeof *mul_appr_ready_time);
							mul_appr_ready_time[nmul_appr - 1] = t + d ;
						}
					}else{
						time[time_alap_index[i] ] = t;
					}
				}
			}
		}
	}
	printf("\nacc+:%d appr+:%d acc_x:%d appr_x:%d\n", nadd, nadd_appr, nmul, nmul_appr) ; 
	free(time_alap);free(time_alap_index);
}
