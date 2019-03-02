#include "ZombieCommon.as";
//Only works properly in client.
bool client_IsInDaylight(CBlob@ this)
{
	CMap@ map = this.getMap();
	CBlob@[] nearBlobs;
	Vec2f pos = this.getPosition();
	if (map.getBlobsInRadius(pos, 40, @nearBlobs))
	{
		for(int i = 0; i < nearBlobs.length(); i++)
		{
			CBlob@ nearBlob = nearBlobs[i];
			if(nearBlob.hasTag("Emits Sunlight"))
			{
				return true;
			}
		}
	}

	Tile tile = map.getTile(pos);// - only works on server-side.
	u8 sunlight = tile.light;

	if(isNightTime() || sunlight < 80)
	{
		return false;
	}
	return true;
}

//this version includes any light emitted (but only during the day)
bool isInDaylight(CBlob@ this)
{
	CMap@ map = this.getMap();
	CBlob@[] nearBlobs;
	Vec2f pos = this.getPosition();
	if (map.getBlobsInRadius(pos, 40, @nearBlobs))
	{
		for(int i = 0; i < nearBlobs.length(); i++)
		{
			CBlob@ nearBlob = nearBlobs[i];
			if(nearBlob.hasTag("Emits Sunlight"))
			{
				return true;
			}
		}
	}
	//SColor poscolor = map.getColorLight(pos);
	//u8 light = poscolor.getLuminance();
	//Raycast upwards, checking for background tiles as we go till we find a solid block.
	Vec2f tilepos = pos;
	bool inDarkness = false;
	while(true)
	{
		pos.y -= map.tilesize;
		Tile tile = map.getTile(pos);
		if(map.isTileBackgroundNonEmpty(tile))
		{
			//continue;
		}
		else 
		{
			inDarkness = map.isTileSolid(tile);
			break;
		}
	}
	if(isNightTime() || inDarkness/*light < 80*/) //currently lanterns can be used to grow underground :(
	{
		return false;
	}
	return true;
}