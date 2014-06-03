%{
#include <stdlib.h>
#include <stdio.h>
#include "ruby.h"
#ifndef NIL
#define NIL(type)               ((type)0)
#endif
int yylex(void) ;
void yyerror(const char * ) ;

%}
%union	{
	int i ;
	VALUE val ;
	char *str;
	ID id ;
}
%token <i> T_graph T_node T_edge T_digraph T_subgraph T_strict T_edgeop
	/* T_list, T_attr are internal tags, not really tokens */
%token T_list T_attr
%token <str> T_atom T_qatom

%type <i>  optstrict graphtype rcompound attrtype 
%type <str> optsubghdr optgraphname optmacroname atom qatom
%type <val> graph body optstmtlist stmtlist stmt compound
%type <id>  simple nodelist node
%%

graph                   : hdr body { $$ = $2 ;}
                        | error  { rb_raise( rb_eFatal, "Grammar error") ;}
                        | {}
                        ;

body                    : '{' optstmtlist '}' { $$ = $2; }
                        ;

hdr                     : optstrict graphtype optgraphname {}
                        ;

optgraphname            : atom {$$=$1;} 
                        | {$$=0;} 
                        ;

optstrict               : T_strict  {$$=1;} 
                        | {$$=0;} 
                        ;

graphtype               : T_graph {$$ = 0;} 
                        | T_digraph {$$ = 1;} 
                        ;

optstmtlist             : stmtlist  { $$ = $1 ;}
                        | {}
                        ;

stmtlist                : stmtlist stmt {
                        	VALUE hash1 = $1, hash2 = $2 ;
				VALUE ret_hash = rb_hash_new(), nap_ary ;
				nap_ary = rb_ary_plus(
                        		rb_hash_aref(hash1, ID2SYM("v") ) ,
                        		rb_hash_aref(hash2, ID2SYM("v") ) );
                        	rb_hash_aset(ret_hash, ID2SYM("v"), nap_ary) ;



                        	$$ = ret_hash ;
                        }
                        | stmt {$$ = $1; } 
                        ;

optsemi                 : ';' | ;

stmt                    :  attrstmt  optsemi { $$ = Qnil ; }
                        |  compound  optsemi { Check_Type($1, T_HASH); $$ = $1 ; }
                        ;

compound                : simple rcompound optattr {
                        	if ($2 != 0){ 
                        		$$ = 0 ;
                        	}else if($2 == 0){
					/* only node declaration */
					VALUE ret = rb_hash_new() ;
					VALUE node_attr_pair = rb_ary_new() ;
					VALUE nap_ary = rb_ary_new() ;
					VALUE node = ID2SYM($1) ;
					//VALUE attr = $3 ;
					rb_ary_push(node_attr_pair, node) ;
					rb_ary_push(node_attr_pair, attr) ;
					rb_ary_push(nap_ary, node_attr_pair) ;
					rb_hash_aset(ret, ID2SYM("v"), nap_ary ) ;
					$$ = ret ;
                        	} }
                        ;

simple                  : nodelist { $$ = $1; }
                        | subgraph { $$ = 0; }
                        ;

rcompound               : T_edgeop {} simple {} rcompound {$$ = 1;}
                        | {$$ = 0;}
                        ;


nodelist                : node { $$ = $1; }
                        | nodelist ',' node ;

node                    : atom { $$ = rb_intern($1); }
                        | atom ':' atom { $$ = rb_intern($1); } 
                        | atom ':' atom ':' atom { $$ = rb_intern($1); }
                        ;

attrstmt                :  attrtype optmacroname attrlist {}
                        |  graphattrdefs {}
                        ;

attrtype                : T_graph {$$ = T_graph;}
                        | T_node {$$ = T_node;}
                        | T_edge {$$ = T_edge;}
                        ;

optmacroname            : atom '=' {}
                        | /* empty */ { }
                        ;

optattr                 : attrlist |  /* empty */ ;

attrlist                : optattr '[' optattrdefs ']' ;

optattrdefs             : optattrdefs attrdefs 
                        | /* empty */ ;

attrdefs                :  attritem optseparator
                        ;

attritem                : attrassignment | attrmacro ; 

attrassignment          :  atom '=' atom {





                        }
                        ;

attrmacro               : '@' atom /* not yet impl */
                        ;

graphattrdefs           : attrassignment
                        ;

subgraph                : optsubghdr {opensubg($1);} body {closesubg();}
                        ;

optsubghdr              : T_subgraph atom {}
                        | T_subgraph  {}
                        | {}
                        ;

optseparator            :  ';' | ',' | /*empty*/ ;

atom                    :  T_atom {$$ = $1;}
                        |  qatom {$$ = $1;}
                        ;

qatom                   :  T_qatom {$$ = $1;}
                        |  qatom '+' T_qatom {$$ = strcat($1,$3);}
                        ;
%%
static VALUE initialize(VALUE self){
	VALUE id = rb_hash_new(); 
	VALUE vertex = rb_ary_new() ;

	rb_iv_set(self, "@id", id) ;
	rb_iv_set(self, "@vertex", vertex) ;

	return self ;
}

static VALUE parse(VALUE self, VALUE str){
	FILE *file = fopen(RSTRING_PTR (str), "r") ;
	Check_Type(str, T_STRING) ;
	if(file == NULL){
		rb_raise(rb_eFatal, "No such file: %s", RSTRING_PTR) ;
	}
	if(yyparse() == 0){
		fclose(file) ;
	}else{
		fclose(file) ;
		rb_raise(rb_eFatal, "Parse error") ;
	}
	return Qnil ;
}



void Init_Parser(){
	VALUE DFG_ILP_mod = rb_const_get(rb_cObject, rb_intern("DFG_ILP")) ;
	cParser = rb_define_class_under(DFG_ILP_mod, "Parser", rb_cObject) ;
	rb_define_method(cParser,"parse", parse, 1);
	rb_define_method(cParser,"initialize", initialize, 1);
}
