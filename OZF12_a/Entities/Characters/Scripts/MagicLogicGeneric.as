#include "Hitters.as";


void ballOnCollide( CBlob@ this, CBlob@ blob, bool solid, f32 HITDAMAGE)
{
	Vec2f pos = this.getPosition();
	if(solid)
	{
		this.setVelocity(Vec2f_zero); //Not sure if this does much, but if there's lag hopefully it'll prevent quite as much bouncey.
		if(getNet().isServer())
		{
			this.server_Die();
		}
		if(blob !is null)
			this.server_Hit( blob, pos, Vec2f_zero, this.get_f32("hitDamage"), Hitters::fire);
	}
}