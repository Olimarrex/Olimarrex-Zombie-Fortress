#include "PoisonCommon.as";
#include "BrewPotionCommon.as";
#include "PotionCommon.as";
void onTick (CBlob@ this)
{
	f32 strength = getPotionStrength(this, potionIndex::regenerate);
	this.server_Heal(strength / 300.0f);
}