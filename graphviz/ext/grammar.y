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
%type <str> optsubghdr qatom optmacroname
%type <val> graph body optstmtlist stmtlist stmt compound attrassignment attritem attrdefs optattrdefs attrlist optattr rcompound
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
				VALUE ret_hash = rb_hash_new(), nap_ary ;
				nap_ary = rb_ary_plus(
                        		rb_hash_aref($1, ID2SYM(rb_intern("v")) ) ,
                        		rb_hash_aref($2, ID2SYM(rb_intern("v")) ) );
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
                        	if($2 == Qnil){
					/* only node declaration */
					VALUE ret = rb_hash_new() ;
					VALUE node_attr_pair = rb_ary_new() ;
					VALUE nap_ary = rb_ary_new() ;
					VALUE node = ID2SYM($1) ;
                        		VALUE attr_hash = rb_hash_new();
					rb_ary_push(node_attr_pair, node) ;
                        		if(TYPE ($3) == T_ARRAY) {
                        			while (RARRAY_LEN($3) > 0 ){
                        				VALUE ary = rb_ary_pop( $3 ) ;
                        				VALUE str2 = rb_ary_pop(ary) ;
                        				VALUE str1 = rb_ary_pop(ary) ;
                         				Check_Type(str2, T_STRING) ;
                        				Check_Type(str1, T_STRING) ;
                        				rb_hash_aset(attr_hash, str1, str2 ) ;
                        			}
                        			rb_ary_push(node_attr_pair, attr_hash) ;
                        		}else if(TYPE( $3 ) == T_NIL) {
                        			rb_ary_push(node_attr_pair, rb_ary_new() );
                        		}else{rb_raise(rb_eFatal, "Grammar error") ;}
                        		rb_ary_push(nap_ary, node_attr_pair) ;
					rb_hash_aset(ret, ID2SYM(rb_intern("v")), nap_ary ) ;
					$$ = ret ;
                        	}else if ($2 != Qnil){ 
                        		/* TODO */
                        	}
                        }
                        ;

simple                  : nodelist { $$ = $1; }
                        | subgraph { $$ = Qnil; }
                        ;

rcompound               : T_edgeop  simple rcompound {
                        	if($2 == Qnil){rb_raise(rb_eFatal, "grammar error") ;}
                        	if ($3 == Qnil){$$ = $2 ;
                        	}else {
                        		        
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

atom                    :  T_atom {$$ = rb_intern($1); printf("T_atom: %s\n", $1) ; }
                        |  qatom {$$ = rb_intern($1);}
                        ;

qatom                   :  T_qatom {$$ = $1;}
                        |  qatom '+' T_qatom {$$ = strcat($1,$3);}
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
}
