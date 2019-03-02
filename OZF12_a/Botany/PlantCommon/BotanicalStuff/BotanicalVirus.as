#include "PlantCommon.as";
#include "Shitters.as";
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 600;
	this.addCommandID("Cure");
}
void onTick(CBlob@ this)
{
	if(this.hasTag("virus"))
	{
		CBlob@[] nearBlobs;
		if (this.getMap().getBlobsInRadius(this.getPosition(), ((this.getRadius() * 2.4f) + 9.0f), @nearBlobs)) //Might cause MAJOR lag issues, what should do..?
		{
			for(int i = 0; i < nearBlobs.length(); i++)
			{
				CBlob@ nearBlob = nearBlobs[i];
				if(nearBlob !is null)
				{
					if(nearBlob.hasTag("plant") && !nearBlob.hasTag("virus"))
					{
						nearBlob.Tag("virus");
					}
				}
			}
			//this.getCurrentScript().tickFrequency = 1000 + XORRandom(100); //Everthing's been virused, be less interested in the world.
		}
		if(getNet().isServer())
		{
			this.server_Hit(this, this.getPosition(), Vec2f_zero, 0.75f, BigHitters::infection);
		}
	}
	else if(getNet().isServer())
	{
		u8 waterLevel = getWaterLevel(this);
		//print("Bliegh: " + (waterLevel < 2  ? 0.2f : 1.0f));
		if(XORRandom(15.5f * ((waterLevel < 2 ? 0.2f : 1.0f) + (35.0f * this.get_f32("strength")))) == 0) //Shouldn't use 2 because water level should always exist u phug
		{
			this.Tag("virus");
			this.Sync("virus", true);
		}
	}
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_netid( caller.getNetworkID() );
	CBlob@ cureblob = caller.getCarriedBlob();
	if(cureblob !is null && cureblob.getName() == "antidote" && this.hasTag("virus"))
	{
		CButton@ button = caller.CreateGenericButton( "$antidote$", Vec2f(0, 0), this, this.getCommandID("Cure"), "Cure this plant!", params);
	}
}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("Cure"))
	{
		u16 netID;
		params.saferead_netid(netID);
		CBlob@ b = getBlobByNetworkID(netID);
		if(b !is null)
		{
			CBlob@ cureblob = b.getCarriedBlob();
			if(cureblob !is null && cureblob.getName() == "antidote")
			{
				cure(this);
				if(getNet().isServer())
				{
					cureblob.server_Die();
				}
			}
		}
	}
}
void onCollision( CBlob@ this, CBlob@ blob, bool solid ) //For automation, cures itself when a plant collides with it.
{
	if(blob.getName() == "antidote" && this.hasTag("virus")) //Might end up curing several things at once, must be carefur?
	{
		cure(this);
		if(getNet().isServer())
		{
			blob.server_Die();
		}
	}
}
void cure(CBlob@ this)
{
	this.Untag("virus");
	this.getCurrentScript().tickFrequency = 125; //Everthing's been virused, be less interested in the world.
	CBlob@[] nearBlobs;
	if (this.getMap().getBlobsInRadius(this.getPosition(), ((this.getRadius() * 2.0f) + 5.0f), @nearBlobs))
	{
		for(int i = 0; i < nearBlobs.length(); i++)
		{
			CBlob@ nearBlob = nearBlobs[i];
			if(nearBlob !is null && nearBlob.hasTag("virus"))
			{
				nearBlob.Tag("checkitagain");
			}
		}
	}
}
