
#include "PriestCommon.as";
#include "Hitters.as";
#include "PoisonCommon.as";

void onInit( CBlob@ this )
{
	this.set_u32("last teleport", 0 );
	this.set_bool("teleport ready", true );
	this.getCurrentScript().removeIfTag = "dead";
}


void onTick( CBlob@ this ) 
{	
	bool ready = this.get_bool("teleport ready");
	const u32 gametime = getGameTime();
	
	if(ready)
	{
		if(this.isKeyJustPressed( key_action2 )) {
			Vec2f delta = this.getPosition() - this.getAimPos();
			if(delta.Length() < TELEPORT_DISTANCE){
				if(HealNearest(this, this.getAimPos()))
				{
					this.set_u32("last teleport", gametime);
					this.set_bool("teleport ready", false );
				}
			} else if(this.isMyPlayer()) {
				Sound::Play("option.ogg");
			}
		}
	}
	else
	{		
		u32 lastTeleport = this.get_u32("last teleport");
		int diff = gametime - (lastTeleport + TELEPORT_FREQUENCY);
		
		if(this.isKeyJustPressed( key_action2 ) && this.isMyPlayer()){
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("teleport ready", true );
			this.getSprite().PlaySound("/Cooldown2.ogg");
		}
	}
}
//Returns the first item inside an inventory with the specified tag.
CBlob@ getItemWithTag(CInventory@ this, string tag)
{
	if(this is null)
	{
		return null;
	}
	int count = this.getItemsCount();
	print("" +count);
	for(int i = 0; i < count; i++)
	{
		CBlob@ item = this.getItem(i);
		print(item.getName());
		if(item !is null && item.hasTag(tag))
		{
			return item;
		}
	}
	return null;
}
bool HealNearest( CBlob@ this, Vec2f pos)
{
	print("greh");
	CMap@ map = getMap();	
	CBlob@[] blobsInRadius;
	CInventory@ inv = this.getInventory();
	CBlob@ food = getItemWithTag(inv, "nommable");
	
	if (map.getBlobsInRadius( pos, 10.0f, @blobsInRadius ))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			
			if (b !is null)
			{
				if(this.getTeamNum() == b.getTeamNum()
				&& b.hasTag("player"))
				{
					bool healed = false;
					
					if(b.getHealth() < b.getInitialHealth())
					{
						//Add food to inv for healing
						if(food !is null)
						{
							print("greh");
							if(b.server_PutInInventory(food))
							{			
								//Then we needn't do other 2 things.
							}
							else if(b.server_Pickup(food))
							{
								//Blugh
							}
							else
							{
								food.server_RemoveFromInventories();
								food.setPosition(b.getPosition());
							}
						}
						else
						{
							this.server_Hit(this, pos, Vec2f_zero, 1.49f, Hitters::burn);
							b.server_Heal(1.5f);
						}
						healed = true;
					}
						
					int poisonLevel = getPoisonLevel(b);
					if(poisonLevel > 0)
					{
						curePoison(b, 100);
						healed = true;
					}
					if(healed)
					{
						CBlob@ heal = server_CreateBlob("healanimation", b.getTeamNum(), b.getPosition()); //*HUUUCK* HEUUUUUUUUUUUUURHGHHHHHH HUEOOOOOOOOOWLGH *gasp* FRGHAAAAARLGH
						
						b.getSprite().PlaySound("/HealSound.ogg");
						return true;
					}
				}
			}
		}
	}
	return false;
}
