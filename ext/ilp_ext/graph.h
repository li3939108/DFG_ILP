/*******************************************
   2014 by Chaofan Li <chaof@tamu.edu>
********************************************/

#ifndef __GRAPH_H__
#define __GRAPH_H__

#define MAX_EDGE_WEIGHT 5000000
#include <stdio.h>

typedef struct _Internal{
	int PO_label ;
	int count ;
	struct _Internal *next ;
} Internal ;
typedef struct _Vertex{
	int implementation ;
	int PO ;
	int PO_count ;
	Internal *in_count ;		
	int degree ;
	int paths ; //Distinct Paths to Primary Outputs
	int label ;
	int rank ;//for use with Make-Set-Find 
	char *op ;
	int (*list)[2];//[label, operation] 
	struct _Vertex *parent ;//for use with Make-Set-Find
} Vertex;

typedef struct _Graph{
	int V ;
	int E ;
	int (*edge_list)[2] ; // [label,weight]
	int (*edge_pair)[2] ; //[v1, v2]
	Vertex **adj_list ;
} Graph;

extern Graph *new_graph(int V, Vertex *vertex_list[]) ;
extern Graph *reverse(Graph *) ;
extern Vertex *new_vertex(int label) ;
extern void free_vertex(Vertex *v);
extern void free_graph(Graph *G);
extern void add_adjacency_vertex(Vertex *v, int label, int weight) ;
extern Graph *gen(int D, int V) ;
extern void pg(Graph *, FILE *fp) ;
extern void pv(Vertex *, FILE *fp) ;
extern void edges(Graph *, FILE* output) ;
extern Internal *new_internal(int s_label, int count) ;

#endif
