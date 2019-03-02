#include "PoisonCommon.as";
const string heal_id = "heal command";

void onInit(CBlob@ this)
{
	if (!this.exists("eat sound"))
	{
		this.set_string("eat sound", "/Eat.ogg");
	}
	this.Tag("nommable");
	this.addCommandID(heal_id);
}

void Heal(CBlob@ this, CBlob@ blob)
{
	if(this is null) return;
	if (isEdible(this, blob)
	&& (blob.getHealth() < blob.getInitialHealth() - 0.25f || ( getPoisonLevel(this) > 0 && this.exists("poisonCureAmount") ) ) )
	{
		CBitStream params;
		params.write_u16(blob.getNetworkID());

		this.SendCommand(this.getCommandID(heal_id), params);

		this.Tag("healed");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID(heal_id))
	{
		this.Tag("healed");
		this.getSprite().PlaySound(this.get_string("eat sound"));

		u16 blob_id;
		if (!params.saferead_u16(blob_id)) return;
		
		CBlob@ theBlob = getBlobByNetworkID(blob_id);
		if (theBlob is null) return;
		
		f32  heal_amount = getHealAmount(this, theBlob);
		
		if(this.hasTag("poisonous"))
		{
			addPoison(theBlob, 40);
			theBlob.getSprite().PlaySound("war_oh_02.ogg");
		}
		if (getNet().isServer())
		{
			this.server_Die();
			theBlob.server_Heal(f32(heal_amount) * 0.25f);
		}
		
		if(this.exists("poisonCureAmount"))
		{
			curePoison(theBlob, this.get_u16("poisonCureAmount"));
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	int dist = (this.getPosition() - caller.getPosition()).Length();
	if(isEdible(this, caller) && dist < 40)
	{
		caller.CreateGenericButton("$food$", Vec2f(0, 0), this, this.getCommandID(heal_id), "Eat", params);
	}
}

bool isEdible(CBlob@ this, CBlob@ eater)
{
	return getNet().isServer() && eater.hasTag("player") && !this.hasTag("healed");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null)
	{
		return;
	}

	if (getNet().isServer() && !blob.hasTag("dead"))
	{
		Heal(this, blob);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		Heal(this, attached);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	if (getNet().isServer())
	{
		Heal(this, detached);
	}
}

f32 getHealAmount(CBlob@ this, CBlob@ blob)
{
	//Get heal amount.
	f32 heal_amount = 255; //in quarter hearts, 255 means full hp

	if (this.getName() == "heart")	    // HACK
	{
		heal_amount = 4;
	}
	else if(this.exists("heal_amount"))
	{
		heal_amount = this.get_u8("heal_amount");
		heal_amount *= float(blob.getInitialHealth() / 2.0f);
	}
	return heal_amount;
}