//PotionEffects.as;
//Calling potions funcs, etc. as needed.
#include "PotionCommon.as";
void onInit(CBlob@ this)
{
	int[] activePotions;
	this.set("activePotions", activePotions);
}

void onTick(CBlob@ this)
{
	int[] activePotions;
	if(this.get("activePotions", activePotions))
	{
		for(int i = 0; i < activePotions.length; i++)
		{
			int potionIndex = activePotions[i];
			potionInfo info = getPotionInfo(potionIndex);
			if(isPotionEnded(this, potionIndex))
			{
				if(info.endFunc !is null)
				{
					f32 strength = getPotionStrength(this, potionIndex);
					info.endFunc(this, strength);
				}
				if(info.scriptName != "")
				{
					this.RemoveScript(info.scriptName);
				}
				activePotions.removeAt(i);
				this.set("activePotions", activePotions);
			}
		}
		if( activePotions.length > 0 && getGameTime() % (10 / float(activePotions.length)) == 0 )
		{
			effectParticle(this);
		}
	}
}



bool isPotionEnded(CBlob@ this, int index)
{
	potionInfo info = getPotionInfo(index);
	f32 strength = getPotionStrength(this, index);
	u32 duration = info.getPotionDuration(strength);
	int potionTime = getPotionTime(this, index);
	int timeSinceDrunk = getGameTime() - potionTime;

	return (potionTime == 0 || timeSinceDrunk > duration);
}