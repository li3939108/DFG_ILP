/************************************
   2014 Chaofan Li <chaof@tamu.edu>
 ***********************************/
%{
#include "ruby.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "grammar.tab.h"
#ifndef NIL
#define NIL(type)               ((type)0)
#endif
int yylex(void) ;
void yyerror(VALUE, const char *msg) ;
VALUE cParser ;
extern FILE *yyin ;
%}
%parse-param {VALUE self}
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

%type <i>  optstrict graphtype attrtype 
%type <str> optsubghdr optmacroname
%type <val> attrassignment attritem attrdefs optattrdefs attrlist optattr rcompound qatom 
%type <id>  simple nodelist node atom  optgraphname
%%

graph                   : hdr body {/* $$ = $2 ; rb_ivar_set(cParser, rb_intern("@result"), $$);*/ /*rb_funcall(rb_mKernel, rb_intern("print"), 2, ($$), rb_str_new2("\n")   );*/ }
                        | error  { rb_raise( rb_eFatal, "Grammar error") ;}
                        | {
                        	
                        }
                        ;

body                    : '{' optstmtlist '}' {/* $$ = $2;*/YYACCEPT ;}
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

optstmtlist             : stmtlist  {/* $$ = $1 ;*/}
                        | {}
                        ;

stmtlist                : stmtlist stmt {
/*
				VALUE ret_hash = rb_hash_new(), nap_ary ;
				nap_ary = rb_ary_plus(
                        		rb_hash_aref($1, ID2SYM(rb_intern("v")) ) ,
                        		rb_hash_aref($2, ID2SYM(rb_intern("v")) ) );
                        	rb_hash_aset(ret_hash, ID2SYM(rb_intern("v")), nap_ary) ;
                        	$$ = ret_hash ;
*/
                        }
                        | stmt {/*$$ = $1;*/ } 
                        ;

optsemi                 : ';' | ;

stmt                    :  attrstmt  optsemi {/* $$ = Qnil ;*/ }
                        |  compound  optsemi {/* Check_Type($1, T_HASH); $$ = $1 ;*/}
                        ;

compound                : simple rcompound optattr {
                        	if($1 == Qnil){rb_raise(rb_eFatal, "grammar error") ;}

                        	VALUE id = rb_ivar_get(self, rb_intern("@id") ) ;
                        	VALUE vertex = rb_ivar_get(self, rb_intern("@vertex") );
                        	VALUE v = rb_hash_aref(id, ID2SYM($1) ) ;
                        	if(v == Qnil){
                        		long len = RARRAY_LEN( vertex ) ;
                        		rb_ary_push(vertex , rb_ary_new3(2, ID2SYM($1), rb_hash_new()  ) ) ;
                        		rb_hash_aset( id, ID2SYM($1), INT2FIX( len ) ) ;
                        	}
                        	if($2 == Qnil){
					/* only node declaration */

                        		VALUE attr_hash = rb_ary_entry( 
                         			rb_ary_entry( vertex, FIX2LONG (rb_hash_aref(id, ID2SYM($1)) ) ), 1 );
                        		if(TYPE ($3) == T_ARRAY) {
                        			while (RARRAY_LEN($3) > 0 ){
                        				VALUE ary = rb_ary_pop( $3 ) ;
                        				VALUE str2 = rb_ary_pop(ary) ;
                        				VALUE str1 = rb_ary_pop(ary) ;
                         				Check_Type(str2, T_STRING) ;
                        				Check_Type(str1, T_STRING) ;
                        				rb_hash_aset(attr_hash, str1, str2 ) ;
                        			}
                        		}else if(TYPE( $3 ) == T_NIL) {
                        		}else{rb_raise(rb_eFatal, "Grammar error") ;}

                        	}else { 
                        		VALUE edge = rb_ivar_get(self, rb_intern("@edge") ) ;
                        		rb_ary_push ( edge, rb_ary_new3(2, 
                        			rb_hash_aref(id, ID2SYM( $1)), 
                        			rb_hash_aref(id, ID2SYM( $2))) );
   
                        	}
                        }
                        ;

simple                  : nodelist { $$ = $1; }
                        | subgraph { $$ = Qnil; }
                        ;

rcompound               : T_edgeop  simple rcompound {
                        	if($2 == Qnil){rb_raise(rb_eFatal, "grammar error") ;}
                        	VALUE id = rb_ivar_get(self, rb_intern("@id") ) ;
                        	VALUE vertex = rb_ivar_get(self, rb_intern("@vertex") );
                        	VALUE v = rb_hash_aref(id, ID2SYM($2) ) ;
                        	if(v == Qnil){
                        		long len = RARRAY_LEN( vertex ) ;
                        		rb_ary_push(vertex , rb_ary_new3(2, ID2SYM($2), rb_hash_new() ) ) ;
                        		rb_hash_aset( id, ID2SYM($2), INT2FIX( len ) ) ;
                        	}
                        	
                        	if ($3 == Qnil){
                        		$$ = $2 ;
                        	}else {
                        		VALUE edge = rb_ivar_get(self, rb_intern("@edge") ) ;
                        		rb_ary_push ( edge, rb_ary_new3(2, 
                        			rb_hash_aref(id, ID2SYM( $2)), 
                        			rb_hash_aref(id, ID2SYM( $3))) );
                        		$$ = $2 ;
                        	}
                        }
                        | {$$ = Qnil;}
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
                        | attrmacro {$$ = Qnil;} ; 

attrassignment          :  atom '=' atom {
                        	VALUE key = rb_id2str($1) ;
                        	VALUE value = rb_id2str($3) ;
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

atom                    :  T_atom {$$ = rb_intern($1); }
                        |  qatom {$$ = rb_intern_str($1);}
                        ;

qatom                   :  T_qatom {$$ = rb_str_new2($1) ;}
                        |  qatom '+' T_qatom {$$ = rb_str_plus($1, rb_str_new2($3) );}
                        ;
%%

static VALUE parse(VALUE self, VALUE str){
	FILE *file = fopen(RSTRING_PTR (str), "r") ;
	Check_Type(str, T_STRING) ;
	if(file == NULL){
		rb_raise(rb_eFatal, "No such file: %s", RSTRING_PTR(str) ) ;
	}else{
		yyin = file ;
	}
	if(yyparse(self) == 0){
		fclose(file) ;
	}else{
		fclose(file) ;
		rb_raise(rb_eFatal, "Parse error") ;
	}
	return self ;
}

void Init_parser_ext(){
	VALUE DFG_ILP_mod = rb_const_get(rb_cObject, rb_intern("DFG_ILP")) ;
	rb_define_method(rb_const_get(DFG_ILP_mod, rb_intern("Parser")),"_parse", parse, 1);
}
