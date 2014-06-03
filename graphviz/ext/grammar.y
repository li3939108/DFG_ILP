/************************************
   2014 Chaofan Li <chaof@tamu.edu>
 ***********************************/
%{
#include "ruby.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifndef NIL
#define NIL(type)               ((type)0)
#endif
int yylex(void) ;
void yyerror(const char * ) ;
VALUE cParser ;
extern FILE *yyin ;
%}
%union	{
	long i ;
	VALUE val ;
	char *str;
	ID id ;
}
%token <i> T_graph T_node T_edge T_digraph T_subgraph T_strict T_edgeop
	/* T_list, T_attr are internal tags, not really tokens */
%token T_list T_attr
%token <str> T_atom T_qatom

%type <i>  optstrict graphtype rcompound attrtype 
%type <str> optsubghdr qatom optmacroname
%type <val> graph body optstmtlist stmtlist stmt compound attrassignment attritem attrdefs optattrdefs attrlist optattr
%type <id>  simple nodelist node atom  optgraphname
%%

graph                   : hdr body { $$ = $2 ; rb_cvar_set(cParser, rb_intern("@@result"), $$); /*rb_funcall(rb_mKernel, rb_intern("print"), 2, ($$), rb_str_new2("\n")   );*/ }
                        | error  { rb_raise( rb_eFatal, "Grammar error") ;}
                        | {
                        	
                        }
                        ;

body                    : '{' optstmtlist '}' { $$ = $2;}
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
                        		rb_hash_aref(hash1, ID2SYM(rb_intern("v")) ) ,
                        		rb_hash_aref(hash2, ID2SYM(rb_intern("v")) ) );
                        	rb_hash_aset(ret_hash, ID2SYM(rb_intern("v")), nap_ary) ;
                        	$$ = ret_hash ;
                        }
                        | stmt {$$ = $1; } 
                        ;

optsemi                 : ';' | ;

stmt                    :  attrstmt  optsemi { $$ = Qnil ; }
                        |  compound  optsemi { Check_Type($1, T_HASH); $$ = $1 ;}
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
                        		int attr_len = RARRAY_LEN ($3), i ;
                        		for (i = 0; i < attr_len; i++){
                        		}
					//rb_ary_push(node_attr_pair, attr) ;
					rb_ary_push(node_attr_pair, node) ;
					rb_ary_push(nap_ary, node_attr_pair) ;
					rb_hash_aset(ret, ID2SYM(rb_intern("v")), nap_ary ) ;
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

node                    : atom { 
                        	$$ = $1; 
                        	
                        }
                        | atom ':' atom { $$ = $1; } 
                        | atom ':' atom ':' atom { $$ = $1; }
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

optattr                 : attrlist {$$ = $1;}
                        | { $$ = Qnil;}
                        ;

attrlist                : optattr '[' optattrdefs ']' {
                        	if($1 == Qnil){ $$ = $3 ;
                        	}else{ $$ = rb_ary_plus( $1, $3) ;}
                        }
                        ;

optattrdefs             : optattrdefs attrdefs { $$ = rb_ary_push($1, $2); }
                        | {$$ = rb_ary_new() ;}
                        ;

attrdefs                :  attritem optseparator {$$ = $1 ;}
                        ;

attritem                : attrassignment {$$ = $1; }
                        | attrmacro ; 

attrassignment          :  atom '=' atom {
                        	VALUE key = rb_id2str($1) ;
                        	VALUE value = rb_id2str($2) ;
                        	VALUE ret = rb_ary_new() ;
                        	rb_ary_push(ret, key) ;
                        	$$ = rb_ary_push(ret, value) ;
                        }
                        ;

attrmacro               : '@' atom /* not yet impl */
                        ;

graphattrdefs           : attrassignment
                        ;

subgraph                : optsubghdr {} body {}
                        ;

optsubghdr              : T_subgraph atom {}
                        | T_subgraph  {}
                        | {}
                        ;

optseparator            :  ';' | ',' | /*empty*/ ;

atom                    :  T_atom {$$ = rb_intern($1); printf("T_atom: %s\n", $1) ; }
                        |  qatom {$$ = rb_intern($1);}
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
		rb_raise(rb_eFatal, "No such file: %s", RSTRING_PTR(str) ) ;
	}else{
		yyin = file ;
	}
	if(yyparse() == 0){
		rb_ivar_set(self, rb_intern("@result"), rb_cvar_get(cParser, rb_intern("@@result") ) );
		fclose(file) ;
		
		rb_funcall(rb_mKernel, rb_intern("print"), 3, rb_str_new2("result: "),  rb_ivar_get(self, rb_intern("@result")) , rb_str_new2("\n") );
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
	rb_define_method(cParser,"initialize", initialize, 0);
}
