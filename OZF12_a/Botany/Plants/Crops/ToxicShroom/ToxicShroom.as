// Bush logic

#include "PoisonCommon.as";
#include "PlantCommon.as";
#include "MakeBotanySeed.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 3;
	this.Tag("growsInDarkness");
	initPlant(this, plantIndex::toxicshroom);
}
//const u8 GAS_LENGTH = 25;
const u8 GAS_HIT_LENGTH = 40;
const u8 GAS_ACTIVATE_WAIT = 30;
void onTick(CBlob@ this)
{
	if(!this.hasTag("grown"))
	{
		return;
	}
	CBlob@[] blobs;
	bool shouldcount = false;
	bool cloud = false;
	u8 counter = this.get_u8("counter");
	//IF COUNTER IS GREATER THAN NUM TAG POISON.
	//IF HAS TAG POISON DECREASE COUNTER
	//IF IF HAS TAG POISON AND COUNTER IS LIKE 3 THEN UNTAG POISON
	if(counter > GAS_ACTIVATE_WAIT && !this.hasTag("poisonous"))
	{
		this.Tag("poisonous");
		//counter = GAS_LENGTH; //Doesn't work cuz it overrides GAS_HIT_LENGTH
		this.getSprite().PlaySound("PoisonHiss.ogg");
	}
	if(this.hasTag("poisonous"))
	{
		if(counter < 3)
		{
			this.Untag("poisonous");
		}
		else
		{
			//Do poison.
			Vec2f rand = Vec2f(XORRandom(61) - 30, XORRandom(61) - 30);
			cloud = true;
			counter = Maths::Max(counter - 1, 1);
			ParticleAnimated("SporeCloud.png", this.getPosition() + rand, Vec2f(0, -0.2f), XORRandom(360), 0.5f, 20, 0, false);
		}
	}
	if(getMap().getBlobsInRadius(this.getPosition(), 30, blobs))
	{
		for(int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if(b is null) continue;
			if(b.hasTag("poisonable"))
			{
				if(cloud)
				{
					addPoison(b, 1);
					CInventory@ inv = b.getInventory();
					if(inv !is null)
					{
						int invcount = inv.getItemsCount();
						for(int t = 0; t < invcount; t++) //Poison food of inventory. ALSO DOESNT AFFECT CRATES c:
						{
							CBlob@ item = inv.getItem(t);
							if(item is null) continue;
							if(item.hasTag("nommable"))
							{
								setPoisonous(item);
							}
						}
					}
				}
				else
				{
					shouldcount = true;
					break;
				}
			}
			else if(b.hasTag("nommable")) //Poison food
			{
				setPoisonous(b);
			}
		}
	}
	if(shouldcount)
	{
		counter = Maths::Min(254, counter + 1);
	}
	this.set_u8("counter", counter);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(damage > 0.1f)
	{
		this.set_u8("counter", GAS_HIT_LENGTH); //Instant gas that also lasts longer than normal.
	}
	return damage;
}