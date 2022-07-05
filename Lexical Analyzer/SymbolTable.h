#include "bits/stdc++.h"
#include "ScopeTable.h"

using namespace std;

class SymbolTable
{
private:
    ScopeTable *currentScopeTable;
public:
    SymbolTable(ScopeTable *scope);
    void enterScope();
    void exitScope();
    bool insertSymbol(SymbolInfo *symbol, FILE *file);
    SymbolInfo *lookupSymbol(string symbol);
    bool removeSymbol(string symbol);
    void printCurrentScopeTable(FILE *file);
    void printAllScopeTable(FILE *file);
    ~SymbolTable();

    ScopeTable *getCurrentScopeTable() const;
};

SymbolTable::SymbolTable(ScopeTable *scope) {
    this->currentScopeTable = scope;
}

ScopeTable *SymbolTable::getCurrentScopeTable() const {
    return currentScopeTable;
}

bool SymbolTable::insertSymbol(SymbolInfo *symbol, FILE *file) {
    return this->currentScopeTable->insertSymbol(symbol, file);
}

SymbolInfo *SymbolTable::lookupSymbol(string symbol) {
    ScopeTable *scope = currentScopeTable;
    SymbolInfo *foundSymbol = scope->lookupSymbol(symbol);
    while(foundSymbol==nullptr){
        scope = scope->getParentScope();
        if(scope == nullptr){
            cout << "Not Found" << endl << endl;
            return nullptr;
        }
        foundSymbol = scope->lookupSymbol(symbol);
    }
    return foundSymbol;
}

// increasing child scope count
void SymbolTable::enterScope() {
    if(this->currentScopeTable == nullptr){
        cout << "Create a new SymbolTable" << endl << endl;
        return;
    }
    this->currentScopeTable->setChildScopeCount(currentScopeTable->getChildScopeCount() + 1);
    string newID = this->currentScopeTable->getId() + "." + to_string(this->currentScopeTable->getChildScopeCount());
    ScopeTable *newScope = new ScopeTable(this->currentScopeTable->getTotalBuckets(), newID);
    newScope->setParentScope(this->currentScopeTable);
    this->currentScopeTable = newScope;
}

void SymbolTable::printCurrentScopeTable(FILE *file) {
    this->currentScopeTable->printScopeTable(file);
}

void SymbolTable::printAllScopeTable(FILE *file) {
    ScopeTable *scope = this->currentScopeTable;
    while(scope->getParentScope()!= nullptr)
    {
        scope->printScopeTable(file);
        scope = scope->getParentScope();
    }
    scope->printScopeTable(file);
}

void SymbolTable::exitScope() {
    ScopeTable *oldScope = this->currentScopeTable->getParentScope();
    currentScopeTable->setParentScope(nullptr);
    delete currentScopeTable;
    this->currentScopeTable = oldScope;
}

bool SymbolTable::removeSymbol(string symbol) {
    bool isDeleted = this->currentScopeTable->deleteSymbol(symbol);
    if(!isDeleted)
        cout << symbol << " is not found" << endl << endl;
    return isDeleted;
}

SymbolTable::~SymbolTable() {
    cout << "NO CURRENT SCOPE" << endl << endl;
    delete this->currentScopeTable;
}
