#include "PoisonCommon.as";
#include "PoisonPotionCommon.as";
#include "PotionCommon.as";
#include "TimeoutCommon.as";
void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if(hitBlob.hasTag("hastimeouts"))
	{
		f32 strength = getPotionStrength(this, potionIndex::antiGravity);
		f32 gravScale = -0.1f * strength;
		hitBlob.getShape().SetGravityScale(gravScale);
		hitBlob.set_f32("defaultGravScale", gravScale);
		hitBlob.AddForce(Vec2f(0, -1)); //add tiny amount of force to make it trigger, cause if u's movingering.
		setTimeout(hitBlob, 40 + (strength * 5), @endGravityScale);
	}
}

void endGravityScale(CBlob@ this)
{
	this.getShape().SetGravityScale(1.0f);
	this.set_f32("defaultGravScale", 1.0f);
}