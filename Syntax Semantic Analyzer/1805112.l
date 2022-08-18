%option noyywrap    

%x INSIDE_STRING_STATE

%{
    #include "SymbolTable.h"
    #include "y.tab.h"

    #define YYSTYPE SymbolInfo*

    extern FILE *log_output;
    extern int line_count;
    extern int error_count;
    extern SymbolTable symbolTable;
    

    char convertSpecialCharacter(char *ch){
        if(ch[1] != '\\'){
            return ch[1];
        } else if(ch[1] == '\\') {
            if(ch[2] == 'n')
                return (char)10;
            else if(ch[2] == 't')
                return (char)9;
            else if(ch[2] == '\\')
                return (char)92;
            else if(ch[2] == '\'')
                return (char)39;
            else if(ch[2] == 'a')
                return (char)7;
            else if(ch[2] == 'f')
                return (char)12;
            else if(ch[2] == 'r')
                return (char)13;
            else if(ch[2] == 'b')
                return (char)8;
            else if(ch[2] == 'v')
                return (char)11;
            else if(ch[2] == '0')
                return (char)0;
            else if(ch[2] == '\"')
                return (char)34;    
        }
        return *ch;
    }
%}

NEWLINE \r?\n
WHITESPACE [ \t\f\v\r]+


ADDOP [+-]
MULOP [*/%]
INCOP ("++")
DECOP ("--")
RELOP ("<"|"<="|">"|">="|"=="|"!=")
ASSIGNOP [=]
LOGICOP ("&&"|"||")
NOT [!]
LPAREN [(]
RPAREN [)]
LCURL [{]
RCURL [}]
LTHIRD ("[")
RTHIRD ("]")
COMMA [,]
SEMICOLON [;]

DIGITS [0-9]+

CONST_INT {DIGITS}
CONST_FLOAT {DIGITS}?(\.{DIGITS})?([Ee][+-]?{DIGITS})?

SPECIAL_CHAR '(\\[nt\\\'\"afrbv0'])'
CHAR '([ -~]{-}['\\])'
CONST_CHAR {SPECIAL_CHAR}|{CHAR}

IDENTIFIERS [a-zA-Z_][a-zA-Z0-9_]*

STRING_BEGIN \"
SPECIAL_CHAR_INSIDE_STRING (\\[nt\\afrbv0\"\'])

SINGLE_COMMENT \/\/(([\\]+([\n])?)?|([^\n])*)*
MULTI_COMMENT_FLAG (\/\*)
MULTI_COMMENT (\/\*)([^\*]|\*[^\/])*(\*\/)


DECIMAL_POINT_ERROR ({DIGITS}\.{DIGITS}\.{DIGITS})+
ILL_FORMATION_ERROR ([0-9]\.)+|({DIGITS}*([Ee][+-]?{DIGITS})+(\.{DIGITS})+)
INVALID_SUFFIX_PREFIX_ERROR ([0-9]+[a-zA-Z_]+)|([a-zA-Z_]+[0-9]+)
MULTI_CHAR_CONST_ERROR '(([ -~]{-}['\\])([ -~]{-}['\\])+)'
UNFINISHED_CHAR_ERROR ('([ -~]{-}['\\])*)|('(\\[nt\\\'afrbv0'])*)
UNFINISHED_COMMENT_ERROR (\/\*)([^\*]|\*[^\/])*


%%

{WHITESPACE}    { }

"if"    {
    return IF;
}

"else"    {
    return ELSE;
}

"for"    {
    return FOR;
}

"while"    {
    return WHILE;
}

"int"    {
    return INT;
}

"float"    {
    return FLOAT;
}

"void"    {
    return VOID;
}

"printf"    {
    return PRINTLN;
}

"return"    {
    return RETURN;
}




{ADDOP} {
    // fprintf(token_output, "<ADDOP, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <ADDOP> Lexeme %s found.\n\n", line_count, yytext);

    string tempstring(yytext);
    SymbolInfo* tempsymbol = new SymbolInfo(tempstring, "ADDOP");
    yylval.symbolInfo = (YYSTYPE)tempsymbol;
    return ADDOP;
}

{MULOP} {
    // fprintf(token_output, "<MULOP, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <MULOP> Lexeme %s found.\n\n", line_count, yytext);
    
    string tempstring(yytext);
    SymbolInfo* tempsymbol = new SymbolInfo(tempstring, "MULOP");
    yylval.symbolInfo = (YYSTYPE)tempsymbol;
    return MULOP;
}

{INCOP} {
    // fprintf(token_output, "<INCOP, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <INCOP> Lexeme %s found.\n\n", line_count, yytext);

    return INCOP;
}

{DECOP} {
    return DECOP;
}

{RELOP} {
    
    // fprintf(token_output, "<RELOP, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <RELOP> Lexeme %s found.\n\n", line_count, yytext);

    string tempstring(yytext);
    SymbolInfo* tempsymbol = new SymbolInfo(tempstring, "RELOP");
    yylval.symbolInfo = (YYSTYPE)tempsymbol;
    return RELOP;

}

{ASSIGNOP} {
    // fprintf(token_output, "<ASSIGNOP, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <ASSIGNOP> Lexeme %s found.\n\n", line_count, yytext);

    return ASSIGNOP;
}

{LOGICOP} {
    // fprintf(token_output, "<LOGICOP, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <LOGICOP> Lexeme %s found.\n\n", line_count, yytext);

    string tempstring(yytext);
    SymbolInfo* tempsymbol = new SymbolInfo(tempstring, "LOGICOP");
    yylval.symbolInfo = (YYSTYPE)tempsymbol;
    return LOGICOP;

}

{NOT} {
    // fprintf(token_output, "<NOT, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <NOT> Lexeme %s found.\n\n", line_count, yytext);
    return NOT;
}

{LPAREN} {
    // fprintf(token_output, "<LPAREN, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <LPAREN> Lexeme %s found.\n\n", line_count, yytext);

    return LPAREN;
}

{RPAREN} {
    // fprintf(token_output, "<RPAREN, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <RPAREN> Lexeme %s found.\n\n", line_count, yytext);

    return RPAREN;
}

{LCURL} {
    // symbolTable->enterScope();
    // fprintf(token_output, "<LCURL, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <LCURL> Lexeme %s found.\n\n", line_count, yytext);

    return LCURL;
}

{RCURL} {
    // symbolTable->exitScope();
    // fprintf(token_output, "<RCURL, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <RCURL> Lexeme %s found.\n\n", line_count, yytext);

    return RCURL;
}

{LTHIRD} {
    // fprintf(token_output, "<LTHIRD, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <LTHIRD> Lexeme %s found.\n\n", line_count, yytext);

    return LTHIRD;
}

{RTHIRD} {
    // fprintf(token_output, "<RTHIRD, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <RTHIRD> Lexeme %s found.\n\n", line_count, yytext);

    return RTHIRD;
}

{COMMA} {
    // fprintf(token_output, "<COMMA, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <COMMA> Lexeme %s found.\n\n", line_count, yytext);

    return COMMA;
}

{SEMICOLON} {
    // fprintf(token_output, "<SEMICOLON, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <SEMICOLON> Lexeme %s found.\n\n", line_count, yytext);

    return SEMICOLON;
}



{CONST_INT} {
    // fprintf(token_output, "<CONST_INT, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <CONST_INT> Lexeme %s found.\n\n", line_count, yytext);
    // if (symbolTable == nullptr) {
    //     symbolTable = new SymbolTable(new ScopeTable(bucketNo, "1"));
    // }
    // SymbolInfo *symbol = new SymbolInfo(yytext, "CONST_INT");
    // if (symbolTable->insertSymbol(symbol, log_output)) {
    //     symbolTable->printAllScopeTable(log_output);
    // }else 
    //     delete symbol;

    string tempstring(yytext);
    SymbolInfo* tempsymbol = new SymbolInfo(tempstring, "CONST_INT");
    yylval.symbolInfo = (YYSTYPE)tempsymbol;
    return CONST_INT;
    

}

{CONST_FLOAT} {
    // fprintf(token_output, "<CONST_FLOAT, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <CONST_FLOAT> Lexeme %s found.\n\n", line_count, yytext);
    // if (symbolTable == nullptr) {
    //     symbolTable = new SymbolTable(new ScopeTable(bucketNo, "1"));
    // }
    // SymbolInfo *symbol = new SymbolInfo(yytext, "CONST_FLOAT");
    // if (symbolTable->insertSymbol(symbol, log_output)) {
    //     symbolTable->printAllScopeTable(log_output);
    // }else 
    //     delete symbol;

    string tempstring(yytext);
    SymbolInfo* tempsymbol = new SymbolInfo(tempstring, "CONST_FLOAT");
    yylval.symbolInfo = (YYSTYPE)tempsymbol;
    return CONST_FLOAT;
}


{IDENTIFIERS}   {
    // fprintf(token_output, "<ID, %s> ", yytext);
    // fprintf(log_output, "Line no %d: Token <ID> Lexeme %s found.\n\n", line_count, yytext);
    // if (symbolTable == nullptr) {
    //     symbolTable = new SymbolTable(new ScopeTable(bucketNo, "1"));
    // }
    // SymbolInfo *symbol = new SymbolInfo(yytext, "ID");
    // bool result = symbolTable->insertSymbol(symbol, log_output);
    // if (!result) {
    //     delete symbol;
    // }else
    //     symbolTable->printAllScopeTable(log_output);

    string tempstring(yytext);
    SymbolInfo* tempsymbol = new SymbolInfo(tempstring, "ID");
    yylval.symbolInfo = (YYSTYPE)tempsymbol;
    return ID;
}

{STRING_BEGIN}  {

    // BEGIN INSIDE_STRING_STATE;
    // str_lexeme.append(yytext);
    // str_real.append(yytext);


}

<INSIDE_STRING_STATE><<EOF>>  {
    // fprintf(log_output, "Error at line no %d: Unterminated string %s\n\n", line_count+1, const_cast<char*>(str_real.c_str()));
    // str_lexeme = "";
    // str_real = "";
    // total_errors ++;
    // BEGIN INITIAL;
    // return 0;

}

<INSIDE_STRING_STATE>{NEWLINE}     {
    // fprintf(log_output, "Error at line no %d: Unterminated String %s\n\n", line_count, const_cast<char*>(str_lexeme.c_str()));
    // str_real = "";
    // str_lexeme = "";
    // line_count ++;
    // total_errors ++;
    // BEGIN INITIAL;
}

<INSIDE_STRING_STATE>\" {
    // str_real.append(yytext);
    // str_lexeme.append(yytext);
    // fprintf(token_output, "<STRING, %s> ", const_cast<char*>(str_real.c_str()));
    // fprintf(log_output, "Line no %d: Token <STRING> Lexeme %s found --> <String, %s>\n\n", line_count, const_cast<char*>(str_lexeme.c_str()), const_cast<char*>(str_real.c_str()));
    // str_real = "";
    // str_lexeme = "";
    // BEGIN INITIAL;
}

<INSIDE_STRING_STATE>((\\){NEWLINE})    {
    // line_count++;
    // str_lexeme.append(yytext);
}

<INSIDE_STRING_STATE>{SPECIAL_CHAR_INSIDE_STRING}   {
    // str_lexeme.append(yytext);
    // if(yytext[1]=='n'){
    //     str_real.append(1u, '\n');
    // } else if(yytext[1]=='t'){
    //     str_real.append(1u, '\t');
    // } else if(yytext[1]=='\\'){
    //     str_real.append(1u, '\\');
    // } else if(yytext[1]=='\''){
    //     str_real.append(1u, '\'');
    // } else if(yytext[1]=='a'){
    //     str_real.append(1u, '\a');
    // } else if(yytext[1]=='f'){
    //     str_real.append(1u, '\f');
    // } else if(yytext[1]=='r'){
    //     str_real.append(1u, '\r');
    // } else if(yytext[1]=='b'){
    //     str_real.append(1u, '\b');
    // }  else if(yytext[1]=='v'){
    //     str_real.append(1u, '\v');
    // } else if(yytext[1]=='0'){
    //     str_real.append(1u, '\0');
    // }  else if(yytext[1]=='\"'){
    //     str_real.append(1u, '\"');
    // }
}

<INSIDE_STRING_STATE>.  {
    // str_real.append(yytext);
    // str_lexeme.append(yytext);
}

{SINGLE_COMMENT}    {
    // fprintf(log_output, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, yytext);
    // for(int i=0; i<strlen(yytext); i++){
    //     if(yytext[i]=='\n'){
    //         line_count++;
    //     }
    // }
}

{MULTI_COMMENT} {
    // fprintf(log_output, "Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n", line_count, yytext);
    // for(int i=0; i<strlen(yytext); i++){
    //     if(yytext[i]=='\n'){
    //         line_count++;
    //     }
    // }
}

{NEWLINE} {line_count++;}

{ILL_FORMATION_ERROR}   {
    // fprintf(log_output, "Error at line no %d: Ill Formed Number %s\n\n",line_count, yytext);
    // total_errors++;
}

{DECIMAL_POINT_ERROR}   {
    // fprintf(log_output, "Error at line no %d: Too Many Decimal Points %s\n\n", line_count, yytext);
    // total_errors++;
}

{INVALID_SUFFIX_PREFIX_ERROR}   {
    // fprintf(log_output, "Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n", line_count, yytext);
    // total_errors++;
}

{MULTI_CHAR_CONST_ERROR}    {
    // fprintf(log_output, "Error at line no %d: Multi Character Constant Error %s\n\n", line_count, yytext);
    // total_errors++;
}

{UNFINISHED_COMMENT_ERROR}  {
    // fprintf(log_output, "Error at line no %d: Unterminated Comment %s\n\n", line_count, yytext);
    // total_errors++;
    // for(int i=0; i<strlen(yytext); i++){
    //     if(yytext[i]=='\n')
    //         line_count++;
    // }
}

{UNFINISHED_CHAR_ERROR} {
    // fprintf(log_output, "Error at line no %d: Unterminated Character %s\n\n", line_count, yytext);
    // total_errors++;
}

''  {
    // fprintf(log_output, "Error at line no %d: Empty Character Constant Error %s\n\n", line_count, yytext);
    // total_errors++;
}

.   {
    // fprintf(log_output, "Error at line no %d: Unrecognized Character %s\n\n", line_count, yytext);
    // total_errors++;
}

%%