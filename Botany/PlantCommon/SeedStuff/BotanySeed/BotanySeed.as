#include "PlantCommon.as";
//MUUUUCH better xD
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 50; //Meh.
	this.setInventoryName(this.exists("seedname") ? this.get_string("seedname") : "seed");
	initSeed(this);
	this.set_u32("groundTime", 0);
}
void onTick(CBlob@ this) //Making crop.
{
	if(getNet().isServer() && this.getTickSinceCreated() > 150)
	{
		string crop = getBlobName(this);
		if(canGrow(this))
		{
			this.set_u32("groundTime", 0);
			this.set_u32("timeOnGround", 0);
			if(crop != "")
			{
				CBlob@ b = server_CreateBlobNoInit(crop);
				if(b !is null)
				{
					b.setPosition(this.getPosition());
					b.server_setTeamNum(this.getTeamNum());
					b.Init();
					copyMutation(this, b, false);
				}
				this.server_Die();
			}
		}
		else if(!this.isInInventory() && this.isOnGround() || this.getShape().isStatic())
		{
			u32 groundTime = this.get_u32("groundTime");
			if(groundTime != 0)
			{
				if(getGameTime() - groundTime > 1800) //30 seconds
				{
					this.server_Die();
				}
			}
			else
			{
				this.set_u32("groundTime", getGameTime());
			}
			
		}
	}
}
bool canGrow(CBlob@ this)
{
	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	Tile tile = map.getTile(pos + Vec2f(0, 8));
	u16 type = tile.type;
	bool isNiceTile = !map.isTileBackground(tile) && map.isTileGroundStuff(type);
	if(isNiceTile && (this.isOnGround() || this.getShape().isStatic()))
	{
		CBlob@[] nearBlobs;
		Vec2f tPos = getTilePos(pos);
		if (map.getBlobsInRadius(getTilePos(pos), 3, @nearBlobs))
		{
			for(int i = 0; i < nearBlobs.length(); i++)
			{
				CBlob@ nearBlob = nearBlobs[i];
				if(nearBlob !is null && nearBlob.hasTag("plant"))
				{
					return false;
				}
			}
		}
		return !(this.isAttached() && this.isInInventory());
	}
	return false;
}

Vec2f getTilePos(Vec2f pos)
{
	CMap@ map = getMap();
	f32 div_maptile = 1.0f / map.tilesize;

	Vec2f tp = pos * div_maptile;
	Vec2f round_tp = tp;
	round_tp.x = (Maths::Floor(round_tp.x) + 0.5f) * map.tilesize;
	round_tp.y = (Maths::Floor(round_tp.y) + 0.5f)* map.tilesize;
	return round_tp;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("setSeedName"))
	{
		string name = params.read_string();
		if(getNet().isClient())
		{
			this.setInventoryName(name);
		}
	}
}