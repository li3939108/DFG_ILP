/*******************************************
   2014 by Chaofan Li <chaof@tamu.edu>
********************************************/

#ifndef __AS_POSSBLE_H__
#define __AS_POSSBLE_H__

#include "ruby.h"
#include "graph.h"

extern void get_graph(VALUE vlist, VALUE elist) ;
extern int dfs(Graph *G, int s_label, int time[], VALUE delay) ;
extern int asap(Graph *G, int *time, VALUE delay) ;
extern int alap(Graph *G, int *time, VALUE delay, int Q) ;
extern void mobility(Graph *G, int *m, VALUE delay, int Q) ;

#endif
