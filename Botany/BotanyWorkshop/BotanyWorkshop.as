// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "MakeBotanySeed.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	this.set_u8("seedTypeMax", 2);
	this.addCommandID("addSeed");
	this.addCommandID("crossBreed");
	this.set_u32("crossBreedingTime", 0);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 3));
	this.set_Vec2f("shop menu size", Vec2f(2, 1)); 
	this.set_string("shop description", "Do things with plants");
	this.set_u8("shop icon", 25);
	
	{
		ShopItem@ s = addShopItem(this, "Coin", "$COIN$", "coin-10", "Sell tea leaves for money.");
		AddRequirement(s.requirements, "blob", "tealeaf", "Tea Leaf", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Coin", "$COIN$", "coin-5", "Sell botany seeds for money.");
		AddRequirement(s.requirements, "blob", "botanyseed", "Seeds", 1);
		s.spawnNothing = true;
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}

void onTick(CBlob@ this)
{
	int crossBreedingTime = this.get_u32("crossBreedingTime");
	if(crossBreedingTime != 0)
	{
		if(crossBreedingTime + 500 < getGameTime()) //Crossbreeding finished.
		{
			this.set_u32("crossBreedingTime", 0);
			//Get information on the 2 seeds we need to crossbreed with.
			invSeedInfo info = getInvSeedInfo(this, null);
			if(info.seeds.length <= 0)
			{
				return;
			}
			//Get averages
			
			f32 averageGrowthSpeed = 0;
			f32 averageProductivity = 0;
			f32 averageStrength = 0;
			for(int i = 0; i < info.seeds.length; i++)
			{
				CBlob@ seed = info.seeds[i];
				averageGrowthSpeed += seed.get_f32("growth_speed");
				averageProductivity += seed.get_f32("productivity");
				averageStrength += seed.get_f32("strength");
				if(getNet().isServer())
				{
					seed.server_Die();
				}
			}
			averageGrowthSpeed /= info.seeds.length;
			averageProductivity /= info.seeds.length;
			averageStrength /= info.seeds.length;
			//onwards.
			
			//Get the plantIndex of crop to crossbreed.
			int[] resultIndexes = mutateWith(info.indexes);
			if(resultIndexes.length > 0) //Success
			{
				if(getNet().isServer())
				{
					CBlob@ seed = server_makeBotanySeed(this.getPosition(),
					resultIndexes[0],
					false,
					averageGrowthSpeed,
					averageProductivity,
					averageStrength);
				}
				this.getSprite().PlaySound("/Thunder1.ogg");
				this.getSprite().PlaySound("yay_cue_small.ogg");
			}
			else// No Success
			{
				this.getSprite().PlaySound("EvilLaughShort1.ogg");
			}
		}
		else
		{
			if(XORRandom(70) == 0)
			{
				Sound::Play("ProduceSound", this.getPosition());
			}
		}
	}
}

const Vec2f[] seedPositions = {
	Vec2f(-7, 0),
	Vec2f(7, 0)
};

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_netid( caller.getNetworkID() );
	CBlob@ blob = caller.getCarriedBlob();
	//Create 2 buttons.
	
	//The buttons need to be different depending on the name of the blob they're associated with.
	//or, if there's nothing associated, make them enabled automatically.
	
	//Get the name of the button - based on seeds inside inv.
	
	invSeedInfo info = getInvSeedInfo(this, blob);
	bool canCrossbreed = true;
	for(int i = 0; i < 2; i++)
	{
		string desc;
		bool enabled;
		if(i < info.names.length) //for adding count to blobs
		{
			int maxStack = info.maxStacks[i];
			desc = "Add another " + info.names[i] + " to the workshop.\n" + info.counts[i] + "/" + maxStack;
			enabled = blob !is null && info.counts[i] < maxStack && blob.getInventoryName() == info.names[i];
			if(info.counts[i] < maxStack)
			{
				canCrossbreed = false;
			}
		}
		else
		{
			canCrossbreed = false;
			if(blob is null)
			{
				desc = "Put seeds in here for crossbreeding.";
				enabled = false;
			}
			else if(info.requestIndex == -3)
			{
				desc = "Can't add the " + blob.getInventoryName() + " for crossbreeding.\n";
				enabled = false;
			}
			else
			{
				enabled = info.requestIndex < 0;
				desc = "Add the " + blob.getInventoryName() + " for crossbreeding.\n";
			}
		}
		CButton@ button = caller.CreateGenericButton(
		"$seed$",
		seedPositions[i],
		this,
		this.getCommandID("addSeed"),
		desc,
		params);
		button.SetEnabled(enabled);
	}
	//Create crossbreed button.
	{
		int crossBreedingTime = this.get_u32("crossBreedingTime");
		string desc;
		
		bool enabled = canCrossbreed;
		if(crossBreedingTime != 0)
		{
			enabled = false;
			desc = "Crossbreeding still in progress!";
		}
		else if(canCrossbreed)
		{
			desc = "Crossbreed the two seeds!";
		}
		else
		{
			desc = "Need more seeds ";
			for(int i = 0; i < info.names.length; i++)
			{
				desc += "\n" + info.names[i] + ": " + info.counts[i] + "/" + info.maxStacks[i];
			}
		}
		CButton@ button = caller.CreateGenericButton(
		"$SeedMerge$",
		Vec2f(0, -3),
		this,
		this.getCommandID("crossBreed"),
		desc);
		button.SetEnabled(enabled);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (getNet().isServer())
		{
			string[] spl = name.split("-");
			
			if (spl[0] == "coin")
			{
				this.getSprite().PlaySound("/ChaChing.ogg");
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
		}
	}
	else if (cmd == this.getCommandID("addSeed"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		if(blob !is null)
		{
			CBlob@ seed = blob.getCarriedBlob();
			if(seed !is null)
			{
				this.server_PutInInventory(seed);
			}
		}
	}
	else if (cmd == this.getCommandID("crossBreed"))
	{
		setCrossBreeding(this);
	}
}

void setCrossBreeding(CBlob@ this)
{
	this.set_u32("crossBreedingTime", getGameTime());
}




//Information on a request to see whether the seed was unique or not.
//Also contains unique names of seed, and the number of seeds.
shared class invSeedInfo
{
	string[] names; //Name of unique seed.
	int[] counts; //Count of unique seed.
	int[] maxStacks; //maxStacks of unique seeds.
	int[] indexes; //Unique plantIndexes of the seeds.
	CBlob@[] seeds; //All the actual seeds inside the blob.
	
	//index of seed passed for info reference.
	//-1 = no index found.
	//-2 = inv was null.
	//-3 = blob was not a seed.
	int requestIndex; 
}

invSeedInfo getInvSeedInfo( CBlob@ this, CBlob@ inventoryBlob )
{
	invSeedInfo info;
	
	
	CInventory@ inv = this.getInventory();
	if(inv !is null)
	{
		//Gather all unique objects inside inventory, and the number of them.
		int seedTypeMax = this.get_u8("seedTypeMax");
		int itemsCount = inv.getItemsCount();
		int seedTypeNum = 0;
		{
			for(int i = 0; i < itemsCount; i++)
			{
				CBlob@ item = inv.getItem(i);
				if(item is null || item.getName() != "botanyseed")
				{
					continue;
				}
				string seedName = item.getInventoryName();
				int itemIndex = findItemIndex(seedName, info.names);
				if(itemIndex == -1) //Then it's not been found yet, add it to info.counts array.
				{
					seedTypeNum += 1;
					info.names.push_back(seedName);
					info.counts.push_back(1);
					info.maxStacks.push_back(item.inventoryMaxStacks);
					info.indexes.push_back(item.get_u8("plantIndex"));
				}
				else //Increment count of that one.
				{
					info.counts[itemIndex]++;
				}
				//Add all seeds just incase we wanna use it outside.
				info.seeds.push_back(item);
			}
		}
		//Get requestIndex of plant.
		if(inventoryBlob is null || inventoryBlob.getName() != "botanyseed")
		{
			info.requestIndex = -3;
			return info;
		}
		else
		{
			int seedCountIndex = findItemIndex(inventoryBlob.getInventoryName(), info.names);
			info.requestIndex = seedCountIndex;
			return info;
		}
	}
	info.requestIndex = -2;
	return info;
}

int findItemIndex(string cropName, string[] names)
{
	for(int i = 0; i < names.length; i++)
	{
		if(cropName == names[i])
		{
			return i;
		}
	}
	return -1;
}

//TODO: Move to plantcommon after finished debugging.
//Returns the indexes of any blobs the plant might mutate with.
int[] mutateWith(int[] indexes)
{
	int[][] mutagens;
	//Loop through every index and get their mutagens.
	
	for(int i = 0; i < indexes.length; i++)
	{
		//Add all the individual mutagens to the array.
		int index = indexes[i];
		int[][] iMutagen = getMutagens(index);
		for(int iMutagenIndex = 0; iMutagenIndex < iMutagen.length; iMutagenIndex++)
		{
			mutagens.push_back(iMutagen[iMutagenIndex]);
		}
	}
	int[] resultIndexes;
	//Then loop through every blob again and compare the mutagens with the indexes.
	//If any of the indexes match the mutagens, then add the result index to the array.
	for(int i = 0; i < indexes.length; i++)
	{
		int index = indexes[i];
		for(int mutagenIndex = 0; mutagenIndex < mutagens.length; mutagenIndex++)
		{
			int[] mutagen = mutagens[mutagenIndex];
			
			if(mutagen[0] == index) //Then we have a match.
			{
				resultIndexes.push_back(mutagen[1]);
			}
		}
	}
	return resultIndexes;
}