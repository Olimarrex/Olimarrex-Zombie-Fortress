#include "PoisonCommon.as";
#include "PoisonPotionCommon.as";
#include "PotionCommon.as";
void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	f32 strength = getPotionStrength(this, potionIndex::toxic);
	print("strength: " + strength);
	if(hitBlob.getTeamNum() != this.getTeamNum())
	{
		addPoison(hitBlob, 40.0f * strength);
	}
}

void onTick( CBlob@ this ) 
{
	
}