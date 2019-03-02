#include "PoisonCommon.as";
#include "BrewPotionCommon.as";
#include "PotionCommon.as";
void onTick (CBlob@ this)
{
	if(getNet().isServer())
	{
		if(getGameTime() % 20 == 0)
		{
			f32 strength = getPotionStrength(this, potionIndex::regenerate);
			float amount = strength / 50.0f;
			print("Strength: " + strength);
			print("number: " + amount);
			this.server_Heal(amount);
		}
	}
}