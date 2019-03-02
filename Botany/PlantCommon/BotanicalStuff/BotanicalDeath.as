#include "PlantCommon.as";
#include "MakeBotanySeed.as";
//Create produce on death, also check for crossbreeding.
void onDie(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	int teamNum = this.getTeamNum();
	if(this.hasTag("virus"))
	{
		return;
	}
	f32 productivity = this.get_f32("productivity");
	string produce = getProduce(this);
	if(this.hasTag("grown") || this.hasTag("flower"))
	{
		if(getNet().isServer())
		{
			if(!this.hasTag("berry") && produce != "" && (this.hasTag("flower") || !this.hasTag("vine")))//TODO: Move this to a seperate script?
			{
				for(int i = 0; i < productivity; i++)
				{
					server_CreateProduce(produce, teamNum, pos, this);
				}
			}
			f32 seedNum = 1 + getSeedNum(this);
			for(int i = 0; i < seedNum; i++)
			{
				CBlob@ seed = server_makeSeedFromBlob(this, true);
				if(seed !is null)
				{
					seed.setVelocity(Vec2f(-2, XORRandom(7) / 3.0f - 1.0f) );
				}
			}
			//Crossbreeding, replaced by botany workshop.
			/*if(XORRandom(15) == 1)
			{
				CBlob@ cutting = server_CreateBlobNoInit("cutting");
				if(cutting !is null)
				{
					cutting.set_u8("plantIndex", this.get_u8("plantIndex"));
					
					cutting.Tag("mutagen");
					
					cutting.set_string("nameSuffix", this.getInventoryName());
					
					cutting.server_setTeamNum(-1);
					
					cutting.setPosition(pos);
					cutting.Init();					
				}
			}*/
		}
		/*int[][] mutagens;
		if(this.hasTag("crossbred")
		&& this.get("mutagens", mutagens))//If you don't bother to set these then it'll simply ignore I think
		{
			for(int n = 0; n < mutagens.length; n++)
			{
				u8 mutagenIndex = this.get_u8("mutagen_plantIndex");
				if(mutagenIndex == mutagens[n][0])
				{
					if(getNet().isServer())
					{
						CBlob@ b = server_CreateBlob(getBlobName(this, mutagens[n][1]), teamNum, pos);
						if(b !is null)
						{
							copyMutation(this, b, true);
						}
					}
					this.getSprite().PlaySound("/Thunder1.ogg");
					break;
				}
			}
		}*/
	}
}