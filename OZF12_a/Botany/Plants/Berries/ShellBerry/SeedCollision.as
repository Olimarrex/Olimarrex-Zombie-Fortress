#include "PlantCommon.as";
void onInit(CBlob@ this)
{	
	this.set_f32("hit dmg modifier", 4.5f);
	this.set_f32("map dmg modifier", 0.1f);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() && blob.hasTag("flesh") || blob.getName() == this.getName();
}