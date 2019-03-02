#include "PotionCommon.as";
#include "PlantCommon.as";
//Apothecary.as

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.Tag("builder always hit");
	this.addCommandID("beginBrewing");
	this.inventoryButtonPos = Vec2f(12, 0);
}

void onTick(CBlob@ this)
{
	u32 brewStart = this.get_u32("brewStart");
	if(brewStart != 0)
	{
		u32 timeBrewing = getGameTime() - brewStart; 
		//Loop through all produce inside inventory.
		CInventory@ inv = this.getInventory();
		if(inv is null)
		{
			this.set_u32("brewStart", 0);
			warn(this.getName() + "'s Inv was null somehow");
			return;
		}
		int itemCount = inv.getItemsCount();
		for(int i = 0; i < itemCount; i++)
		{
			CBlob@ item = inv.getItem(i);
			if(item !is null)
			{
				if(item.hasTag("produce"))
				{
					manageBrewItem(this, item, timeBrewing);
					return;
				}
			}
		}
		//If we got here then we got through all produce. So we set brewStart to 0 because we can.
		this.set_u32("brewStart", 0);
	}
}

void manageBrewItem(CBlob@ this, CBlob@ produce, u32 timeBrewing)
{
	f32 strength = produce.get_f32("strength");
	u32 brewLength = strength * 50;
	if(timeBrewing > brewLength) //Then we are done, brew the item.
	{
		if(getNet().isServer())
		{
			produce.server_Die();
			//Create the potion.
			CBlob@ potion = server_CreatePotion(this.getPosition(),
			getPotionIndexFromPlantKind(produce),
			strength);
		}
		//Reset brewStart
		this.set_u32("brewStart", getGameTime());
	}
}

const u32 goldCost = 30;

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CInventory@ inv = this.getInventory();
	if(inv is null)
	{
		return;
	}
	//Look for produce in inventory.
	int itemCount = inv.getItemsCount();
	bool canCreate = false;
	string desc = "Can't begin brewing yet!";
	u32 brewStart = this.get_u32("brewStart");
	CInventory@ cInv = caller.getInventory();
	if(cInv is null) return;
	if(cInv.getCount("mat_gold") >= goldCost)
	{
		
		if(brewStart == 0)
		{	
			for(int i = 0; i < itemCount; i++)
			{
				CBlob@ item = inv.getItem(i);
				if(item !is null)
				{
					if(item.hasTag("produce"))
					{
						canCreate = true;
						desc = "Begin the brewing process.";
						break;
					}
				}
			}
			if(!canCreate) //Then we didn't hit any thing with the "produce" tag
			{
				desc = "No produce found!";
			}
		}
		else
		{
			canCreate = false;
			desc = "Already brewing some potions!";
		}
	}
	else
	{
		canCreate = false;
		desc = "You need " + goldCost + " gold to be able to catalyze the brewing!";
	}
	
	CBitStream params;
	params.write_netid( caller.getNetworkID() );
	CButton@ button = caller.CreateGenericButton(
		"$mutagen$",
		Vec2f(-6, 0),
		this,
		this.getCommandID("beginBrewing"),
		desc,
		params
	);
	button.SetEnabled(canCreate);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("beginBrewing"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if(caller !is null)
		{
			CInventory@ cInv = caller.getInventory();
			if(cInv !is null)
			{
				cInv.server_RemoveItems("mat_gold", goldCost);
			}
			this.set_u32("brewStart", getGameTime());
			//Activate anim too.
		}
	}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	CBlob@ blob = forBlob.getCarriedBlob();
	return (blob !is null && blob.hasTag("produce")) &&
	(this.get_u32("brewStart") == 0);
}


//Put produce in, push button, and it starts turning produce into potions.
//Time taken to produce potion is equal to the produce' strength.
//When done, create "potion" and set variables to potion that tell you what it does when drunk.
//Set the sprite to be X based on plant's strength.




/*
#include "Requirements.as"
#include "ShopCommon.as";
#include "Descriptions.as";
#include "WARCosts.as";
#include "CheckSpam.as";



void onInit(CBlob@ this)
{	

	
	AddIconsToken( "$antidote$", "Antidote.png", Vec2f(8,8), 0);
	AddIconsToken( "$seedotron$", "SeedOTron.png", Vec2f (32, 32), 0);
	AddIconsToken( "$botanyseed$", "Seed.png", Vec2f(8, 8), 0);
	AddIconsToken( "$tealeaves$", "TeaLeaf.png", Vec2f(8, 8), 0);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Plant Cure", "$antidote$", "antidote", "An antidote for infected plants.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Mutagen", "$mutagen$", "mutagen", "Gives plants the ability to crossbreed!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Tea Seed", "$botanyseed$", "botanyseed", "Tea bush seed to begin your botanical empire!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Sell leaves", "$tealeaves$", "coin-4", "Sell tea leaves for 4 coins", true);
		AddRequirement(s.requirements, "blob", "tealeaf", "Tea Leaf", 1);
		s.spawnNothing = true;
	}
}



void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		if(getNet().isServer())
		{
			u16 caller, item;
			if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			{
				return;
			}
			
			string name = params.read_string();
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			string[] spl = name.split("-");
			
			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				callerPlayer.server_setCoins(callerPlayer.getCoins() + parseInt(spl[1]));
			}
		}
	}
}*/