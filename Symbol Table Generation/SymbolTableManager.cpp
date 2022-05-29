/*
 * Compiler Offline 1: Symbol Table Generation
 * Author: Md. Asif Haider
 * Date: 29 May 2022
 */

#include <bits/stdc++.h>
#include "SymbolTable.h"

using namespace std;

int main()
{
    // file input, and bucket no. input
    ifstream f;
    int bucketNo;
    f.open("E:\\Local Repository\\Compiler-3-1\\Symbol Table Generation\\input.txt");
    if(!f){
        cout << "Error opening the input file" << endl;
        exit(1);
    }
    f >> bucketNo;

    // creating root scope and the single symbol table
    ScopeTable *scopeTable = new ScopeTable(bucketNo, "1");
    SymbolTable *symbolTable = new SymbolTable(scopeTable);

    char sentences[1000];
    while(!f.eof()) {
        // string *sentence;
        f.getline(sentences, 100);
        char *sentence = strtok(sentences, "\r\n");
        while (sentence != nullptr) {
            char *word = strtok(sentence, " ");

            if (*word == 'I') {
                word = strtok(nullptr, " ");
                string s1 = word;
                word = strtok(nullptr, " ");
                string s2 = word;
                if (symbolTable == nullptr) {
                    symbolTable = new SymbolTable(new ScopeTable(bucketNo, "1"));
                }
                SymbolInfo *symbol = new SymbolInfo(s1, s2);
                if (!symbolTable->insertSymbol(symbol)) {
                    delete symbol;
                };
            } else if (*word == 'L') {
                word = strtok(nullptr, " ");
                string s = word;
                symbolTable->lookupSymbol(s);
            } else if (*word == 'D') {
                word = strtok(nullptr, " ");
                string s = word;
                symbolTable->removeSymbol(s);
            } else if (*word == 'P') {
                word = strtok(nullptr, " ");
                if (*word == 'A') {
                    symbolTable->printAllScopeTable();
                } else if (*word == 'C') {
                    symbolTable->printCurrentScopeTable();
                }
            } else if (*word == 'S') {
                if (symbolTable == nullptr) {
                    delete symbolTable;
                    symbolTable = nullptr;
                } else
                    symbolTable->enterScope();
            } else if (*word == 'E') {
                if (symbolTable == nullptr) {
                    delete symbolTable;
                    symbolTable = nullptr;
                } else if (symbolTable->getCurrentScopeTable() == nullptr) {
                    delete symbolTable;
                    symbolTable = nullptr;
                } else
                    symbolTable->exitScope();
            } else
                cout << "Wrong keyword encountered" << endl << endl;
            sentence = strtok(nullptr, "\n");
        }
    }
    // delete symbolTable;
    return 0;
}