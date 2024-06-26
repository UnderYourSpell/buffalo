/* calculator with AST */
%{
# include <stdio.h>
# include <stdlib.h>
# include "buf_header.h"
%}

%union {
    struct ast *a;
    double d;
    struct symbol *s; /*which symbol*/
    char* g;
    struct symlist *sl;
    int fn; /*which function*/
    int ft; /*which 2 arg function*/
}
/* declare tokens */
%token <d> NUMBER
%token <s> NAME
%token <fn> FUNC
%token <ft> FUNC2
%token <g> STRING
%token EOL
%token IF THEN ELSE WHILE DO LET LOOP

%nonassoc <fn> CMP
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

%type <a> exp stmt list explist string_expr
%type <sl> symlist
%start calclist


%%
stmt: IF exp THEN list           { $$ = newflow('I', $2, $4, NULL); }
    | IF exp THEN list ELSE list { $$ = newflow('I', $2, $4, $6); }
    | WHILE exp DO list          { $$ = newflow('W', $2, $4, NULL); }
    | exp
    | LOOP exp DO list{$$ = newflow ('R',$2,$4,NULL);}
;

list: /* nothing */ { $$ = NULL; }
    | stmt ';' list { if ($3 == NULL)
        $$ = $1;
    else
        $$ = newast('L', $1, $3);
    }
;

exp: exp CMP exp { $$ = newcmp($2, $1, $3); }
    | exp '+' exp { $$ = newast('+', $1,$3); }
    | exp '-' exp { $$ = newast('-', $1,$3);}
    | exp '*' exp { $$ = newast('*', $1,$3); }
    | exp '/' exp { $$ = newast('/', $1,$3); }
    | exp '%' exp { $$ = newast('%', $1,$3); }
    | exp '^' exp { $$ = newast('^', $1,$3); }
    | exp '!' { $$ = newast('!', $1, NULL); }
    | '|' exp { $$ = newast('|', $2, NULL); }
    | '(' exp ')' { $$ = $2; }
    | '-' exp %prec UMINUS { $$ = newast('M', $2, NULL); }
    | NUMBER { $$ = newnum($1); }
    | NAME { $$ = newref($1); }
    | NAME '=' exp { $$ = newasgn($1, $3); }
    | FUNC '(' explist ')' { $$ = newfunc($1, $3); }
    | NAME '(' explist ')' { $$ = newcall($1, $3); }
    | FUNC2 '('exp','exp')'{ $$ = newfunc2($1, $3, $5);}
;

string_expr: STRING {$$ = $1;}


explist: exp
    | exp ',' explist { $$ = newast('L', $1, $3); }
;

symlist: NAME { $$ = newsymlist($1, NULL); }
    | NAME ',' symlist { $$ = newsymlist($1, $3); }
;

calclist: /* nothing */
    | calclist stmt EOL {
        printf("= %4.4g\n>> ", eval($2));
        treefree($2);
    }
    | calclist LET NAME '(' symlist ')' '=' list EOL {
            dodef($3, $5, $8);
            printf("Defined %s\n-> ", $3->name); }
    | calclist string_expr EOL{
        printf("String: %s", $2);
    }
    | calclist error EOL { yyerrok; printf(">> "); }
;
%%
