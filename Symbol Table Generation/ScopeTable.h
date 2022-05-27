#include <bits/stdc++.h>
#include "SymbolInfo.h"

using namespace std;

class ScopeTable
{
private:
    int totalBuckets;
    int childScopeCount;
    SymbolInfo *hashTable;
    ScopeTable *parentScope;
    string ID;
public:
    ScopeTable(int n, string id);
    uint32_t computeHash(string symbol);
    bool insertSymbol(SymbolInfo *symbol);
    SymbolInfo *lookupSymbol(string symbol);
    bool deleteSymbol(string symbol);
    void printScopeTable();
    ScopeTable *getParentScope() const;
    ~ScopeTable();

    int getTotalBuckets() const;

    const string &getId() const;

    int getChildScopeCount() const;

    void setChildScopeCount(int childScopeCount);

    void setParentScope(ScopeTable *parentScope);
};

// Constructor 
ScopeTable::ScopeTable(int n, string id)
{
    this->hashTable = new SymbolInfo[n];
    this->totalBuckets = n;
    this->parentScope = nullptr;
    this->ID = id;
    this->childScopeCount = 0;
    cout << "New ScopeTable with id  " << this->ID << " created"<< endl << endl;
}

// sdbm hash function
uint32_t ScopeTable::computeHash(string symbol)
{
    unsigned long hashValue = 0;
    int c;
    for(int i=0; i<symbol.size(); i++)
    {
        c=symbol[i];
        hashValue = c + (hashValue << 6) + (hashValue << 16) - hashValue;
    }
    return hashValue%this->totalBuckets;
}

bool ScopeTable::insertSymbol(SymbolInfo *symbol)
{
    uint32_t pos = this->computeHash(symbol->getSymbolName());
    int count = 0;
    SymbolInfo *current = this->hashTable[pos].getNextSymbolPointer();
    if(current == nullptr){
        this->hashTable[pos].setNextSymbolPointer(symbol);
        cout << "Inserted in ScopeTable# " << this->ID << " at position " << to_string(pos) << ", " << count << endl << endl;
        return true;
    } else{
        count++;
        if(current->getSymbolName() == symbol->getSymbolName())
        {
            cout << "This word already exists" << endl;
            cout << "< " << current->getSymbolName() << " : " << current->getSymbolType() << " > already exist in the currentScopeTable" << endl << endl;
            return false;
        }
        while(current->getNextSymbolPointer()!=nullptr)
        {
            if(current->getSymbolName() == symbol->getSymbolName())
            {
                cout << "This word already exists" << endl;
                cout << "< " << current->getSymbolName() << " : " << current->getSymbolType() << " > already exist in the currentScopeTable" << endl << endl;
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
         SymbolInfo *current = this->hashTable[i].getNextSymbolPointer();
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
             SymbolInfo *next = this->hashTable[i].getNextSymbolPointer();

             // hashed position empty
             if(next== nullptr)
                 continue;

             SymbolInfo *current = new SymbolInfo;
             if(next->getSymbolName()==symbol){
                 this->hashTable[i].setNextSymbolPointer(nullptr);
             } else {
                 while (next->getSymbolName() != symbol) {
                     current = next;
                     next = current->getNextSymbolPointer();
                     count ++ ;
                     if (next == nullptr) {
                         break;
                     }
                 }
                 if(next== nullptr)
                     continue;
                 else{
                     current->setNextSymbolPointer(next->getNextSymbolPointer());
                     delete next;
                     cout << "Deleted entry at position " << i << ", " << count
                          << " in the current ScopeTable" << endl << endl;
                     return true;
                 }
             }
             current->setNextSymbolPointer(next->getNextSymbolPointer());
             delete next;
             cout << "Deleted entry at position " << i << ", " << count
                  << " in the current ScopeTable" << endl << endl;
             return true;
         }
     }
 }

 void ScopeTable::printScopeTable() {
    cout << "ScopeTable# " << this->ID << endl << endl;
    for(int i=0; i<this->totalBuckets; i++){
        cout << i << " --> ";
        SymbolInfo *current = this->hashTable[i].getNextSymbolPointer();
        while(current!= nullptr){
            cout << "< " << current->getSymbolName() << " : " << current->getSymbolType() << " >";
            current = current->getNextSymbolPointer();
        }
        cout << endl;
    }
    cout << endl;
}

ScopeTable::~ScopeTable(){
    cout << "ScopeTable with id " << this->ID << " is removed" << endl;
    if(this->getId()=="1")
        cout << "Destroying the First Scope" << endl;
    cout << "Destroying the ScopeTable" << endl << endl;
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
