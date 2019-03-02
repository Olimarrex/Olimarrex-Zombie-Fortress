#include "PoisonCommon.as";
#include "PoisonPotionCommon.as";
#include "PotionCommon.as";
void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	f32 strength = getPotionStrength(this, potionIndex::toxic);
	print("dis happen");
	if(getNet().isServer())
	{
		print("is server");
	}
	if(getNet().isClient())
	{
		print("is client");
	}
	if(hitBlob.getTeamNum() != this.getTeamNum())
	{
		print("strengtH: " + strength);
		float poisonPower = strength * 40.0f;
		print("power: " + poisonPower);
		addPoison(hitBlob, poisonPower);
	}
}

// void onTick( CBlob@ this ) 
// {
	
// }