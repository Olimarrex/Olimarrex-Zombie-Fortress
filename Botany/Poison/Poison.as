#include "PoisonCommon.as"; 
void onInit(CBlob@ this)
{
	this.Tag("poisonable");
	this.set_u16("poison magnitude", 0);
	this.getCurrentScript().tickFrequency = 60;
	this.getCurrentScript().removeIfTag = "dead";
	this.set_f32("poisonRes", 1.0f);
}

void onTick(CBlob@ this)
{
	int magnitude = getPoisonLevel(this);
	if(magnitude > 0)
	{
		
		//Tiny amount decreased magnitude.
		int amount = 1;
		if(this.isInWater()) //4 * faster poison curing when in water. 
		{
			amount += 3;
			Vec2f pos = this.getPosition();
			ParticleAnimated(CFileMatcher("HeartAnim.png").getFirst(), pos, Vec2f_zero, 0, 0.5f, 20, 0.0f, false);
		}
		curePoison(this, amount);
		if(true)
		{
			if(getNet().isServer())
			{
				this.server_Hit(this, this.getPosition(), Vec2f(0, 0), Maths::Sqrt(magnitude) / 35.0f, 0);
			}
			if(getNet().isClient())
			{
				CPlayer@ p = this.getPlayer();
				if(p !is null && p.isMyPlayer())
				{
					SetScreenFlash( 90, 0, 120, 0 );
				}
				ParticleAnimated("PoisonBubble.png", this.getPosition() + Vec2f(XORRandom(10) - 5, XORRandom(4)), Vec2f(0, -(10 + XORRandom(10)) / 10.0f), 0.0f, 1.0f, 20.0f + XORRandom(30.0f), 0.03f, false);
			}
		}
	}
}