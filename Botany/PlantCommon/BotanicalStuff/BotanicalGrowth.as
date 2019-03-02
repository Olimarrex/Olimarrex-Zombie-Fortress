//Gotta completely redo growth.
#include "PlantGrowthCommon.as";
#include "PlantCommon.as";
#include "canGrow.as";
#include "Shitters.as";

/*void onInit(CBlob@ this)
{
	if (!this.exists(grown_amount))
		this.set_u8(grown_amount, 0);
	if (!this.exists(growth_chance))
		this.set_u8(growth_chance, default_growth_chance);
	if (!this.exists(growth_time))
		this.set_u8(growth_time, default_growth_time);

	if (this.hasTag("instant_grow"))
		this.set_u8(grown_amount, growth_max);
}*/
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData != BigHitters::builder && isSolidHit(customData))
	{
		damage /= 3.0f;
	}
	return damage;
}
void onInit(CBlob@ this)
{
	this.addCommandID("Mutate");
	this.Tag("plant");
	this.Tag("builder always hit");
	if(getNet().isServer() && this.exists("strength"))
	{
		this.server_SetHealth(this.getHealth() * getStrength(this));
	}
	if(this.exists("growth_speed"))
	{
		f32 growth_speed = getGrowthSpeed(this);
		this.getCurrentScript().tickFrequency = getTickFreq(this, growth_speed);
//Ingenious Geti! ... I think
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller) //Mutagen stuff.
{
	//CrossBreeding is no longer done this way - but keeping it in just incase.
	/*CBitStream params;
	params.write_netid( caller.getNetworkID() );
	CBlob@ mutagen = caller.getCarriedBlob();
	if(mutagen !is null && mutagen.hasTag("mutagen") && !this.hasTag("crossbred"))
	{
		CButton@ button = caller.CreateGenericButton(
		"$mutagen$",
		Vec2f(0, 0),
		this,
		this.getCommandID("Mutate"),
		"Crossbreed the " + this.getInventoryName() + "\n with the " + mutagen.getInventoryName() + ".",
		params);
	}*/
}

void onTick(CBlob@ this) //Manage des shet server-side only?
{
	if(getNet().isServer())
	{
		u8 statusindex = getStatus(this);
		if(statusindex == 255)
		{
			u16 growth_stage = this.get_u16("growth_stage");
			f32 growth_speed = getGrowthSpeed(this);
			this.getCurrentScript().tickFrequency = getTickFreq(this, growth_speed);
			growth_stage += 1;
			this.set_u16("growth_stage", growth_stage);
			this.Sync("growth_stage", true);
			CSprite@ sprite = this.getSprite();
			if(!this.hasTag("grown"))
			{
				Animation@ anim = sprite.getAnimation("growth");
				
				if(anim !is null && sprite.isAnimation("growth"))
				{
					if(growth_stage > anim.getFramesCount())
					{
						this.Tag("grown");
						this.Sync("grown", true);
						//GROWN.
					}
				}
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("Mutate"))
	{
		u16 netID;
		params.saferead_netid(netID);
		CBlob@ caller = getBlobByNetworkID(netID);
		if(caller !is null)
		{
			CBlob@ mutagen = caller.getCarriedBlob();
			if(mutagen !is null && mutagen.hasTag("mutagen") && !this.hasTag("crossbred"))
			{
				if(getNet().isServer())
				{
					mutagen.server_Die();
				}
				addMutagen(this, mutagen);
			}
		}
	}
}

int getTickFreq(CBlob@ this, int growth_speed)
{
	int tickFreq = growth_speed * (this.isInWater() ? 4 : 1); //Ingenious Geti! ... I think
	if(sv_test) //Don' forget dis here.
	{
		tickFreq /= 40.0f;
	}
	return tickFreq;
}