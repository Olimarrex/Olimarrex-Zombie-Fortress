#include "PoisonCommon.as";
#include "BrewPotionCommon.as";
#include "PotionCommon.as";
#include "Shitters.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 strength = getPotionStrength(this, potionIndex::damageRes);
	if(isSolidHit(customData))
	{
		damage /= 1.25f + strength;
	}
	return damage;
}