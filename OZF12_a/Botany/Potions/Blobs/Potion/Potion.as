//Potion.as
#include "PotionCommon.as";
void onInit(CBlob@ this)
{
	potionInfo info = getPotionInfo(this);
	this.addCommandID("drink");
	this.setInventoryName(info.getPotionName());
}
void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	string desc = "Quaff the " + this.getInventoryName() + ".";
	CBitStream params;
	if(this.hasTag("empty"))
	{
		return;
	}
	params.write_netid( caller.getNetworkID() );
	CButton@ button = caller.CreateGenericButton(
		"$mutagen$",
		Vec2f(0, 0),
		this,
		this.getCommandID("drink"),
		desc,
		params
	);
	button.SetEnabled(true);
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("drink"))
	{
		if(this.hasTag("empty"))
		{ 
			return;
		}
		this.Tag("empty");	
		if(getNet().isServer())
		{
			this.server_Die();
		}
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if(caller !is null)
		{
			drinkPotion(this, caller);
		}
	}
}
