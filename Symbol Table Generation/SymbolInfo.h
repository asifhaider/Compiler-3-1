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
    void setSymbolName(string name);
    string getSymbolName();
    void setSymbolType(string type);
    string getSymbolType();
    void setNextSymbolPointer(SymbolInfo *symbolInfo);
    SymbolInfo *getNextSymbolPointer();
};

// Constructor with null next
 SymbolInfo::SymbolInfo()
 {
     this->symbolName = "";
     this->symbolType = "";
     this->nextSymbolPointer = nullptr;
 }

SymbolInfo::SymbolInfo(string name, string type)
{
    this->symbolName = name;
    this->symbolType = type;
    this->nextSymbolPointer = nullptr;
}

// Getter Setters
void SymbolInfo::setSymbolName(string name)
{
    this->symbolName = name;
}

string SymbolInfo::getSymbolName()
{
    return this->symbolName;
}

void SymbolInfo::setSymbolType(string type)
{
    this->symbolType = type;
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