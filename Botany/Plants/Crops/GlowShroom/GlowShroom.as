// Bush logic

#include "PoisonCommon.as";
#include "PlantCommon.as";
#include "MakeBotanySeed.as";

void onInit(CBlob@ this)
{
	this.Tag("growsInDarkness");
	initPlant(this, plantIndex::glowshroom);
	this.SetLightRadius(20.0f * getStrength(this));
	this.SetLightColor(SColor(255, 18, 152, 255));
	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	if(this.hasTag("grown"))
	{
		this.SetLight(true);
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}