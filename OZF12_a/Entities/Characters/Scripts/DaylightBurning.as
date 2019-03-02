#include "Hitters.as";
#include "FireCommon.as";
#include "SunlightCommon.as";
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 100;
	this.addCommandID("burn");
}
void onTick(CBlob@ this)
{
	if(getNet().isClient() && this.isMyPlayer())
	{
		CMap@ map = this.getMap();
		Tile tile = map.getTile(this.getPosition());
		u8 sunlight = tile.light;
		if(client_IsInDaylight(this) && !this.isInWater())
		{
			this.SendCommand(this.getCommandID("burn"));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("burn"))
	{
		if(getNet().isServer())
		{
			if(!this.hasTag(burning_tag))
			{
				this.server_Hit(this, this.getPosition(), Vec2f_zero, 0.01f, Hitters::fire);
			}
		}
	}
}