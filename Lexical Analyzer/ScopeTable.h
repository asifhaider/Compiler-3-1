#include <bits/stdc++.h>
#include "SymbolInfo.h"

using namespace std;

class ScopeTable
{
private:
    int totalBuckets;
    int childScopeCount;
    SymbolInfo **hashTable;
    ScopeTable *parentScope;
    string ID;
public:
    ScopeTable(int n, string id);
    uint32_t computeHash(string symbol);
    bool insertSymbol(SymbolInfo *symbol, FILE *file);
    SymbolInfo *lookupSymbol(string symbol);
    bool deleteSymbol(string symbol);
    void printScopeTable(FILE *file);
    ~ScopeTable();

    int getTotalBuckets() const;
    ScopeTable *getParentScope() const;
    const string &getId() const;
    int getChildScopeCount() const;
    void setChildScopeCount(int childScopeCount);
    void setParentScope(ScopeTable *parentScope);
};

// Constructor 
ScopeTable::ScopeTable(int n, string id)
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
uint32_t ScopeTable::computeHash(string symbol)
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

bool ScopeTable::insertSymbol(SymbolInfo *symbol, FILE *file)
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
            fprintf(file, "%s already exists in current ScopeTable\n\n", const_cast <char*>(current->getSymbolName().c_str()));
            return false;
        }
        while(current->getNextSymbolPointer()!=nullptr)
        {
            if(current->getSymbolName() == symbol->getSymbolName())
            {
                cout << "This word already exists" << endl;
                cout << "< " << current->getSymbolName() << " : " << current->getSymbolType() << " > already exist in the currentScopeTable" << endl << endl;
                fprintf(file, "%s already exists in current ScopeTable\n\n", const_cast <char*>(current->getSymbolName().c_str()));
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

 SymbolInfo *ScopeTable::lookupSymbol(string symbol)
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

 bool ScopeTable::deleteSymbol(string symbol) {
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

 void ScopeTable::printScopeTable(FILE *file) {
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

ScopeTable::~ScopeTable(){
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

ScopeTable *ScopeTable::getParentScope() const {
    return this->parentScope;
}

int ScopeTable::getTotalBuckets() const {
    return totalBuckets;
}

const string &ScopeTable::getId() const {
    return ID;
}

int ScopeTable::getChildScopeCount() const {
    return childScopeCount;
}

void ScopeTable::setChildScopeCount(int childScopeCount) {
    ScopeTable::childScopeCount = childScopeCount;
}

void ScopeTable::setParentScope(ScopeTable *parentScope) {
    ScopeTable::parentScope = parentScope;
}
