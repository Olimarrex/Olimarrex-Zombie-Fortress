#include "PoisonCommon.as";
#include "BrewPotionCommon.as";
#include "PotionCommon.as";
void onTick( CBlob@ this ) 
{
	f32 strength = getPotionStrength(this, potionIndex::spitSeeds);
	if(getNet().isServer() && getGameTime() % Maths::Round(20.0f / strength) == 0)
	{
		Vec2f pos = this.getPosition();
		Vec2f aimpos = this.getAimPos();
		Vec2f vel = aimpos - pos;
		vel.Normalize();
		vel.RotateBy(XORRandom(21) - 10, Vec2f_zero);
		vel *= 6.0f;
		
		CBlob@ seed = server_CreateBlob("spatseed", this.getTeamNum(), pos + vel);
		
		vel *= Maths::Sqrt(strength / 2.0f) + 1.0f;
		seed.server_SetTimeToDie(2);
		seed.setVelocity(vel);
		CPlayer@ p = this.getPlayer();
		if(p !is null)
		{
			seed.SetDamageOwnerPlayer(p);
		}
	}
}