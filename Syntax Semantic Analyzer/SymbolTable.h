#pragma once
#include <bits/stdc++.h>

using namespace std;

class Parameter
{
private:
    string paramName;
    string paramType;
public:
    Parameter(string name, string type)
    {
        this->paramName = name;
        this->paramType = type;
    }

    string getParamType()
    {
        return this->paramType;
    }

    string getParamName()
    {
        return this->paramName;
    }
};

class SymbolInfo
{
private:
    string symbolName;
    string symbolType;
    SymbolInfo *nextSymbolPointer;

    int arraySize;  // array size tracker
    bool isFuncDefined;     // checking if the function is defined
    vector <Parameter> parameterList;     // tracking function parameters    

public:
    SymbolInfo() {
        this->symbolName = "";
        this->symbolType = "";
        this->arraySize = 0;
        this->nextSymbolPointer = nullptr;
        isFuncDefined = false; 
}

SymbolInfo(string name, string type)
{
    this->symbolName = name;
    this->symbolType = type;
    this->nextSymbolPointer = nullptr;
    this->isFuncDefined = false;
    this->arraySize = 0;
}

// Getter Setters
string getSymbolName()
{
    return this->symbolName;
}

string getSymbolType()
{
    return this->symbolType;
}

void setArraySize(int size)
{
    this->arraySize = size;
}

int getArraySize()
{
    return this->arraySize;
}

void setIsFuncDefined(bool defined)
{
    this->isFuncDefined = defined;
}

bool getIsFuncDefined()
{
    return this->isFuncDefined;
}

void setNextSymbolPointer(SymbolInfo *symbolInfo)
{
    this->nextSymbolPointer = symbolInfo;
}

SymbolInfo *getNextSymbolPointer()
{
    return this->nextSymbolPointer;
}

void saveArray(string name, string type, int size)
{
    this->symbolName = name;
    this->symbolType = type;
    this->arraySize = size;
    this->nextSymbolPointer = nullptr;
    this->isFuncDefined = false;
}

void saveFunction(string name, string type, vector<Parameter>parameterList)
{
    this->symbolName = name;
    this->symbolType = type;
    this->arraySize = -1;
    this->nextSymbolPointer = nullptr;
    this->parameterList = parameterList;
    this->isFuncDefined = false;

}

void addParameter(string name, string type)
{
    Parameter parameter(name, type);
    parameterList.push_back(parameter);
}

vector<Parameter> getParameterList()
{
    return this->parameterList;
}

bool isArray()
{
    return (arraySize > 0);
}

bool isVariable()
{
    return (arraySize == 0);
}

bool isFunction()
{
    return (arraySize == -1);
}

~SymbolInfo(){
    delete this->nextSymbolPointer;
 }
};




class ScopeTable
{
private:
    int totalBuckets;
    int childScopeCount;
    SymbolInfo **hashTable;
    ScopeTable *parentScope;
    string ID;
public:
    // Constructor 
ScopeTable(int n, string id)
{
    this->hashTable = new SymbolInfo* [n];
    for(int i=0; i<n; i++)
    {
        this->hashTable[i] = nullptr;
    }
    this->totalBuckets = n;
    this->parentScope = nullptr;
    this->ID = id;
    this->childScopeCount = 0;
    cout << "New ScopeTable with id  " << this->ID << " created"<< endl << endl;
}

// sdbm hash function
uint32_t computeHash(string symbol)
{
    uint32_t hashValue = 0;
    uint32_t c;
    for(uint32_t i=0; i<symbol.size(); i++)
    {
        c=symbol[i];
        hashValue = c + (hashValue << 6) + (hashValue << 16) - hashValue;
    }
    return hashValue%this->totalBuckets;
}

bool insertSymbol(SymbolInfo *symbol)
{
    uint32_t pos = this->computeHash(symbol->getSymbolName());
    int count = 0;
    if(this->hashTable[pos] == nullptr){
        this->hashTable[pos] = symbol;
        cout << "Inserted in ScopeTable# " << this->ID << " at position " << to_string(pos) << ", " << count << endl << endl;
        return true;
    } else{
        count++;
        SymbolInfo *current = this->hashTable[pos];
        if(current->getSymbolName() == symbol->getSymbolName())
        {
            cout << "This word already exists" << endl;
            cout << "< " << current->getSymbolName() << " : " << current->getSymbolType() << " > already exist in the currentScopeTable" << endl << endl;
            // // fprintf(, "%s already exists in current ScopeTable\n\n", const_cast <char*>(current->getSymbolName().c_str()));
            return false;
        }
        while(current->getNextSymbolPointer()!=nullptr)
        {
            if(current->getSymbolName() == symbol->getSymbolName())
            {
                cout << "This word already exists" << endl;
                cout << "< " << current->getSymbolName() << " : " << current->getSymbolType() << " > already exist in the currentScopeTable" << endl << endl;
                // // fprintf(, "%s already exists in current ScopeTable\n\n", const_cast <char*>(current->getSymbolName().c_str()));
                return false;
            }
            current = current->getNextSymbolPointer();
            count++;
        }
        current->setNextSymbolPointer(symbol);
        cout << "Inserted in ScopeTable# " << this->ID << " at position " << to_string(pos) << ", " << count << endl << endl;
        return true;
    }
}

 SymbolInfo *lookupSymbol(string symbol)
 {
     for(int i=0; i<this->totalBuckets; i++)
     {
         int count = 0;
         SymbolInfo *current = this->hashTable[i];
         while(current != nullptr)
         {
             if(current->getSymbolName() == symbol)
             {
                 cout << "Found in ScopeTable# " << this->ID <<  " at position " << i << ", " << count << endl << endl;
                 return current;
             }
             current = current->getNextSymbolPointer();
             count++;
         }
     }
     return nullptr;
 }

 bool deleteSymbol(string symbol) {
     if (this->lookupSymbol(symbol) == nullptr) {
         cout << "Not Found" << endl;
         return false;
     } else {
         cout << "Found it" << endl;
         for (int i = 0; i < this->totalBuckets; i++) {
             int count = 0;
             SymbolInfo *current = this->hashTable[i];

             // hashed position empty
             if(current== nullptr)
                 continue;

             // first element delete
             if(current->getSymbolName()==symbol){
                 this->hashTable[i] = current->getNextSymbolPointer();
                 delete current;
                 cout << "Deleted entry at position " << i << ", " << count
                      << " in the current ScopeTable" << endl << endl;
                 return true;
             } else {
                 count++;
                 SymbolInfo *next = current->getNextSymbolPointer();
                 while (next != nullptr) {
                     if (next->getSymbolName() == symbol) {
                         current->setNextSymbolPointer(next->getNextSymbolPointer());
                         cout << "Deleted entry at position " << i << ", " << count
                              << " in the current ScopeTable" << endl << endl;
                         delete next;
                         return true;
                     }
                     current = next;
                     next = current->getNextSymbolPointer();
                     count++;
                 }
                 delete next;
             }
         }
     return true;
     }
 }

 void printScopeTable(FILE *file) {
    cout << "ScopeTable# " << this->ID << endl << endl;
    fprintf(file, "ScopeTable# %s\n\n", const_cast<char*>(this->ID.c_str()));
    for(int i=0; i<this->totalBuckets; i++){
        SymbolInfo *current = this->hashTable[i];
        if(current!=nullptr){
            cout << i << " --> ";
            fprintf(file, "%d -->", i);
        } else 
            continue;
        while(current!= nullptr){
            
            cout << "< " << current->getSymbolName() << " : " << current->getSymbolType() << " >";
            fprintf(file, "< %s : %s >", const_cast<char*>(current->getSymbolName().c_str()), const_cast<char*>(current->getSymbolType().c_str()));
            current = current->getNextSymbolPointer();
        }
        cout << endl;
        fprintf(file, "%c", '\n');
    }
    cout << endl;
    fprintf(file, "%c", '\n');
}

~ScopeTable(){
    cout << "ScopeTable with id " << this->ID << " is removed" << endl;
    if(this->getId()=="1")
        cout << "Destroying the First Scope" << endl;
    cout << "Destroying the ScopeTable" << endl << endl;
    delete this->parentScope;
    for (int i=0; i<this->totalBuckets; i++){
        delete this->hashTable[i];
    }
    delete[] this->hashTable;
}

ScopeTable *getParentScope() const {
    return this->parentScope;
}

int getTotalBuckets() const {
    return totalBuckets;
}

const string &getId() const {
    return ID;
}

int getChildScopeCount() const {
    return childScopeCount;
}

void setChildScopeCount(int childScopeCount) {
    childScopeCount = childScopeCount;
}

void setParentScope(ScopeTable *parentScope) {
    parentScope = parentScope;
}
};





class SymbolTable
{
private:
    ScopeTable *currentScopeTable;
public:
SymbolTable(ScopeTable *scope) {
    this->currentScopeTable = scope;
}

ScopeTable *getCurrentScopeTable() const {
    return currentScopeTable;
}

bool insertSymbol(SymbolInfo *symbol) {
    return this->currentScopeTable->insertSymbol(symbol);
}

SymbolInfo *lookupSymbol(string symbol) {
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
void enterScope() {
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

void printCurrentScopeTable(FILE *file) {
    this->currentScopeTable->printScopeTable(file);
}

void printAllScopeTable(FILE *file) {
    ScopeTable *scope = this->currentScopeTable;
    while(scope->getParentScope()!= nullptr)
    {
        scope->printScopeTable(file);
        scope = scope->getParentScope();
    }
    scope->printScopeTable(file);
}

void exitScope() {
    ScopeTable *oldScope = this->currentScopeTable->getParentScope();
    currentScopeTable->setParentScope(nullptr);
    delete currentScopeTable;
    this->currentScopeTable = oldScope;
}

bool removeSymbol(string symbol) {
    bool isDeleted = this->currentScopeTable->deleteSymbol(symbol);
    if(!isDeleted)
        cout << symbol << " is not found" << endl << endl;
    return isDeleted;
}

~SymbolTable() {
    cout << "NO CURRENT SCOPE" << endl << endl;
    delete this->currentScopeTable;
}
};
