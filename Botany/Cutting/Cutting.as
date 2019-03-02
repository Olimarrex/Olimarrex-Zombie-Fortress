//Cutting.as
//DISCONTINUED
void onInit(CBlob@ this)
{
	if(getNet().isClient())
	{
		this.setInventoryName(this.get_string("nameSuffix") + " Cutting");
	}
}
void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	this.SetFrame(blob.get_u8("plantIndex"));
}