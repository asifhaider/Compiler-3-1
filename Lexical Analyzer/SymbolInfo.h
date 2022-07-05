#include <bits/stdc++.h>

using namespace std;

class SymbolInfo
{
private:
    string symbolName;
    string symbolType;
    SymbolInfo *nextSymbolPointer;

public:
    SymbolInfo();
    SymbolInfo(string name, string type);
    string getSymbolName();
    string getSymbolType();
    void setNextSymbolPointer(SymbolInfo *symbolInfo);
    SymbolInfo *getNextSymbolPointer();
    ~SymbolInfo();
};

SymbolInfo::SymbolInfo() {
}

SymbolInfo::SymbolInfo(string name, string type)
{
    this->symbolName = name;
    this->symbolType = type;
    this->nextSymbolPointer = nullptr;
}

// Getter Setters
string SymbolInfo::getSymbolName()
{
    return this->symbolName;
}

string SymbolInfo::getSymbolType()
{
    return this->symbolType;
}

void SymbolInfo::setNextSymbolPointer(SymbolInfo *symbolInfo)
{
    this->nextSymbolPointer = symbolInfo;
}

SymbolInfo *SymbolInfo::getNextSymbolPointer()
{
    return this->nextSymbolPointer;
}

SymbolInfo::~SymbolInfo(){
    delete this->nextSymbolPointer;
 }