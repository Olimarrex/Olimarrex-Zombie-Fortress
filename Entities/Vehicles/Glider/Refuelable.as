void onInit(CBlob@ this)
{
	this.addCommandID("Refuel");
}
//Make a button for adding wood to glider.
void GetButtonsFor(CBlob@ this, CBlob@ caller) //Mutagen stuff.
{
	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "mat_wood")
	{
		CBitStream params;
		params.write_netid( carried.getNetworkID() );
		CButton@ button = caller.CreateGenericButton( "$mat_wood$", Vec2f(0, 0), this, this.getCommandID("Refuel"), "Refuel the " + this.getInventoryName(), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("Refuel"))
	{
		CBlob@ wood = getBlobByNetworkID(params.read_netid());
		if(getNet().isServer())
		{
			wood.server_DetachFromAll();
			if(wood !is null)
			{
				this.server_PutInInventory(wood);
			}
		}
	}
}

void onRender(CSprite@ this)
{
	if (this is null) return; //can happen with bad reload

	// draw only for local player
	CBlob@ localBlob = getLocalPlayerBlob();
	CBlob@ blob = this.getBlob();

	CInventory@ inv = blob.getInventory();
	if(inv is null)
	{
		return;
	}
	if (localBlob is null)
	{
		return;
	}
	AttachmentPoint@ driver = blob.getAttachments().getAttachmentPointByName("FLYER");
	if (driver !is null	&& driver.getOccupied() is localBlob)
	{
		if(inv.getCount("mat_wood") < 50 && getGameTime() % 10 <= 5)
		{
			GUI::DrawIconByName("$mat_wood$", blob.getScreenPos());
		}
	}
}