int getPoisonLevel(CBlob@ this)
{
	return this.get_u16("poison magnitude");
}

void setPoison(CBlob@ blob, int magnitude)
{
	if(blob.hasTag("poisonable"))
	{
		blob.set_u16("poison magnitude", Maths::Max(magnitude, getPoisonLevel(blob)));
	}
}
void addPoison(CBlob@ blob, int magnitude)
{
	if(blob.hasTag("poisonable"))
	{
		magnitude /= blob.get_f32("poisonRes");
		blob.set_u16("poison magnitude", Maths::Min(500, int(magnitude) + getPoisonLevel(blob) ) );
	}
}
void curePoison(CBlob@ blob, int healingpower) //LIES
{
	if(blob.hasTag("poisonable"))
	{
		int number = getPoisonLevel(blob) - int(healingpower); 
		number = Maths::Max(0, number);
		
		blob.set_u16("poison magnitude", number);
	}
}
const string poisonString = "Poisonous ";
void setPoisonous(CBlob@ this)
{
	if(!this.hasTag("poisonous"))
	{
		this.Tag("poisonous");
		this.setInventoryName(poisonString + this.getInventoryName());
	}
}
void unsetPoisonous(CBlob@ this)
{
	if(this.hasTag("poisonous"))
	{
		this.Untag("poisonous");
		int len = poisonString.length;
		string invString = this.getInventoryName().substr(len);
		this.setInventoryName(invString);
	}
}