#include "Hitters.as";
#include "ShieldCommon.as";
void onInit(CBlob@ this)
{
	if(getNet().isServer())
	{
		this.server_SetTimeToDie(6);
	}
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob !is null)
	{
		// check if shielded
		if(getNet().isServer())
		{
			const bool hitShield = (blob.hasTag("shielded") && blockAttack(blob, this.getVelocity(), 0.0f));
			if((blob.hasTag("flesh") || blob.hasTag("player")) && blob.getTeamNum() != this.getTeamNum())
			{
				f32 speed = this.getShape().vellen;
				if(!hitShield && speed > 2)
				{
					f32 damage = 0.5f;
					this.server_Hit(blob, this.getPosition(), this.getVelocity(), damage, Hitters::crush);
				}
				
				this.server_Die();
			}
		}
		
	}
}
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if(blob.getShape().isStatic())
	{
		return true;
	}
	return false;
}