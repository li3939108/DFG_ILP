%{
#include <string.h>
#include <grammar.tab.h>
#define BUFSIZ 4096
%}

GRAPH_EOF_TOKEN				[@]	
LETTER [A-Za-z_\200-\377]
DIGIT	[0-9]
NAME	{LETTER}({LETTER}|{DIGIT})*
NUMBER	[-]?(({DIGIT}+(\.{DIGIT}*)?)|(\.{DIGIT}+)){LETTER}?
ID		({NAME}|{NUMBER})
%x comment
%x qstring
%x hstring
%%
{GRAPH_EOF_TOKEN}               {return(EOF);}
<INITIAL,comment,qstring>\n     {line_num++;}
"/*"                            {BEGIN(comment);}
<comment>[^*\n]*                /* eat anything not a '*' */
<comment>"*"+[^*/\n]*           /* eat up '*'s not followed by '/'s */
<comment>"*"+"/"                {BEGIN(INITIAL);}
"//".*                          /* ignore C++-style comments */
^"#".*                          /* ppDirective (); */
"#".*                           /* ignore shell-like comments */
[ \t\r]                         /* ignore whitespace */
"\xEF\xBB\xBF"                  /* ignore BOM */
"node"                          {return(T_node);} /* see tokens in agcanonstr */
"edge"                          {return(T_edge);}
"graph"                         {
                                	if (!graphType){ graphType = T_graph;}
                                	return(T_graph);
                                }
"digraph"                       {
                                	if (!graphType){ graphType = T_digraph;}
                                	return(T_digraph);
                                }
"strict"                        {return(T_strict);}
"subgraph"                      {return(T_subgraph);}
"->"                            {
                                	if (graphType == T_digraph){ return(T_edgeop);
                                	} else{ return('-');}
                                }
"--"			            	{
                                	if (graphType == T_graph){ return(T_edgeop); 
                                	}else{ return('-');}
                                }
{NAME}                          { 
                                	yylval.str = yytext; 
                                	return(T_atom); 
                                }
{NUMBER}                        { 
                                	if (chkNum()){ yyless(yyleng-1);} 
                                	yylval.str = yytext; 
                                	return(T_atom); 
                                }

["]                             {BEGIN(qstring); beginstr();}
<qstring>["]                    {BEGIN(INITIAL); endstr(); return (T_qatom);}
<qstring>[\\]["]                {addstr ("\"");}
<qstring>[\\][\\]               {addstr ("\\\\");}
<qstring>[\\][\n]               {line_num++;} /* ignore escaped newlines */
<qstring>([^"\\]*|[\\])         {addstr(yytext);}
[<]                             {
                                	BEGIN(hstring); 
                                        html_nest++ ; 
                                        beginstr();
                                }
<hstring>[>]                    {
                                	html_nest--; 
                                	if (html_nest) {
                                	}else {
                                		BEGIN(INITIAL); 
                                		endstr_html(); 
                                		return (T_qatom);
                                	}
                                }

<hstring>[<]                    {html_nest++; addstr(yytext);}
<hstring>[\n]                   {addstr(yytext); line_num++;} /* add newlines */
<hstring>([^><\n]*)             {addstr(yytext);}
.                               {return (yytext[0]);}
%%
static int line_num = 1;
static int html_nest = 0;  /* nesting level for html strings */
static int graphType;
/* buffer for arbitrary length strings (longer than BUFSIZ) */
static char	*Sbuf,*Sptr,*Send;


static void beginstr(void) {
	if (Sbuf == NULL) {
		Sbuf = malloc(BUFSIZ);
		Send = Sbuf + BUFSIZ;
	}
	Sptr = Sbuf;
	*Sptr = 0;
}
static void addstr(char *src) {
	char	c;
	if (Sptr > Sbuf) Sptr--;
	do {
		do {c = *Sptr++ = *src++;} while (c && (Sptr < Send));
		if (c) {
			long	sz = Send - Sbuf;
			long	off = Sptr - Sbuf;
			sz *= 2;
			Sbuf = (char*)realloc(Sbuf,sz);
			Send = Sbuf + sz;
			Sptr = Sbuf + off;
		}
	} while (c);
}
static void endstr(void) {
	yylval.str = Sbuf;
}

static void endstr_html(void) {
	yylval.str = Sbuf;
}
static int chkNum(void) {
	unsigned char c = (unsigned char)yytext[yyleng-1];   /* last character */
	if (!isdigit(c) && (c != '.')) {  /* c is letter */
		return 1;
	}else {return 0;}
}
