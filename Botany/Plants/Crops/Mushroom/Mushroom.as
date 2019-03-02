// Mushroom logic
#include "PlantCommon.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 3;
	this.Tag("growsInDarkness");
	
	initPlant(this, plantIndex::mushroom);
}