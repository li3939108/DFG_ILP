/*******************************************
   2014 by Chaofan Li <chaof@tamu.edu>
********************************************/

#ifndef __AS_POSSBLE_H__
#define __AS_POSSBLE_H__

#include "ruby.h"
#include "graph.h"

extern void get_graph(VALUE vlist, VALUE elist) ;
extern int dfs(Graph *G, int s_label, int time[], VALUE delay, VALUE delay_type) ;
extern int asap(Graph *G, int *time, VALUE delay, VALUE delay_type) ;
extern int alap(Graph *G, int *time, VALUE delay, int Q,VALUE  delay_type) ;
extern void mobility(Graph *G, int *m, VALUE delay, int Q, VALUE delay_type) ;
extern void number_of_distinct_paths(Graph *G) ;
extern void list_scheduling(Graph *G, Graph *Gt, int *time, VALUE delay, int Q, int gap) ;

#endif
