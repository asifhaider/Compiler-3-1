%{
    #include "SymbolTable.h"
    #define bucketNo 30

    extern FILE *yyin;  // takes input from file
    FILE *file_input, *log_output, *error_output;

    ScopeTable *scopeTable = new ScopeTable(bucketNo, "1");
    SymbolTable *symbolTable = new SymbolTable(scopeTable);

    // shifted from lex file
    int line_count = 1;
    int error_count = 0;

    int yyparse(void);
    int yylex(void);
    
    void yyerror(const char *s)
    {
        fprintf(error_output, "Syntax error at line %d: \n%s\n\n", line_count, s);
    }

    // for checking with current return type
    string currentFuncReturnType = "error";

    vector<string> stringSplit(string line, char delimeter)
    {
        stringstream ss(line);
        vector<string>tokens;
        string dummy;

        while(getline(ss, dummy, delimeter)){
            tokens.push_back(dummy);
        }
        return tokens;
    }

    // function parameter extractor, first splits based on comma, then space
    vector<Parameter> parameterExtractor(string argument)
    {
        vector<Parameter>extracts;
        vector<string>paramTypeNames = stringSplit(argument, ',');
        vector<string> paramTypeName;

        for(string s:paramTypeNames)
        {
            paramTypeName = stringSplit(s, ' ');
            Parameter p(paramTypeName[1], paramTypeName[0]);
            extracts.push_back(p);
        }
        return extracts;
    }

    int arraySizeExtractor(string var)
    {
        stringstream ss(var);
        string token;

        while(getline(ss, token, '[')){}
        stringstream ss2(token);
        getline(ss2, token, ']');

        return stoi(token);
    }

    string arrayNameExtractor(string var)
    {
        stringstream ss(var);
        string token;

        getline(ss, token, '[');
        return token;
    }

%}

%union {
    SymbolInfo* symbolInfo;
}


%token IF ELSE FOR WHILE INT FLOAT VOID RETURN
%token INCOP DECOP ASSIGNOP NOT 
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON PRINTLN
%token <symbolInfo> ADDOP MULOP RELOP LOGICOP
%token <symbolInfo> ID CONST_INT CONST_FLOAT


%type <symbolInfo> start program unit 
%type <symbolInfo> var_declaration variable type_specifier declaration_list
%type <symbolInfo> arguments argument_list
%type <symbolInfo> parameter_list func_declaration func_definition
%type <symbolInfo> term factor expression
%type <symbolInfo> logic_expression rel_expression simple_expression unary_expression 
%type <symbolInfo> statement statements compound_statement expression_statement 


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%


// start 

start : program
{
    $$ = $1;
    fprintf(log_output, "Line %d: start : program\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
}

// program 

program : program unit
{
    $$ = new SymbolInfo($1->getSymbolName() + "\n" + $2->getSymbolName(),"program");
    fprintf(log_output, "Line %d: program : program unit\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
} | unit 
{
    $$ = $1;
    fprintf(log_output, "Line %d: program : unit\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
};



// unit 

unit : var_declaration
{
    $$ = $1;
    fprintf(log_output, "Line %d: unit : var_declaration\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());    
} | func_declaration
{
    $$ = $1;
    fprintf(log_output, "Line %d: unit : func_declaration\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
} | func_definition 
{
    $$ = $1;
    fprintf(log_output, "Line %d: unit : func_definition\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
};


// function declaration

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
{
    string functionType = $1->getSymbolName();
    string functionName = $2->getSymbolName();

    vector<Parameter> parameterList = parameterExtractor($4->getSymbolName());
    
    SymbolInfo* currentFunction = symbolTable->lookupSymbol(functionName);


    if(currentFunction != nullptr)  // already declared before in this name
    {
        error_count++;
        string error_msg = "Multiple declaration of " + functionName;
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

    } else // not already declared 
    {
        // vector<Parameter> parameterList;
        // for(string pt:parameterTypes)
        // {
        //     parameterList.push_back(Parameter(" ", ))
        // }

        SymbolInfo *syminfo = new SymbolInfo();
        syminfo->saveFunction(functionName, functionType, parameterList);
        symbolTable->insertSymbol(syminfo);        
    }

    $$ = new SymbolInfo($1->getSymbolName() + " " + $2->getSymbolName() + "(" + $4->getSymbolName() + ");", "func_declaration");
    fprintf(log_output, "Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str()); 
} | type_specifier ID LPAREN RPAREN SEMICOLON
{
    string functionType = $1->getSymbolName();
    string functionName = $2->getSymbolName();
    
    SymbolInfo* currentFunction = symbolTable->lookupSymbol(functionName);

    if(currentFunction != nullptr)  // already declared before in this name
    {
        error_count++;
        string error_msg = "Multiple declaration of " + functionName;
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

    } else // not already declared 
    {
    
        vector<Parameter> parameterList;
        SymbolInfo *syminfo = new SymbolInfo();
        syminfo->saveFunction(functionName, functionType, parameterList);
        symbolTable->insertSymbol(syminfo);        
    }

    $$ = new SymbolInfo($1->getSymbolName() + " " + $2->getSymbolName() + "();", "func_declaration");
    fprintf(log_output, "Line %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
};



// function definition

func_definition : type_specifier ID LPAREN parameter_list RPAREN
{
    string functionType = $1->getSymbolName();
    string functionName = $2->getSymbolName();

    vector<Parameter> parameterList = parameterExtractor($4->getSymbolName());
    
    SymbolInfo* currentFunction = symbolTable->lookupSymbol(functionName);

    // check if declared 

    if(currentFunction!=nullptr)
    {
        if(currentFunction->isFunction())
        {
            if(currentFunction->getIsFuncDefined())
            {
                // error of function re-definition
            }
            else 
            {
                // declared but not defined 
                bool isDefinitionConsistent = true;
                int declaredParameterSize = currentFunction->getParameterList().size();
                int definedParameterSize = parameterList.size();

                if(declaredParameterSize != definedParameterSize)
                {
                    // declaration and definition mismatch
                    isDefinitionConsistent = false;
                    error_count++;
                    string error_msg = "Total number of arguments mismatch with declaration in function " + functionName;
                    fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

                }

                string declaredType = currentFunction->getSymbolType();
                if(declaredType != functionType)
                {
                    // declaration and definition return type mismatch
                    isDefinitionConsistent = false;
                    error_count++;
                    string error_msg = "Return type mismatch with function declaration in function " + functionName;
                    fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str()); 
                }

                
                // more error, function parameter type mismatch

                // deleting the function declaration and entering new scope with saving the function definition
                symbolTable->removeSymbol(functionName);

                SymbolInfo *syminfo = new SymbolInfo();
                syminfo->saveFunction(functionName, functionType, parameterList);
                syminfo->setIsFuncDefined(true);

                symbolTable->insertSymbol(syminfo);

                symbolTable->enterScope();

                bool multipleParamError = false;
                for(int i=0; i<parameterList.size(); i++)
                {
                    // paramInserted = symbolTable->insertSymbol(parameterList[i].getParamName(), parameterList[i].getParamType());
                    for(int j=0; j<parameterList.size(); j++)
                    {
                        if(i==j)continue;
                        else
                        {
                            if(parameterList[i].getParamName()==parameterList[j].getParamName())
                            {
                                error_count++;
                                string error_msg = "Multiple declaration of " + functionName + " in parameter";
                                fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
                                multipleParamError = true;
                                break;
                            }
                        }
                    }
                    if(multipleParamError)
                        break;
                }
            }

        }    
        else 
        {
            // error?
        }
    }
    else 
    {
        // function not declared yet
        SymbolInfo *syminfo = new SymbolInfo();
        syminfo->saveFunction(functionName, functionType, parameterList);
        syminfo->setIsFuncDefined(true);

        symbolTable->insertSymbol(syminfo);

        symbolTable->enterScope();

        bool multipleParamError = false;
        for(int i=0; i<parameterList.size(); i++)
        {
            // paramInserted = symbolTable->insertSymbol(parameterList[i].getParamName(), parameterList[i].getParamType());
            for(int j=0; j<parameterList.size(); j++)
            {
                if(i==j)continue;
                else
                {
                    if(parameterList[i].getParamName()==parameterList[j].getParamName())
                    {
                        error_count++;
                        string error_msg = "Multiple declaration of " + functionName + " in parameter";
                        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
                        multipleParamError = true;
                        break;
                    }
                }
            }
            if(multipleParamError)
                break;
        }

    }

} compound_statement 
{
    $$ = new SymbolInfo($1->getSymbolName() + " " + $2->getSymbolName() + "(" + $4->getSymbolName() + ")" + $7->getSymbolName() + "\n", "func_definition");
    fprintf(log_output, "Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n", line_count);
    fprintf(log_output,"\n%s\n\n", $2->getSymbolName().c_str());

}
| type_specifier ID LPAREN RPAREN
{
    string functionType = $1->getSymbolName();
    string functionName = $2->getSymbolName();
    
    SymbolInfo* currentFunction = symbolTable->lookupSymbol(functionName);

    // check if declared

    if(currentFunction != nullptr)
    {
        if(currentFunction->getIsFuncDefined())
            {
                // error of function re-definition
            }
            else 
            {
                // declared but not defined 
                bool isDefinitionConsistent = true;
                int declaredParameterSize = currentFunction->getParameterList().size();
                int definedParameterSize = 0;

                if(declaredParameterSize != definedParameterSize)
                {
                    // declaration and definition mismatch
                    isDefinitionConsistent = false;
                    error_count++;
                    string error_msg = "Total number of arguments mismatch with declaration in function " + functionName;
                    fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

                }

                string declaredType = currentFunction->getSymbolType();
                
                if(declaredType != functionType)
                {
                    // declaration and definition return type mismatch
                    isDefinitionConsistent = false;
                    error_count++;
                    string error_msg = "Return type mismatch with function declaration in function " + functionName;
                    fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str()); 
                }

                if(isDefinitionConsistent)
                {
                    symbolTable->removeSymbol(functionName);
                    SymbolInfo *syminfo = new SymbolInfo();
                    vector<Parameter>parameterList;

                    syminfo->saveFunction(functionName, functionType, parameterList);
                    syminfo->setIsFuncDefined(true);

                    symbolTable->insertSymbol(syminfo);
                }
            }
    } else
    {
        SymbolInfo *syminfo = new SymbolInfo();
        vector<Parameter>parameterList;

        syminfo->saveFunction(functionName, functionType, parameterList);
        syminfo->setIsFuncDefined(true);

        symbolTable->insertSymbol(syminfo);
    }

    symbolTable->enterScope();
}
compound_statement
{
    $$ = new SymbolInfo($1->getSymbolName() + " " + $2->getSymbolName() + "()" + $6->getSymbolName() + "\n", "func_definition");
    fprintf(log_output, "Line %d: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n", line_count);
    fprintf(log_output,"\n%s\n\n", $2->getSymbolName().c_str());
};



// parameter list

parameter_list : parameter_list COMMA type_specifier ID 
{
    $$ = new SymbolInfo($1->getSymbolName() + "," + $3->getSymbolName() + " " + $4->getSymbolName(), "parameter_list");
    fprintf(log_output, "Line %d: parameter_list : parameter_list COMMA type_specifier ID\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
} | parameter_list COMMA type_specifier
{
    $$ = new SymbolInfo($1->getSymbolName() + "," + $3->getSymbolName(), "parameter_list");
    fprintf(log_output, "Line %d: parameter_list : parameter_list COMMA type_specifier\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
} | type_specifier ID
{
    $$ = new SymbolInfo($1->getSymbolName() + " " + $2->getSymbolName(), "parameter_list");
    fprintf(log_output, "Line %d: parameter_list : type_specifier ID\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());    
} | type_specifier
{
    $$ = $1;
    fprintf(log_output, "Line %d: parameter_list : type_specifier\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
};


// compound statement 

compound_statement : LCURL statements RCURL
{
    $$ = new SymbolInfo("{\n" + $2->getSymbolName() + "\n}", "compound_statement");
    fprintf(log_output, "Line %d: compound_statement : LCURL statements RCURL\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());

    // prints all scopes and exits the current scope after curly brace ends
    symbolTable->printAllScopeTable(log_output);
    symbolTable->exitScope();
} | LCURL RCURL
{
    $$ = new SymbolInfo("{\n}", "compound_statement");
    fprintf(log_output, "Line %d: compound_statement : LCURL RCURL\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
};


// variable declaration

var_declaration : type_specifier declaration_list SEMICOLON
{
    string var_type = $1->getSymbolType();
    string var_name = $2->getSymbolName();

    // variable can't be a void type
    if(var_type == "void")
    {
        error_count++;
        string error_msg = "Variable type cannot be void";
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

    } else 
    {
        vector <string> variable_names = stringSplit(var_name, ',');
        for (string v:variable_names)
        {
            // variable or array variable 
            SymbolInfo *syminfo;

            if((v.find("[")!=string::npos) || (v.find("]")!=string::npos))
            {
                // array variable found
                int array_len = arraySizeExtractor(v);
                string array_name = arrayNameExtractor(v);
                syminfo->saveArray(array_name, var_type, array_len);

            } else 
            {
                // variable found
                syminfo = new SymbolInfo(v, var_type);
            }

            // while inserting into symbol table, check if variable declaration already exists
            if(!symbolTable->insertSymbol(syminfo))
            {
                error_count++;
                string error_msg = "Multiple declaration of" + syminfo->getSymbolName();
                fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

            }
        }
    }
    $$ = new SymbolInfo($1->getSymbolName() + " " + $2->getSymbolName() + ";", "var_declaration");
    fprintf(log_output, "Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str()); 

}

// type specifier

type_specifier : INT 
{
    $$ = new SymbolInfo("int", "int");
    fprintf(log_output, "Line %d: type_specifier : INT\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
} | FLOAT 
{
    $$ = new SymbolInfo("float", "int");
    fprintf(log_output, "Line %d: type_specifier : FLOAT\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
} | VOID 
{
    $$ = new SymbolInfo("void", "void");
    fprintf(log_output, "Line %d: type_specifier : VOID\n", line_count);
    fprintf(log_output,"\n%s\n\n", $$->getSymbolName().c_str());
};


// declaration list
declaration_list : declaration_list COMMA ID
{
    $$ = new SymbolInfo($1->getSymbolName() + "," + $3->getSymbolName(), "declaration_list");
    fprintf(log_output, "Line %d: declaration_list : declaration_list COMMA ID\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
{
    $$ = new SymbolInfo($1->getSymbolName() + "," + $3->getSymbolName() + "[" + $5->getSymbolName() + "]", "declaration_list");
    fprintf(log_output, "Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | ID 
{
    $$ = $1;
    fprintf(log_output, "Line %d: declaration_list : ID\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | ID LTHIRD CONST_INT RTHIRD
{
    $$ = new SymbolInfo($1->getSymbolName() + "[" + $3->getSymbolName() + "]", "declaration_list");
    fprintf(log_output, "Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};


// statements 

statements : statement
{
    $$ = $1;
    fprintf(log_output, "Line %d: statements : statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | statements statement
{
    $$ = new SymbolInfo($1->getSymbolName() + "\n" + $2->getSymbolName(), "statements");
    fprintf(log_output, "Line %d: statements : statements statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};

// statement 

statement : var_declaration
{
    $$ = $1;
    fprintf(log_output, "Line %d: statement : var_declaration\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | expression_statement
{
    $$ = $1;
    fprintf(log_output, "Line %d: statement : expression_statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | {symbolTable->enterScope();} compound_statement
{
    $$ = $2;
    fprintf(log_output, "Line %d: statement : compound_statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | FOR LPAREN expression_statement expression_statement expression RPAREN statement
{
    $$ = new SymbolInfo("for(" + $3->getSymbolName() + $4->getSymbolName() + $5->getSymbolName() + ")" + $7->getSymbolName(), "statement");
    fprintf(log_output, "Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
{
    $$ = new SymbolInfo("if(" + $3->getSymbolName() + ")" + $5->getSymbolName(), "statement");
    fprintf(log_output, "Line %d: statement : IF LPAREN expression RPAREN statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | IF LPAREN expression RPAREN statement ELSE statement
{
    $$ = new SymbolInfo("if(" + $3->getSymbolName() + ")" + $5->getSymbolName() + "else" + $7->getSymbolName(), "statement");
    fprintf(log_output, "Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | WHILE LPAREN expression RPAREN statement
{
    $$ = new SymbolInfo("while(" + $3->getSymbolName() + ")" + $5->getSymbolName(), "statement");
    fprintf(log_output, "Line %d: statement : WHILE LPAREN expression RPAREN statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | PRINTLN LPAREN ID RPAREN statement
{
    // checking if it is declared before or not

    string name = $3->getSymbolName();
    SymbolInfo* symbol = symbolTable->lookupSymbol(name);

    if(symbol == nullptr)
    {
        // not found to be declared before 
        error_count++;
        string error_msg = "Undeclared variable" + symbol->getSymbolName();
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

        // any more error?
    }

    $$ = new SymbolInfo("printf(" + $3->getSymbolName() + ")", "statement");
    fprintf(log_output, "Line %d: statement : PRINTLN LPAREN ID RPAREN statement\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | RETURN expression SEMICOLON
{
    /// why symbol name
    string currentReturnType = $2->getSymbolName();

    // return void error handled, but is it needed?

    if(currentFuncReturnType == "void"){
        error_count++;
        string error_msg = "Function type void can't have a return statement";
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
        currentFuncReturnType = "error";
    }

    // there might be more errors related to return type

    $$ = new SymbolInfo("return " + $2->getSymbolName() + ";", "statement");
    fprintf(log_output, "Line %d: statement : RETURN expression SEMICOLON\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());

};



// expression statement 

expression_statement : SEMICOLON
{
    $$ = new SymbolInfo(";", "SEMICOLON");
} | expression SEMICOLON
{
    $$ = new SymbolInfo($1->getSymbolName() + ";", "expression_statement");
    fprintf(log_output, "Line %d: expression_statement : expression SEMICOLON\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};


// variable 

variable : ID
{
    string returnType;

    SymbolInfo* symbol = symbolTable->lookupSymbol($1->getSymbolName());
    
    if(symbol == nullptr)
    {
        // not found to be declared before 
        error_count++;
        string error_msg = "Undeclared variable" + $1->getSymbolName();
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
        $$ = new SymbolInfo($1->getSymbolName(), "error");
    } else 
    {
        // variable type matching (array or not)
        if(symbol->isArray())
        {
            $$ = new SymbolInfo();
            $$->saveArray(symbol->getSymbolName(), "error", symbol->getArraySize());
        } else 
        {
            // no change, ID is variable
            $$ = new SymbolInfo(symbol->getSymbolName(), symbol->getSymbolType());
        }
    }

    fprintf(log_output, "Line %d: variable : ID\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());

} | ID LTHIRD expression RTHIRD
{

    SymbolInfo* symbol = symbolTable->lookupSymbol($1->getSymbolName());
    
    if(symbol == nullptr)
    {
        // not found to be declared before 
        error_count++;
        string error_msg = "Undeclared variable" + $1->getSymbolName();
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

        $$ = new SymbolInfo($1->getSymbolName() + "[" + $3->getSymbolName() + "]", "error");
    } else 
    {
        // variable type matching (array or not)
        if(symbol->isArray())
        {
            // testing array index type
            if($3->getSymbolType()!="int")
            {
                // array index mismatch
                error_count++;
                string error_msg = "Expression inside third brackets not an integer";
                fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
            }
            $$ = new SymbolInfo($1->getSymbolName() + "[" + $3->getSymbolName() + "]", symbol->getSymbolType());
        } else 
        {
            // found variable, but it is an array 
            error_count++;
            string error_msg = "Type mismatch, " + symbol->getSymbolName() + " is an array";
            fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
            
            $$ = new SymbolInfo($1->getSymbolName() + "[" + $3->getSymbolName() + "]", "error");
        }
    }
    
    fprintf(log_output, "Line %d: variable : ID LTHIRD expression RTHIRD\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};

// expression

expression : logic_expression
{
    $$ = $1;
    fprintf(log_output, "Line %d: expression : logic_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());

} | variable ASSIGNOP expression
{
    // type checking

    SymbolInfo* leftElement = $1;
    SymbolInfo* rightElement = $3;

    if(leftElement->getSymbolType() == rightElement->getSymbolType())
    {

    } else    
    {    
        if(leftElement->getSymbolType() == "error" || rightElement->getSymbolType() == "error")
        {
            // checking if it is array
            
            if(leftElement->isArray() || rightElement->isArray())
            {
                string error_msg;
                if(leftElement->isArray())
                    error_msg = "Type mismatch, " + leftElement->getSymbolName() + " is an array";
                else if (rightElement->isArray())
                    error_msg = "Type mismatch, " + rightElement->getSymbolName() + " is an array";

                error_count ++ ;
                fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
            }
        }
    
    else if(leftElement->getSymbolType() == "float" && rightElement->getSymbolType()=="int")
    {
        // automatic type conversion from int to float
    } else 
    {
        // check later

        error_count++;
        string error_msg = "Type mismatch";
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

    }
    }

    $$ = new SymbolInfo($1->getSymbolName() + "=" + $3->getSymbolName(), "expression");
    fprintf(log_output, "Line %d: expression : variable ASSIGNOP expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};



// logical expression


logic_expression : rel_expression
{
    $$ = $1;
    fprintf(log_output, "Line %d: logic_expression : rel_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());

} | rel_expression LOGICOP rel_expression
{
    //// ERROR

    string logicExpressionType = "int";

    string leftType = $1->getSymbolType();
    string rightType = $3->getSymbolType();

    if((leftType != "int") || (rightType != "int"))
    {
        error_count++;
        string error_msg = "Non-Integer operand on logical/relational operator";
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

        logicExpressionType = "error";
    }

    $$ = new SymbolInfo($1->getSymbolName() + $2->getSymbolName() + $3->getSymbolName(), logicExpressionType);
    fprintf(log_output, "Line %d: rel_expression : rel_expression LOGICOP rel_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};


// relational expression

rel_expression : simple_expression
{
    $$ = $1;
    fprintf(log_output, "Line %d: rel_expression : simple_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | simple_expression RELOP simple_expression
{
    // int how and why?
    $$ = new SymbolInfo($1->getSymbolName() + $2->getSymbolName() + $3->getSymbolName(), "int");
    fprintf(log_output, "Line %d: rel_expression : simple_expression RELOP simple_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};


// simple expression

simple_expression : term 
{
    $$ = $1;
    fprintf(log_output, "Line %d: simple_expression : term\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | simple_expression ADDOP term
{
    string expressionType = "int";
    if(($1->getSymbolType() == "float") || ($3->getSymbolType()=="float"))
    {
        expressionType = "float";
    }
    $$ = new SymbolInfo($1->getSymbolName() + $2->getSymbolName() + $3->getSymbolName(), expressionType);
    fprintf(log_output, "Line %d: simple_expression : simple_expression ADDOP term\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};


// term

term : unary_expression
{
    $$ = $1;
    fprintf(log_output, "Line %d: term : unary_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | term MULOP unary_expression
{

    string leftType = $1->getSymbolType();
    string operatorType = $2->getSymbolName();
    string rightType = $3->getSymbolType();

    string returnType = "error";

    // modulus operator type checking

    if(operatorType == "%")
    {
        if(leftType != "int" || rightType != "int")
        {
            error_count++;
            string error_msg = "Non-Integer operand on modulus operator";
            fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());

            returnType = "error";

        } else 
        {
            // modulus by zero check
            string rightName = $3->getSymbolName();
            if(rightName == "0")
            {
                error_count++;
                string error_msg = "Modulus by Zero";
                fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());      
            }
            
            returnType = "int";
        }
    } else if (operatorType == "*" || operatorType == "/")
    {
        if(leftType == "float" || rightType == "float")
            returnType = "float";
        else 
            returnType = "int";
        
        // divided by zero error?
        if(operatorType == "/")
        {
            
        }
    } else 
    {
        returnType = "undeclared";
    }

    $$ = new SymbolInfo($1->getSymbolName() + $2->getSymbolName() + $3->getSymbolName(), returnType);
    fprintf(log_output, "Line %d: term : term MULOP unary_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};

// unary expression

unary_expression : ADDOP unary_expression
{
    $$ = new SymbolInfo($1->getSymbolName() + $2->getSymbolName(), $2->getSymbolType());
    fprintf(log_output, "Line %d: unary_expression : ADDOP unary_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | NOT unary_expression
{
    /// check later for error 
    $$ = new SymbolInfo("!" + $2->getSymbolName(), $2->getSymbolType());
    fprintf(log_output, "Line %d: unary_expression : NOT unary_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | factor
{
    $$ = $1;
    fprintf(log_output, "Line %d: unary_expression : factor\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};




// factor

factor : variable
{
    $$ = $1;
    fprintf(log_output, "Line %d: factor : variable\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());

} | ID LPAREN argument_list RPAREN
{
    // ERROR

    string returnType = "undeclared";

    SymbolInfo *symbol = symbolTable->lookupSymbol($1->getSymbolName());

    if(symbol == nullptr)
    {
        // not found to be declared before 
        error_count++;
        string error_msg = "Undeclared function" + $1->getSymbolName();
        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
    } else 
    {
        // further checking might be needed

        if(symbol->isFunction())
        {
            returnType = symbol->getSymbolType();
            string argument_name_string = $3->getSymbolName();
            string argument_type_string = $3->getSymbolType();

            vector<string> argument_names = stringSplit(argument_name_string, ',');
            vector<string> argument_types = stringSplit(argument_type_string, ',');

            vector<Parameter> parameter_list = symbol->getParameterList();

            // return type void checking?

            // no of argument matching

            if(returnType == "void")
            {
                error_count++;
				string error_msg = "Void function can't be used as factor";
                fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
            }

            else if(parameter_list.size() != argument_names.size())
            {
                error_count++;
                string error_msg = "Total number of arguments mismatch in function" + symbol->getSymbolName();
                fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
            } else 
            {
                // each argument type checking
                for(int i=0; i<argument_names.size(); i++)
                {
                    if(argument_types[i]!=parameter_list[i].getParamType())
                    {
                        // argument type mismatch
                        error_count++;
                        string error_msg = i +  "th argument mismatch in function" + symbol->getSymbolName();
                        fprintf(error_output, "Error at line %d: %s\n", line_count, error_msg.c_str());
                    }
                }
            }
        }

        // might be some more error
    }

    $$ = new SymbolInfo($1->getSymbolName() + "(" + $3->getSymbolName() + ")", returnType);
    fprintf(log_output, "Line %d: factor : ID LPAREN argument_list RPAREN\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | LPAREN expression RPAREN
{
    $$ = new SymbolInfo("(" + $2->getSymbolName() + ")", $2->getSymbolType());
    fprintf(log_output, "Line %d: factor : LPAREN expression RPAREN\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | CONST_INT
{
    $$ = yylval.symbolInfo;
    fprintf(log_output, "Line %d: factor : CONST_INT\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | CONST_FLOAT
{
    $$ = yylval.symbolInfo;
    fprintf(log_output, "Line %d: factor : CONST_FLOAT\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | variable INCOP
{
    $$ = new SymbolInfo($1->getSymbolName() + "++", $1->getSymbolType());
    fprintf(log_output, "Line %d: factor : variable INCOP\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | variable DECOP
{
    $$ = new SymbolInfo($1->getSymbolName() + "++", $1->getSymbolType());
    fprintf(log_output, "Line %d: factor : variable DECOP\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};


// argument list

argument_list : arguments
{
    $$ = $1;
    fprintf(log_output, "Line %d: argument_list : arguments\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
} | 
{
    $$ = new SymbolInfo("", "void");
    fprintf(log_output, "Line %d: argument_list : \n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};


// arguments 

arguments : arguments COMMA logic_expression
{
    string argument_names = $1->getSymbolName() + "," + $3->getSymbolName();
    string argument_types = $1->getSymbolType() + "," + $3->getSymbolType();

    $$ = new SymbolInfo(argument_names, argument_types);
    fprintf(log_output, "Line %d: arguments : arguments COMMA logic_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());

} | logic_expression
{
    $$ = $1;
    fprintf(log_output, "Line %d: arguments : logic_expression\n", line_count);
    fprintf(log_output, "\n%s\n\n", $$->getSymbolName().c_str());
};

%%

int main(int argc, char *argv[])    /* Sub Routine Section */
{
    if(argc!=2){
        printf("Please provide input file name and try again\n");
        return 0;
    }

    file_input = fopen(argv[1], "r");
    if(file_input==NULL){
        printf("Cannot open specified file\n");
        return 0;
    }

    log_output = fopen("1805112_log.txt", "w");
    error_output = fopen("1805112_error.txt", "w");

    yyin = file_input;
    yyparse();
    

    fclose(yyin);
    fclose(error_output);
    fclose(log_output);
    return 0;
}