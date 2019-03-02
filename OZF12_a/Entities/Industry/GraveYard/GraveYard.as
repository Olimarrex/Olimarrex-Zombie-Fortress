#include "MaterialCommon.as";
void onInit(CBlob@ this)
{
	this.addCommandID("Zombify");
	this.Tag("builder always hit");
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$Succumb$", Vec2f_zero, this, this.getCommandID("Zombify"), "Bury yourself", params);
	}
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("Zombify"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16()); //Does this need to done on both client and server to prevent Bad Deltas? - Olimarrex
		if(getNet().isServer())
		{
			if(caller !is null)
			{
				CPlayer@ player = caller.getPlayer();
				if(getNet().isServer() && player !is null && !player.hasTag("zombify"))
				{
					int amount = Maths::Min((getGameTime() / 20.0f) + 250, 2000);
					Material::createFor(caller, "mat_wood", amount);
					Material::createFor(caller, "mat_stone", amount / 2);
					if(amount > 300)
					{
						Material::createFor(caller, "mat_gold", amount / 8);
					}
					caller.server_Die();
					player.Tag("zombify");
					player.Tag("willingZombie");
				}
			}
		}
	}
}