#include "PlantCommon.as";
CBlob@ server_makeSeedFromBlob(CBlob@ this, bool mutate) //Makes a seed of the plant in question. Can be done on any blob, but only plants will work.
{
	if(!getNet().isServer())
	{
		return null;
	}
	return server_makeBotanySeedFromBlob(this.getPosition(), this.get_u8("plantIndex"), mutate, this);
}
CBlob@ server_makeSeedFromCutting(CBlob@ this, bool mutate) //Attempts to make a seed/cutting using produce. Can be done on any blob, but only those with seed info will work!
{
	if(!getNet().isServer())
	{
		return null;
	}//Get qualities from cutting, if there aren't any, then this isn't a cutting.
	if(!this.exists("strength"))
	{
		return null;
	}
	this.server_Die(); //Kills the pheg
	return(server_makeBotanySeedFromBlob(this.getPosition(), this.get_u8("plantIndex"), mutate, this));
}
CBlob@ server_makeBotanySeedFromBlob(Vec2f pos, int plantIndex, bool mutate, CBlob@ this = null)
{
	if(getNet().isServer())
	{
		CBlob@ seedblob = server_CreateBlobNoInit("botanyseed"); //pok
		if(seedblob !is null)
		{
			//APPARENTLY WE DONT NEED TO SYNC ON NO INIT
			if(this !is null)
			{
				copyMutation(this, seedblob, mutate, false);
			}
			else
			{
				this.set_f32("growth_speed", 1);
				this.set_f32("productivity", 1);
				this.set_f32("strength", 1);
			}
			seedblob.set_u8("plantIndex", plantIndex);
			seedblob.set_string("seedname", getSeedName(plantIndex));
			seedblob.setPosition(pos);
			seedblob.server_setTeamNum(-1);
			seedblob.Init();
		}
		return seedblob;
	}
	else
	{
		warn("server_makeBotanySeedFromBlob was called onClient!");
		return null;
	}
}
CBlob@ server_makeBotanySeed(Vec2f pos, int plantIndex, bool mutate, f32 growthSpeed, f32 productivity, f32 strength)
{
		CBlob@ seedblob = server_CreateBlobNoInit("botanyseed"); //pok
		if(seedblob !is null)
		{
			//APPARENTLY WE DONT NEED TO SYNC ON NO INIT
			seedblob.set_f32("growth_speed", growthSpeed);
			seedblob.set_f32("productivity", productivity);
			seedblob.set_f32("strength", strength);
			seedblob.set_u8("plantIndex", plantIndex);
			seedblob.set_string("seedname", getSeedName(plantIndex));
			seedblob.setPosition(pos);
			seedblob.server_setTeamNum(-1);
			seedblob.Init();
		}
		return seedblob;
}