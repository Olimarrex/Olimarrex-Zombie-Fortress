//ZombieCommon.as
#include "zombies_Rules.as";
shared int getDaysSurvived()
{
	CRules@ rules = getRules();
	int gamestart = rules.get_s32("gamestart");
	f32 day_cycle = rules.daycycle_speed * 60.0f;
	int dayNumber = ((getGameTime() - gamestart) / getTicksASecond() / day_cycle) + 1;
	return  dayNumber;
}

shared bool isNightTime()
{
	CMap@ map = getMap();
	CRules@ rules = getRules();
	f32 daytime = map.getDayTime();
	return (!(daytime > 0.25f && daytime < 0.75f)) || rules.hasTag("alwaysNight");
}

//This way I can sync tickets.
const u8 teamNum = 3; //Is probably a better way to do this.
shared s16[] getTickets()
{
	CRules@ this = getRules();
	s16[] tickets;
	for(int i = 0; i < teamNum; i++)
	{
		tickets.push_back(this.get_s16("tickets" + i));
	}
	return tickets;
}

shared void setTickets(s16[] tickets)
{
	CRules@ this = getRules();
	for(int i = 0; i < teamNum; i ++)
	{
		this.set_s16("tickets" + i, tickets[i]);
	}
}

shared void syncTickets(bool server)
{
	CRules@ this = getRules();
	for(int i = 0; i < teamNum; i ++)
	{
		this.Sync("tickets" + i, server);
	}
}

shared class waveInfo
{
	string name;
	int weight;
	int minWave;
	int maxWave;
	bool pZombie;
	waveInfo(string _name, int _weight, int _minWave, int _maxWave, bool _pZombie)
	{
		name = _name;
		weight = _weight;
		minWave = _minWave;
		maxWave = _maxWave;
		pZombie = _pZombie;
	}
}

shared waveInfo[] initWaveInfos()
{
	waveInfo[] infos = {
	//			Name, 		 chance,  minwave, maxwave, p wave specific zombie
		waveInfo("zchicken",		70, 	0, 	7,	false),
		waveInfo("catto",			50, 	1, 	15,	false),
		waveInfo("skeleton", 		40, 	3, 	18,	false),
		waveInfo("gasbag", 			20, 	5, 	20,	false),
		waveInfo("zombie", 			60, 	6,	30,	false),
		waveInfo("zbison", 			20, 	6, 	60,	false), //TODO: make these bois WAY more strong.
		waveInfo("landwraith", 		10, 	7, 	-1,	false),
		waveInfo("greg", 			10, 	9, 	-1,	false),
		waveInfo("wraith", 			5, 		8,	-1,	false),
		waveInfo("zombieknight",	20, 	10, -1,	false),
		waveInfo("zombieknight",	40, 	18,	-1,	false),
		
		//Zombies that spawn on the major waves (pZombies)
		waveInfo("pankou", 			15,		4,	-1,	true),
		waveInfo("pbrute", 			10,		4,	-1,	true),
		waveInfo("pgreg", 			7,		9,	-1,	true),
		waveInfo("horror", 			10,		14,	-1,	true),
		waveInfo("phellknight", 	5,		14,	-1,	true),
		waveInfo("pbanshee", 		5,		19, -1,	true),
		waveInfo("abomination", 	2, 		24,	-1,	true),
		waveInfo("abomination", 	20,		34,	-1,	true)
	};
	return infos;
}

shared string[] selectStringsToSpawn(int wave, bool isPWave, int number, waveInfo[] waveInfos)
{
	int totalWeight = 0;
	waveInfo[] selectedInfos;
	for(int i = 0; i < waveInfos.length; i++)
	{
		waveInfo info = waveInfos[i];
		if(!isPWave xor info.pZombie)
		{
			if(wave > info.minWave && (wave < info.maxWave || info.maxWave == -1))
			{
				selectedInfos.push_back(info);
				totalWeight += info.weight;
			}
		}
	}	
	
	string[] blobs;
	for(int i = 0; i < number; i++)
	{
		int weightToSelect = XORRandom(totalWeight);
		int num = 0;
		for(int j = 0; j < selectedInfos.length; j++)
		{
			waveInfo info = selectedInfos[j];
			num += info.weight;
			if(weightToSelect <= num)
			{
				blobs.push_back(info.name);
				break;
			}
		}
	}
	return blobs;
}

shared int getOtherTeam(int curTeam)
{
	return Maths::Abs(curTeam - 2);
}
shared int canZombify(bool willing)
{
	CRules@ rules = getRules();
	int playerCount = getPlayersCount();
	ZombiesCore@ core;
	getRules().get("core", @core);
	int zombieCount = core.teams[1].players_count; //ZOMBIE TEAM PLAYER COUNT.
	int zombieRation = ( (zombieCount * 3.0f) + 4 );
	if(!(playerCount - zombieRation > 0) || !willing)
	{
		return zombifyStatus::playerCount;
	}
	else if(getDaysSurvived() < 5)
	{
		return zombifyStatus::time;
	}
	else
	{
		return zombifyStatus::allowed;
	}
}
string[] zombifyString = {
	"Bury Yourself",
	"Don't abandon your small team!",
	"It's too soon to bury yourself!"
};
namespace zombifyStatus 
{
	shared enum status
	{
		allowed = 0,
		playerCount,
		time
	};
}










//Greh