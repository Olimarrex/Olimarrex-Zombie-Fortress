//Null

//Remedies
/*void healRemedy( CBlob@ this, int strength )
{
	this.server_Heal(1.0f * strength);
}*/


//Brews

void poisonResStart( CBlob@ this, f32 strength )
{
	f32 poisonRes = this.get_f32("poisonRes");
	print("Poison Res: "+ poisonRes + " strength: " + strength);
	this.set_f32("poisonRes", poisonRes * (strength * 2));
}

void poisonResEnd( CBlob@ this, f32 strength )
{
	f32 poisonRes = this.get_f32("poisonRes");
	print("Poison Res: "+ poisonRes);
	this.set_f32("poisonRes", poisonRes / (strength * 2));
}

//Elixirs


void nightVisStart( CBlob@ this, f32 strength )
{
	if(this.isMyPlayer() && getNet().isClient())
	{
		this.SetLightRadius(60.0f * strength);
		this.SetLightColor(SColor(255, 18, 152, 255));
		this.SetLight(true);
	}
}

void nightVisEnd( CBlob@ this, f32 strength )
{
	if(this.isMyPlayer() && getNet().isClient())
	{
		this.SetLightRadius(0.0f);
		this.SetLight(false);
	}
}

void healStart( CBlob@ this, f32 strength )
{
	this.server_Heal(strength * 2.0f);
	if(getNet().isServer())
	{
		this.server_SetHealth(this.getHealth() + strength); //CAN GO OVER THE TOP!
	}
}