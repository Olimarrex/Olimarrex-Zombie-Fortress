#define SERVER_ONLY;
#include "zombies_Rules.as";

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}