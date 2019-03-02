#include "ZombieCommon.as";
#include "SunlightCommon.as";
#include "PotionCommon.as";
const u8 max_level = 140; //Max water level.
void initPlant(CBlob@ this, u8 plantIndex)//All de variabrus that plants hab!
{
	if(!this.exists("growth_stage"))
	this.set_u16("growth_stage", 0);
	
	//These are always the same now.
	this.set_f32("growth_speed", 1);
	
	this.set_f32("strength", 1); //Decides health and vulnerability to infection
	
	this.set_f32("productivity", 1);
	
	this.set_u8("plantIndex", plantIndex);
}
void initSeed(CBlob@ this)//All de variabrus that Seebs hab!
{
		if(!this.exists("growth_speed"))
		{
			this.set_f32("growth_speed", 5); //Speed of growth! The higher the number, the slower it grows.
		}
		if(!this.exists("strength"))
		{
			this.set_f32("strength", 5); //The strength of the seed. Ofc is float. Decides it's vulnerability to poison, and possibly it's max water level?
		}
		if(!this.exists("productivity"))
		{
			this.set_f32("productivity", 5); //The number of things it'll produce, it's a float because of mutation.
		}
}
void initProduceVars(CBlob@ crop, CBlob@ produce)
{
	copyMutation(crop, produce, true);
	produce.set_u8("plantIndex", crop.get_u8("plantIndex"));
	produce.Sync("plantIndex", true);
}
void copyMutation(CBlob@ this, CBlob@ newBlob, bool mutate, bool sync = true)
{
	f32 growth_speed = this.get_f32("growth_speed");
	f32 strength = this.get_f32("strength");
	f32 productivity = this.get_f32("productivity");
	if(mutate) //Add some randomness for evolution simulation
	{
		growth_speed = Mutate(growth_speed);
		strength = Mutate(strength);
		productivity = Mutate(productivity);
	}
	newBlob.set_f32("growth_speed", growth_speed);
	newBlob.set_f32("strength", strength);
	newBlob.set_f32("productivity", productivity);
	if(sync)
	{
		newBlob.Sync("growth_speed", true);
		newBlob.Sync("strength", true);
		newBlob.Sync("productivity", true);
	}
}

void setPlantIndex(CBlob@ blob, int plantIndex)
{
	blob.set_u8("plantIndex", plantIndex);
}

float Mutate(float origin)
{
	float extra = origin;
	extra /= 13.0f;
	extra += 0.06f; //Minimum of 0.06 + very small number.
	if(XORRandom(2) == 0) //50/50 chance of being pos/neg. It's just easier to fiddle with this way 
	{
		extra = -extra;
	}
	origin += extra;
	origin = Maths::Clamp(origin, 0.0f, 10.0f);
	if(origin < 0) //Prevent backwards-overflow errors. It's a float atm, but switches when outside 	.
	{
		return 0;
	}
	return origin;
}
CBlob@ server_CreateProduce(string produce, u8 teamNum, Vec2f pos, CBlob@ this)
{
	CBlob@ b = server_CreateBlob(produce, teamNum, pos);
	b.Tag("produce"); //Important for differeing between produce and seeds!
	b.set_u8("plantIndex", this.get_u8("plantIndex"));
	b.set_f32("strength", this.get_f32("strength"));
	//Currently trying to use seeds instead.
	/*if(b !is null) //Set variables incase it gets turned into a "cutting". This could lead to some hilarious stuff, like, if produce was a bomb, then you could harvest the bomb plant, and would have to rush to turn it into a seed before it blew you up. xD
	{
		initProduceVars(this, b);
	}*/
	
	return b;
}
u8 getStatus(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	if(this.hasTag("virus"))
	{
		return 0;
	}
	else
	{
		
		if(getWaterLevel(this) < 2)//Dry
		{
			return 1;
		}
		
		//isInDaylight is expensive - should cache?
		if(!isInDaylight(this) xor this.hasTag("growsInDarkness"))
		{
			return 2;
		}
	}
	return 255;
}
bool hasVirus(CBlob@ blob)
{
	return blob.hasTag("virus");
}

namespace plantIndex
{
	shared enum index
	{
		standard = 0,
		tea,
		splintling,
		strawberry,
		qaziq,
		goldberry,
		cragval,
		tomato,
		iorn,
		grain,
		toxicshroom,
		mushroom,
		glowshroom,
		shellberry,
		herb
	};
}

//Statistics for the factor of plant growth. This is where you decide different qualities of plants.
//Can't do in-line array declarations inside constructors. ffs
shared int[][] getAnnoyingDeclarationIssue(int i) {
	int[][] nullArray;
	int[][][] annoyingShit = {
		nullArray, //standard
		nullArray, //Tea
		nullArray, //splintling
		nullArray, //Strawberry
		{{plantIndex::tea, plantIndex::goldberry}}, //Qaziq
		nullArray, //GoldBerry
		nullArray, //Cragval
		nullArray, //Tomato
		nullArray, //Iorn
		nullArray, //Grain
		{{plantIndex::grain, plantIndex::mushroom}}, //Toxic Shroom
		{{plantIndex::grain, plantIndex::shellberry}, {plantIndex::toxicshroom, plantIndex::glowshroom}}, //Mushroom
		nullArray, //Glow Shroom
		{{plantIndex::glowshroom, plantIndex::herb}, {plantIndex::toxicshroom, plantIndex::qaziq}}, //Shellberry
		{{plantIndex::shellberry, plantIndex::tea}}, //Herb
	};
	if(i <= annoyingShit.length - 1)
	{
		return annoyingShit[i];
	}
	else
	{
		warn("Damn off by one errors : " + i + " was larger than " + annoyingShit.length);
		return annoyingShit[0];
	}
};
int i = 0;
const plantStats[] plantStatList = {
	plantStats(				//"Standard"
		250,						//Growth speed
		10,							//productivity
		1,							//strength
		125,						//seednum
		"knight",					//produce blobname
		"building",					//plant blobname
		"Bugged Seed",				//seednum
		i++,						//Mutagen array
		potionIndex::nothing		//Potion index
	),
	plantStats				//Tea
	(
		1400,						//Growth speed
		1, 							//productivity
		4,							//strength
		140,						//seednum
		"tealeaf",					//produce blobname
		"tea",						//plant blobname
		"Tea Seed",					//seednum
		i++,						//Mutagen array
		potionIndex::nothing		//Potion index
	),
	plantStats(850, 	1, 		1, 		280, 	"log",				"splintling",		"Splintling Seed",	i++,	potionIndex::nothing),		//splintling
	plantStats(1900, 	1, 		1, 		230, 	"strawberryfruit",	"strawberry",		"strawberry Seed",	i++,	potionIndex::nothing),		//Strawberry
	plantStats(1900, 	1, 		1, 		230, 	"pebble",			"qaziq",			"Qaziq Seed",		i++,	potionIndex::damageRes),	//Qaziq
	plantStats(760, 	0.7f,	1, 		172, 	"goldpebble",		"goldberry",		"Goldberry Seed",	i++,	potionIndex::antiGravity),	//GoldBerry
	plantStats(1400, 	1, 		1, 		182, 	"boulder",			"cragval",			"Cragval Seed",		i++,	potionIndex::nothing),		//Cragval
	plantStats(150, 	1.5f, 	1, 		222, 	"tomatofruit",		"tomato",			"Tomato Seed",		i++,	potionIndex::nothing),		//Tomato
	plantStats(150,		5, 		1, 		197, 	"pebble",			"iorn",				"Iorn Seed",		i++,	potionIndex::nothing),		//Iorn
	plantStats(650,		1, 		1, 		230, 	"grain",			"grain_plant",		"Grain Seed",		i++,	potionIndex::poisonRes),	//Grain
	plantStats(1200,	1,		1,		196, 	"toxiccap",			"tshroom",			"Toxic Spore",		i++,	potionIndex::toxic),		//Toxic Shroom
	plantStats(1950,	1,		1,		190,	"truffle",			"shroom",			"Red Spore",		i++,	potionIndex::regenerate),	//Mushroom
	plantStats(900, 	1,		1, 		149, 	"glowcap",			"glowshroom",		"Glowy Spore", 		i++,	potionIndex::nightVis),		//Glow Shroom
	plantStats(2400, 	1,		1, 		230, 	"shellberry",		"shellberryplant",	"Shellberry Seed",	i++,	potionIndex::spitSeeds),	//Shell Berry
	plantStats(1400, 	1,		1, 		219, 	"herbleaf",			"herbplant",		"Herb Plant",		i++,	potionIndex::heal),			//Herb
};

shared class plantStats
{
	float growthSpeed;
	float productivity;
	float strength;
	float seedNum;
	string produceName;
	string plantName;
	string seedName;
	int[][] mutagens;
	int potionIndex;
	//TODO: string seedName;
	plantStats(float _growthSpeed, float _productivity, float _strength, float _seedNum, string _produceName, string _plantName, string _seedName, int i, int _potionIndex)
	{
		growthSpeed = _growthSpeed;
		productivity = _productivity;
		strength = _strength;
		seedNum = _seedNum;
		produceName = _produceName;
		plantName = _plantName;
		seedName = _seedName;
		mutagens = getAnnoyingDeclarationIssue(i);
		potionIndex = _potionIndex;
	}
}

//TODO: add an Existance check for these.

int[][] getMutagens(CBlob@ this)
{
	return getMutagens(getIndex(this));
}
int[][] getMutagens(int index)
{
	return plantStatList[index].mutagens;
}

f32 getGrowthSpeed(CBlob@ this)
{
	return getGrowthSpeed(this, getIndex(this));
}
f32 getGrowthSpeed(CBlob@ this, int index)
{
	f32 speed = this.get_f32("growth_speed");
	speed = plantStatList[index].growthSpeed / speed;
	//print("Total Speed: " + speed);
	return speed;
}

f32 getProductivity(CBlob@ this)
{
	return getProductivity(this, getIndex(this));
}
f32 getProductivity(CBlob@ this, int index)
{
	f32 productivity = this.get_f32("productivity");
	productivity *= plantStatList[index].productivity;
	return productivity;
}

f32 getStrength(CBlob@ this)
{
	return getStrength(this, getIndex(this));
}

f32 getStrength(CBlob@ this, int index)
{
	f32 strength = this.get_f32("strength");
	strength *= plantStatList[index].strength;
	return strength;
}
/**
Seed Num works like this:
First the plant always produces 1 seed.
Then it gets XORRandom(SeedNum)
Then it divides it by 64 and rounds it.
this means if you choose 72 then there's a 1 in 5 chance of producing a seed.
if you choose 6 then there's a 2 in 6 chance.
if you choose 13 then there's a 1 in 13 chance of getting 2 extra, and like an 8 in 13 chance of getting 1 extra.
**/
f32 getSeedNum(CBlob@ this)
{
	return getSeedNum(getIndex(this));
}
f32 getSeedNum(int index)
{
	f32 seedNum = Maths::Round(XORRandom(plantStatList[index].seedNum) / 100.0f);
	return seedNum;
}

string getProduce(CBlob@ this)
{
	return getProduce(getIndex(this));
}
string getProduce(int index)
{
	string name = plantStatList[index].produceName;
	return name;
}

string getBlobName(CBlob@ this)
{
	return getBlobName(getIndex(this));
}
string getBlobName(int index)
{
	string name = plantStatList[index].plantName;
	return name;
}

string getSeedName(CBlob@ this)
{
	return getSeedName(getIndex(this));
}
string getSeedName(int index)
{
	string seedname = plantStatList[index].seedName;
	return seedname;
}

int getPotionIndexFromPlantKind(CBlob@ this)
{
	return getPotionIndexFromPlantKind(getIndex(this));
}

int getPotionIndexFromPlantKind(int index)
{
	int potionIndex = plantStatList[index].potionIndex;
	return potionIndex;
}

int getIndex(CBlob@ this)
{
	u8 index = this.get_u8("plantIndex");
	if(index >= plantStatList.length)
	{
		warn("plant Index: " + index + " does not have a seed index! Defaulting to standard");
		index = plantIndex::standard;
	}
	return index;
}

u8 getWaterLevel(CBlob@ this)
{
	if(!this.exists("water_level"))
	{
		return 254;
	}
	else
	{
		return(this.get_u8("water_level"));
	}
	return 0;
}

//Mutagens

bool canAddMutagen(CBlob@ this, CBlob@ mutagen)
{
	return true;
}

void addMutagen(CBlob@ this, CBlob@ mutagen)
{
	if(getNet().isClient())
	{
		createMutagenLayer(this, mutagen);
	}
	this.Tag("crossbred");
	this.set_u8("mutagen_plantIndex", mutagen.get_u8("plantIndex"));
	//this.set_u32("mutagenTime", getGameTime()); //Not necessary atm.
}

void createMutagenLayer(CBlob@ this, CBlob@ mutagen)
{
	CSprite@ sprite = this.getSprite();
	CSprite@ mutaSprite = mutagen.getSprite();
	if(sprite is null || mutaSprite is null)
		return;
		
	//Copy sprite details.
	CSpriteLayer@ mutagenLayer = sprite.addSpriteLayer(
	"mutagen",
	mutaSprite.getFilename(),
	mutaSprite.getFrameWidth(),
	mutaSprite.getFrameHeight());
	mutagenLayer.SetVisible(true);
	mutagenLayer.SetFrame(mutaSprite.getFrame());
	mutagenLayer.SetRelativeZ(2);
}

