/* recognize tokens for the calculator */
%option noyywrap nodefault yylineno
%{
# include "buf_header.h"
# include "buf_parser.tab.h"
%}

/* float exponent */
EXP ([Ee][-+]?[0-9]+)
%%

"+" |
"-" |
"*" |
"/" |
"=" |
"%" |
"!" |
"^" |
"|" |
"," |
";" |
"(" |
")" { return yytext[0]; }


">" { yylval.fn = 1; return CMP; }
"<" { yylval.fn = 2; return CMP; }
"<>" { yylval.fn = 3; return CMP; }
"==" { yylval.fn = 4; return CMP; }
">=" { yylval.fn = 5; return CMP; }
"<=" { yylval.fn = 6; return CMP; }
"!=" { yylval.fn = 7; return CMP; }


"if" { return IF; }
"then" { return THEN; }
"else" { return ELSE; }
"while" { return WHILE; }
"do" { return DO; }
"yak" { return LET;}
"loop" {return LOOP;}


"sqrt" { yylval.fn = B_sqrt; return FUNC; }
"exp" { yylval.fn = B_exp; return FUNC; }
"log" { yylval.fn = B_log; return FUNC; }
"print" { yylval.fn = B_print; return FUNC; }
"sin" { yylval.fn = B_sin; return FUNC; }
"cos" { yylval.fn = B_cos; return FUNC; }
"tan" { yylval.fn = B_tan; return FUNC; }
"asin" { yylval.fn = B_asin; return FUNC; }
"acos" { yylval.fn = B_acos; return FUNC; }
"atan" { yylval.fn = B_atan; return FUNC; }
"random" { yylval.fn = B_rand; return FUNC; }

"pow" { yylval.ft = B_pow; return FUNC2; }
"atan2" { yylval.ft = B_atan2; return FUNC2; }

\"[^\"\\n]*["\\n] { yylval.g = yytext; return STRING; }


[a-zA-Z][a-zA-Z0-9]* { yylval.s = lookup(yytext); return NAME; }

[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}? { yylval.d = atof(yytext); return NUMBER; }

"//".*
[ \t] /* ignore whitespace */

\\\n { printf("c> "); } /* ignore line continuation */

\n { return EOL; }

. { yyerror("Mystery character %c\n", *yytext); }
%%
