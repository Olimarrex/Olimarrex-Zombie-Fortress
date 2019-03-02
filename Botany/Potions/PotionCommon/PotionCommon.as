#include "PlantCommon.as";
#include "PotionFunctions.as";
namespace potionTypes
{
	shared enum index
	{
		brew = 0,
		elixir,
		poison,
		remedy
	};
}

//Issues reaching this inside other shared classes.
//Could fix EZ by adding a shared function that retrieves potionTypeInfos.
shared class potionTypeInfo
{
	string prefixName;
	string suffixName;
	potionTypeInfo(string _prefixName, string _suffixName)
	{
		prefixName = _prefixName;
		suffixName = _suffixName;
	}
}

shared class potionInfo
{
	string scriptName;
	string potionName;
	string configName; //used when trying to find a potion by name. - jus' like blob config name
	int typeIndex;
	potionCallback@ startFunc;
	potionCallback@ endFunc;
	int durationFactor;
	
	potionInfo
	(string _scriptName,
	string _potionName,
	string _configName,
	int _typeIndex,
	potionCallback@ _startFunc = null,
	potionCallback@ _endFunc = null,
	int _durationFactor = 0)
	{
		scriptName = _scriptName;
		potionName = _potionName;
		configName = _configName;
		typeIndex = _typeIndex;
		startFunc = _startFunc;
		endFunc = _endFunc;
		durationFactor = _durationFactor;
	}
	
	string getScriptName()
	{
		return scriptName;
	}
	string getPotionName()
	{
		return potionName;
	}
	int getTypeIndex()
	{
		return typeIndex;
	}
	u32 getPotionDuration(f32 strength)
	{
		return strength * durationFactor;
	}
}


CBlob@ server_CreatePotion(Vec2f pos, int potionIndex, f32 strength)
{
	CBlob@ potion = server_CreateBlobNoInit("potion");
	potion.setPosition(pos);
	potion.server_setTeamNum(-1);
	
	potion.set_u16("potionIndex", potionIndex);
	potion.set_f32("strength", strength);
	return potion;
}

//RETRIEVING POTION VARIABLES ON POTION DRINKERS
string potStrName(int index)
{
	return "potionStrength " + index;
}
string potTimeName(int index)
{
	return "potionTimerTime " + index;
}

f32 getPotionStrength(CBlob@ this, int index)
{
	string strName = potStrName(index);
	if(this.exists(strName))
	{
		return this.get_f32(strName);
	}
	else
	{
		warn("pot Strength Name not found for potion index: " + index);
		return 1.0f;
	}
}

u32 getPotionTime(CBlob@ this, int index)
{
	return this.get_u32(potTimeName(index));
}

//THE BIG ONE
//MUST BE CALLED BOTH CLIENT AND SERBER.
void drinkPotion(CBlob@ potion, CBlob@ drinker)
{
	potionInfo info = getPotionInfo(potion);
	string scriptName = info.getScriptName();
	int type = info.getTypeIndex();
	u16 potionIndex = potion.get_u16("potionIndex");
	f32 strength = potion.get_f32("strength");
	//Get Potion strength.
	if(info.startFunc !is null)
	{
		info.startFunc(drinker, strength);
		for(int i = 0; i < 10; i++)
		{
			effectParticle(drinker);
		}
	}
	if(scriptName != "")
	{
		//OOF to fix issues with script order.
		drinker.RemoveScript("FleshHit.as");
		drinker.AddScript(scriptName);
		drinker.AddScript("FleshHit.as");
	}
	drinker.set_f32(potStrName(potionIndex), strength);
	drinker.set_u32(potTimeName(potionIndex), getGameTime());
	int[] activePotions;
	drinker.get("activePotions", activePotions);
	activePotions.push_back(potionIndex);
	drinker.set("activePotions", activePotions);
}

int getPotionIndex(string configName)
{
	for(int i = 0; i < potions.length; i++)
	{
		potionInfo info = getPotionInfo(i);
		if(info.configName == configName)
		{
			return i;
		}
	}
	return -1;
}
//Ways to retrieve potionInfo.
potionInfo getPotionInfo(CBlob@ this)
{
	return getPotionInfo(this.get_u16("potionIndex"));
}

potionInfo getPotionInfoFromPlantKind(CBlob@ this)
{
	return getPotionInfo(getPotionIndexFromPlantKind(this));
}

potionInfo getPotionInfo(int potionIndex)
{
	return potions[potionIndex];
}


//REMEDY POTION EFFECTS

//So we don't gotta fuck around with adding a script just to do one thing,
//then remove script immediately.

funcdef void potionCallback( CBlob@, f32 );





/*potionTypeInfo[] potionTypeInfos =
{
	potionTypeInfo("Brew of ", " brew"),
	potionTypeInfo("Elixir of ", ""),
	potionTypeInfo("Poison of ", " poison"),
	potionTypeInfo("Remedy of ", " remedy")
};*/

namespace potionIndex
{
	shared enum index
	{
		nothing = 0,
		regenerate,
		toxic,
		poisonRes,
		nightVis,
		spitSeeds,
		antiGravity,
		heal,
		damageRes
	};
}
//Startfunc, endfunc, duration
potionInfo[] potions =
{
	potionInfo("", "Mundane Water", "nothing", potionTypes::remedy),
	potionInfo("RegenerationBrew.as", "Brew of Regeneration", "regenerate", potionTypes::brew, null, null, 600),
	potionInfo("ToxicPoison.as", "Blade Poison of Foul Play", "toxic", potionTypes::poison, null, null, 200),
	potionInfo("", "Brew of Poison Resistance", "poisonres", potionTypes::brew, @poisonResStart, @poisonResEnd, 1200),
	potionInfo("", "Elixir of Night Vision", "nightvis", potionTypes::elixir, @nightVisStart, @nightVisEnd, 700),
	potionInfo("SpitSeedsElixir.as", "Seed Spitter's Elixir", "spitseeds", potionTypes::elixir, null, null, 300),
	potionInfo("AntiGravityPoison.as", "Blade Poison of AntiGravity", "antigravity", potionTypes::poison, null, null, 200),
	potionInfo("", 	"Remedy of Healing", "heal", potionTypes::remedy, @healStart),
	potionInfo("DamageResElixir.as", "Elixir of Rockskin", "rockskin", potionTypes::elixir, null, null, 1000)
};

void effectParticle(CBlob@ this)
{
	Vec2f randVec =  getRandomVelocity(0, 6, 360);
	ParticleAnimated("PotionEffect.png", this.getPosition() + randVec, randVec / 15, XORRandom(360), 1, 26, -0.1f, false);
}