#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
#include "ZombieCommon.as";
#include "CTF_PopulateSpawnList.as";
#include "HallCommon.as";

//simple config function - edit the variables below to change the basics

const f32 zombieRatio = 0.5f; //errors out if set to 0
const bool pZomsOnInit = false;

void Config(ZombiesCore@ this)
{
	CRules@ rules = getRules();
	// make stats file
	ConfigFile stats;
	string suffix = getMap().getMapName();
	suffix = suffix.substr(0, suffix.length - 4);
	string g_statsFile = "OZFStats/OZFStats_" + suffix;
	ConfigFile global_stats;
	string global_statsFile = "OZFStats/OZFStats_global.cfg";
	
	u32 mapRecord = 0;
	u32 toWriteDays = 0;
	u32 globalRecord = 0;
	
	if(global_stats.loadFile("../Cache/" + global_statsFile))
	{
		if(global_stats.exists("days survived"))
		{
			globalRecord = global_stats.read_u32("days survived");
		}
		else
		{
			warn("Global Record Wasn't found, something is up with where it reads the cache?");
		}
	}
	
	if (stats.loadFile("../Cache/" + g_statsFile)) //if a stats file exists
	{
		if(stats.exists("days survived"))
		{
			mapRecord = stats.read_u32("days survived");
		}
		
	}
	rules.set_u16("globalRecord", globalRecord); //Incase someone lives for more than 255 days *_*
	rules.Sync("globalRecord", true);
	rules.set_u16("mapRecord", mapRecord);
	rules.Sync("mapRecord", true);

	
    rules.set_bool("PlayerZombies", true);
	string configstr = "../Mods/" + sv_gamemode + "/Rules/zombies_vars.cfg";
	if (rules.exists("Zombiesconfig")) {
	   configstr = rules.get_string("Zombiesconfig");
	}
	ConfigFile cfg = ConfigFile( configstr );
	
	//how long for the game to play out?
    s32 gameDurationMinutes = cfg.read_s32("game_time",-1);
    if (gameDurationMinutes <= 0)
    {
		this.gameDuration = 0;
		rules.set_bool("no timer", true);
	}
    else
    {
		this.gameDuration = (getTicksASecond() * 60 * gameDurationMinutes);
	}
	
    bool destroy_dirt = cfg.read_bool("destroy_dirt", true);
	rules.set_bool("destroy_dirt", destroy_dirt);
	bool grave_spawn = cfg.read_bool("grave_spawn",false);
	
	s32 max_zombies = 30;
	s32 max_pzombies = 30;
	s32 max_migrantbots = 2;	
	rules.set_s32("max_zombies", max_zombies);
	rules.set_s32("max_pzombies", max_pzombies);
	rules.set_s32("max_migrantbots", max_migrantbots);
	rules.set_bool("grave_spawn", grave_spawn);
    //spawn after death time 
    this.spawnTime = (getTicksASecond() * cfg.read_s32("spawn_time", 30));
	
}

//Zombies spawn system

const s32 spawnspam_limit_time = 10;

shared class ZombiesSpawns : RespawnSystem
{

    ZombiesCore@ Zombies_core;

    bool force;
    s32 limit;
	
	s16[] tickets = {
	30,
	-1,
	30
	};
	
	void SetCore(RulesCore@ _core)
	{
		setTickets(tickets);
		syncTickets(true);
		RespawnSystem::SetCore(_core);
		@Zombies_core = cast<ZombiesCore@>(core);
		
		limit = spawnspam_limit_time;
		getRules().set_bool("everyones_dead",false);
	}

    void Update()
    {
		int everyone_dead = 0;
		int total_count = Zombies_core.players.length;
		
		CRules@ rules = getRules();
		CMap@ map = getMap();
		f32 mapTime = rules.get_f32("forceDayTime");
		if(mapTime != -1 && Maths::Abs(mapTime - map.getDayTime()) > 0.1f)
		{
			map.SetDayTime(mapTime);
		}
        for (uint team_num = 0; team_num < Zombies_core.teams.length; ++team_num )
        {
            OZFTeamInfo@ team = cast<OZFTeamInfo@>( Zombies_core.teams[team_num] );

            for (uint i = 0; i < team.spawns.length; i++)
            {
                OZFPlayerInfo@ info = cast<OZFPlayerInfo@>(team.spawns[i]);
                
                UpdateSpawnTime(info, i);
				if ( info !is null )
				{
					if (info.can_spawn_time>0) everyone_dead++;
					//total_count++;
				}
                DoSpawnPlayer( info );
            }
        }
		if (getRules().isMatchRunning())
		{
			if (everyone_dead == total_count && total_count!=0) getRules().set_bool("everyones_dead",true); 
			//if (getGameTime() % (10*getTicksASecond()) == 0) warn("ED:"+everyone_dead+" TC:"+total_count);
		}
    }
    
    void UpdateSpawnTime(OZFPlayerInfo@ info, int i)
    {
		if ( info !is null )
		{
			u8 spawn_property = 255;
			
			if(info.can_spawn_time > 0) {
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(200,(info.can_spawn_time / 30)));
			}
			
			string propname = "Zombies spawn time "+info.username;
			
			Zombies_core.rules.set_u8( propname, spawn_property );
			Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) );
		}
	}

	bool SetMaterials( CBlob@ blob,  const string &in name, const int quantity )
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if(inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlob( name );
		if (mat !is null)
		{
			mat.Tag("do not set materials");
			mat.server_SetQuantity(quantity);
			if (!blob.server_PutInInventory(mat))
			{
				mat.setPosition( blob.getPosition() );
			}
		}

		return true;
	}

    void DoSpawnPlayer( PlayerInfo@ p_info )
    {
        if (canSpawnPlayer(p_info))
        {
			//limit how many spawn per second
			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?
			           
			bool undead = player.getTeamNum() == 1;
			
			if(!undead && player.hasTag("zombify")) //Don't untag, it'll stay when player restarts.
			{
				Zombies_core.Zombify(player);
			}
			if(limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}
			
			
            if (player is null)
            {
				RemovePlayerFromSpawn(p_info);
                return;
            }
            if (!undead && player.getTeamNum() != int(p_info.team))
            {
				player.server_setTeamNum(p_info.team);
				warn("Reset player team to: "+p_info.team);
			}		
			// remove previous players blob	  			
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer( null );
				blob.server_Die();					
			}
			
			if (!undead)
			{
				p_info.blob_name = "builder"; //hard-set the survivors respawn blob
			}
			else
			{
				p_info.blob_name = "bonereaper"; //hard-set the undead respawn blob
			}
			
            CBlob@ playerBlob = SpawnPlayerIntoWorld( getSpawnLocation(p_info), p_info);

            if (playerBlob !is null)
            {
                p_info.spawnsCount++;
				if(Zombies_core.rules.isMatchRunning())
				{	
					tickets[p_info.team] --;
				}
				setTickets(tickets);
				syncTickets(true);
                RemovePlayerFromSpawn(player);
				u8 blobfix = player.getTeamNum(); //hacky solution for player blobs not being the team color
				if (playerBlob.getTeamNum()!=blobfix)
				{
					playerBlob.server_setTeamNum(blobfix);
				}

				// spawn resources
				//SetMaterials( playerBlob, "mat_wood", 200 );
				//SetMaterials( playerBlob, "mat_stone", 100 );
            }
        }
    }

    bool canSpawnPlayer(PlayerInfo@ p_info)
    { 
		if(tickets[p_info.team] <= 0 && p_info.team != 1)
		{
			CPlayer@ player = getPlayerByUsername(p_info.username);
			Zombies_core.ChangePlayerTeam( player, 1);
			return false;
		}
		OZFPlayerInfo@ info = cast<OZFPlayerInfo@>(p_info);

        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		//return true;
        //if (force) { return true; }

        return info.can_spawn_time <= 0;
    }

    Vec2f getSpawnLocation(PlayerInfo@ p_info)
    {
        OZFPlayerInfo@ c_info = cast<OZFPlayerInfo@>(p_info);
		u8 team = p_info.team;
		CMap@ map = getMap();
		if(c_info !is null)
        {
			
			if(map !is null)
			{
				CPlayer@ player = getPlayerByUsername(p_info.username);
				if (team == 0 || team == 2) //survivors spawn point
				{
					if(c_info.spawn_point != 0) //If spawn_point is 0 then we want it to spawn at edges of map.
					{
						CBlob@ pickSpawn = getBlobByNetworkID(c_info.spawn_point);
						if (pickSpawn !is null &&
							pickSpawn.hasTag("respawn") && !isUnderRaid(pickSpawn) &&
							pickSpawn.getTeamNum() == p_info.team)
						{
							return pickSpawn.getPosition();
						}
					}
				}
				else if (team == 1) //undead spawn point
				{
					CBlob@[] portals;
					getBlobsByName("undeadstatue", @portals);
					for (int n = 0; n < portals.length; n++)
					if(portals[n] !is null) //check if we still have portals and spawn us there
					{
						ParticleZombieLightning(portals[n].getPosition());
						return Vec2f(portals[n].getPosition()); 
					}										
				}
			}
        }
		f32 x = team == 0 ? 32.0f : map.tilemapwidth * map.tilesize - 32.0f;
		if(map.tilesize == 0)
		{
			warn("DAFUQ?");
			return Vec2f_zero;
		}
		return Vec2f(x, map.getLandYAtX(s32(x/map.tilesize))*map.tilesize - 16.0f);	//in case portals/migrantbots are missing spawn at the edge
    }

    void RemovePlayerFromSpawn(CPlayer@ player)
    {
        RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
    }
    
    void RemovePlayerFromSpawn(PlayerInfo@ p_info)
    {
        OZFPlayerInfo@ info = cast<OZFPlayerInfo@>(p_info);
        
        if (info is null) { warn("Zombies LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

        string propname = "Zombies spawn time "+info.username;
        
        for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			OZFTeamInfo@ team = cast<OZFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				team.spawns.erase(pos);
				break;
			}
		}
		
		Zombies_core.rules.set_u8( propname, 255 ); //not respawning
		Zombies_core.rules.SyncToPlayer( propname, getPlayerByUsername(info.username) ); 
		
		info.can_spawn_time = 0;
	}

    void AddPlayerToSpawn( CPlayer@ player )
    {
		s32 tickspawndelay;
        OZFPlayerInfo@ info = cast<OZFPlayerInfo@>(core.getInfoFromPlayer(player));
		if(!Zombies_core.rules.isMatchRunning())
		{
			tickspawndelay = 0;
		}
		else if (/*player.getDeaths() != 0 && */info.team != 1 && isNightTime())
		{
			int gamestart = getRules().get_s32("gamestart");
			int day_cycle = getRules().daycycle_speed * 60;
			int timeElapsed = ((getGameTime()-gamestart) / getTicksASecond()) % day_cycle;
			tickspawndelay = (day_cycle - timeElapsed) * getTicksASecond();
			//warn("DC: "+day_cycle+" TE:"+timeElapsed);
		}
		else
		{
			tickspawndelay = 160;
			if(info.team == 1 && !isNightTime()) //Less power for zombos during day.
			{
				tickspawndelay *= 4;
			}
		}
		

        if (info is null)
		{
			return;
		}

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;
			
		//print("ADD SPAWN FOR " + player.getUsername()+ "Spawn Delay: " +tickspawndelay);

		if (info.team < Zombies_core.teams.length)
		{
			OZFTeamInfo@ team = cast<OZFTeamInfo@>(Zombies_core.teams[info.team]);
			
			info.can_spawn_time = tickspawndelay;
			
			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
    }

	bool isSpawning( CPlayer@ player )
	{
		OZFPlayerInfo@ info = cast<OZFPlayerInfo@>(core.getInfoFromPlayer(player));
		for (uint i = 0; i < Zombies_core.teams.length; i++)
        {
			OZFTeamInfo@ team = cast<OZFTeamInfo@>(Zombies_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1) {
				return true;
			}
		}
		return false;
	}

};

shared class ZombiesCore : RulesCore
{
	waveInfo[] waveInfos = initWaveInfos();
	
    s32 warmUpTime;
    s32 gameDuration;
    s32 spawnTime;
	s32 timeStage = 0;	

    ZombiesSpawns@ Zombies_spawns;

    ZombiesCore() {}

    ZombiesCore(CRules@ _rules, RespawnSystem@ _respawns )
    {
        super(_rules, _respawns );
    }
    
    void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
    {
        RulesCore::Setup(_rules, _respawns);
        @Zombies_spawns = cast<ZombiesSpawns@>(_respawns);
        server_CreateBlob( "Entities/Meta/WARMusic.cfg" );
		int gamestart = getGameTime();
		rules.set_s32("gamestart",gamestart);
		rules.SetCurrentState(WARMUP);
    }

    void Update()
    {
		
        if (rules.isGameOver()) { return; }
		int max_zombies = rules.get_s32("max_zombies");
		int num_zombies = rules.get_s32("num_zombies");
		int max_pzombies = rules.get_s32("max_pzombies");
		int max_migrantbots = rules.get_s32("max_migrantbots");
		int gamestart = rules.get_s32("gamestart");
		int timeElapsed = getGameTime()-gamestart;
		
		int playerCount = getPlayerCount();
		
		int dayNumber = getDaysSurvived();
		float difficulty = 2.5f * dayNumber; //default 2.0
		if(playerCount < 3)
		{
			difficulty /= float(4 - playerCount);
		}
		float actdiff = 4.5f * dayNumber; //default 4.0
		
		int num_survivors = rules.get_s32("num_survivors"); //newstart survivors
		CBlob@[] survivors_blobs;
			getBlobsByTag("survivorplayer", @survivors_blobs );
			num_survivors = survivors_blobs.length;
			rules.set_s32("num_survivors", num_survivors); //newend	 survivors	
			
		if (actdiff > 13)
		{
			actdiff=13;
			difficulty = difficulty-1.0; 
		}
		else { difficulty = 1.0; } //default actdiff>9
		
		if (rules.isWarmup() && (timeElapsed > getTicksASecond()*60) || (sv_test && timeElapsed>getTicksASecond()*5) )
		{
			rules.SetCurrentState(GAME);
		}
		rules.set_f32("difficulty",difficulty / 3.2); //default 3.0
		int intdif = difficulty;
		if (intdif<=0) intdif=1;
		int spawnRate = Maths::Max(getTicksASecond() * (7 - (difficulty / 6.0f) ), 1);
		
		if (getGameTime() % 200 == 0)
		{
			CBlob@[] zombie_blobs;
			getBlobsByTag("zombie", @zombie_blobs );
			num_zombies = zombie_blobs.length;
			rules.set_s32("num_zombies",num_zombies);
		}
	    if (getGameTime() % (spawnRate) == 0)
        {
			
			CMap@ map = getMap();
			if (map !is null)
			{
				Vec2f[] zombiePlaces;
				rules.SetGlobalMessage("Day " + dayNumber);		
				
				//getMap().getMarkers("zombie spawn", zombiePlaces );
				bool nightTime = isNightTime();
				if(num_zombies < max_zombies)
				{
					{
						u32 x = 32;
						Vec2f left;
						if(!getMap().rayCastSolid( Vec2f(x, 0.0f), Vec2f(x, map.tilemapheight * map.tilesize), left ))
						{
							left = Vec2f(x, 0);
						}
						else
						{
							left.y -= 20;
						}
						zombiePlaces.push_back(left);
						
						Vec2f right;
						x = (map.tilemapwidth * map.tilesize) - 32;
						if(!getMap().rayCastSolid( Vec2f(x, 0.0f), Vec2f(x, map.tilemapheight * map.tilesize), right ))
						{
							right = Vec2f(x, 0);
						}
						else
						{
							right.y -= 20;
						}
						zombiePlaces.push_back(right);
					}
					if (nightTime)
					{
						
						string[] stringInfos = selectStringsToSpawn(dayNumber, false, 2, waveInfos);
						
						for(int i = 0; i < zombiePlaces.length; i++)
						{
							Vec2f sp = zombiePlaces[i];
							string[] stringInfos;
							//start of night
							if(timeStage == 1)
							{
								if (dayNumber % 5 == 0)
								{
									stringInfos = selectStringsToSpawn(dayNumber, true, Maths::Sqrt(dayNumber) * 6, waveInfos);
								}
							}
							else
							{
								stringInfos = selectStringsToSpawn(dayNumber, false, 1, waveInfos);
							}
							
							for(int i = 0; i < stringInfos.length; i++)
							{
								server_CreateBlob(stringInfos[i], 1, sp);
							}
						}
					}
				}
				//timeStage management.
				if(nightTime) //Night start
				{
					if(timeStage == 0) //Night init
					{
						timeStage = 1;
					}
					else if(timeStage == 1) //Constant night
					{
						timeStage = 2;
					}
				}
				else
				{
					if(timeStage == 2) //Day start
					{
						timeStage = 3;
						if(dayNumber % 10 == 0)
						{
							string gradientName = gradientNames[Maths::Min(Maths::Floor(dayNumber / (10.0f + 1)), gradientNames.length - 1)];
							map.CreateSkyGradient( gradientName );
						}
					}
					else if(timeStage == 3) //Constant day
					{
						timeStage = 0;
					}
				}
			}
		}

		
        RulesCore::Update(); //update respawns
        CheckTeamWon();

    }
	string[] gradientNames = {
		"skygradient.png",
		"darkergradient.png",
		"darkerergradient.png"
	};
    //team stuff

    void AddTeam(CTeam@ team)
    {
        OZFTeamInfo t(teams.length, team.getName());
        teams.push_back(t);
    }
	
	u8 getRandomTeam()
	{
		u8 team;
		u32 gameTime = getGameTime();
			
		bool[] hasTickets = { //If we don't use the gameTime thing game returns a null error on nextmap (when there are like 4+ people on)
		gameTime < 100 || Zombies_spawns.tickets[0] > 0,
		true,
		gameTime < 100 || Zombies_spawns.tickets[2] > 0
		};
		
		bool[] possibleTeams = {hasTickets[0], pZomsOnInit, hasTickets[2]};
		
		
		u8[] pseudoTicketCount = {teams[0].players_count, teams[1].players_count / zombieRatio, teams[2].players_count};
		
		//CALCULATE INITIAL SMALLEST INDEX
		//NEEDS TO BE THE LAST POSSIBLE TEAM FOR IMPORTANT REASONS.
		u8 smallestIndex = 0;
		for(int i = possibleTeams.length - 1; i >= 0; i--)
		{
			if(possibleTeams[i])
			{
				smallestIndex = i;
				break;
			}
		}
		
		for(int step = 0; step < pseudoTicketCount.length; step++)
		{
			if(possibleTeams[step] && pseudoTicketCount[step] <= pseudoTicketCount[smallestIndex])
			{
				smallestIndex = step;
			}
			else
			{
				possibleTeams[step] = false;
			}
		}
		
		
		//Can't think of a better way :(
		u8[] teamNums;
		for(int i = 0; i < possibleTeams.length; i++)
		{
			if(possibleTeams[i])
			{
				teamNums.push_back(i);
			}
		}
		
		if(teamNums.length > 0) //actually choose the list of people
		{
			team = teamNums[XORRandom(teamNums.length)];
		}
		else
		{
			//warn("Could not find valid team to choose - defaulting to zombo");
			team = 1;
		}
		return team;
	}
	
    void AddPlayer(CPlayer@ player, u8 team, string default_config = "builder")
    {
        if(team == 0) //decide which team to put the player onto.
		{
			team = getRandomTeam();
		}
		

		PlayerInfo@ check = getInfoFromName(player.getUsername());
		if (check is null)
		{
			OZFPlayerInfo p(player.getUsername(), team, default_config);
			players.push_back(@p);
			ChangeTeamPlayerCount(p.team, 1);
			player.server_setTeamNum(team);
		}
    }
	
	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		if (!rules.isMatchRunning()) { return; }
		
		u8 teamnum = victim.getTeamNum();
		if (victim !is null )
		{
			if(teamnum != 1)
			{
				bool teamDead = true;
				CPlayer@[] CPlayers;
				for(int i = 0; i < players.length; i++)
				{
					PlayerInfo@ p_info = players[i];
					CPlayer@ player = getPlayerByUsername(p_info.username);
					if(player !is null && player.getTeamNum() == teamnum)
					{
						CBlob@ pblob = player.getBlob();
						if(pblob !is null && !pblob.hasTag("dead"))
						{
							teamDead = false;
						}
						CPlayers.push_back(player);
					}
				}
				if(teamDead)
				{
					for(int i = 0; i < CPlayers.length; i++)
					{
						int otherTeam = getOtherTeam(teamnum);
						ChangePlayerTeam( CPlayers[i], otherTeam);
						Zombies_spawns.tickets[otherTeam] += Zombies_spawns.tickets[teamnum];
						Zombies_spawns.tickets[teamnum] = 0;
						setTickets(Zombies_spawns.tickets);
						syncTickets(true);
						rules.SetGlobalMessage( "The " + teams[teamnum].name + " didn't last the night!" );
					}
				}
			}
			if (killer !is null && killer.getTeamNum() == 1)
			{
				addKill(killer.getTeamNum());
				Zombify ( victim );
				if(!killer.hasTag("willingZombie") && victim.getTeamNum() != 1)
				{
					u8 humanKills = killer.get_u8("humanKills");
					humanKills++;
					if(humanKills >= 2)
					{
						Unzombify(killer);
					}
					else
					{
						killer.set_u8("humanKills", humanKills);
					}
					
				}
			}
		}
	}
	
	void Zombify( CPlayer@ player)
	{
		ChangePlayerTeam( player, 1 );
	}
	
	void Unzombify( CPlayer@ player)
	{
		player.Untag("zombify");
		player.Untag("willingZombie"); //justin Case
		ChangePlayerTeam( player, getRandomTeam() );
	}
	
    //checks
    void CheckTeamWon( )
    {
        if(!rules.isMatchRunning()) { return; }
		int num_survivors = rules.get_s32("num_survivors");
		int dayNumber = getDaysSurvived();
		/*if(getRules().get_bool("everyones_dead")) 
		{
            rules.SetTeamWon(1);
			rules.SetCurrentState(GAME_OVER);
            rules.SetGlobalMessage( "You died on day "+ dayNumber+"." );		
			getRules().set_bool("everyones_dead",false); 
		}*/
		if(num_survivors == 0) //
		{
			rules.SetTeamWon(1);
			rules.SetCurrentState(GAME_OVER);
			string globalMessage = "No survivors are left. You survived for "+ dayNumber+" days.";
			
			
			//UPDATE STATS.
			{		
				// make stats file
				ConfigFile stats;
				string suffix = getMap().getMapName();
				suffix = suffix.substr(0, suffix.length - 4);
				string g_statsFile = "OZFStats/OZFStats_" + suffix;
				ConfigFile global_stats;
				string global_statsFile = "OZFStats/OZFStats_global.cfg";
				
				u32 mapRecord = 0;
				u32 toWriteDays = 0;
				u32 globalRecord = 0;
				
				if(global_stats.loadFile("../Cache/" + global_statsFile))
				{
					if(global_stats.exists("days survived"))
					{
						globalRecord = global_stats.read_u32("days survived");
					}
				}
				
				if (stats.loadFile("../Cache/" + g_statsFile)) //if a stats file exists
				{
					if(stats.exists("days survived"))
					{
						mapRecord = stats.read_u32("days survived");
					}
					
				}
				
				{
					if(dayNumber > mapRecord)
					{
						if(dayNumber > globalRecord)
						{
							globalRecord = dayNumber;
							globalMessage += "\n\nNEW GLOBAL RECORD!";
							getRules().set_u16("globalRecord", globalRecord);
						}
						toWriteDays = dayNumber;
						globalMessage += "\n\nNew map record!";
						getRules().set_u16("mapRecord", mapRecord);
					}
					else
					{
						toWriteDays = mapRecord;
						globalMessage += "\n\nNo record was set, Current record: " + mapRecord + "\nCurrent Global Record: " + globalRecord;
					}

					stats.add_u32("days survived", toWriteDays);
					stats.saveFile(g_statsFile);
					
					global_stats.add_u32("days survived", globalRecord);
					global_stats.saveFile(global_statsFile);
		
				}
			}
			
			rules.SetGlobalMessage(globalMessage);
		}
    }

    void addKill(int team)
    {
        if (team < int(teams.length))
        {
            OZFTeamInfo@ team_info = cast<OZFTeamInfo@>( teams[team] );
        }
    }

};

//pass stuff to the core from each of the hooks

void spawnPortal(Vec2f pos)
{
	server_CreateBlob("ZombiePortal", 1,pos+Vec2f(0,-24.0));
}


void spawnGraves(Vec2f pos)
{
	bool grave_spawn = getRules().get_bool("grave_spawn");
	if (grave_spawn)
	{
		int r = XORRandom(8);
		if (r == 0)
			server_CreateBlob("casket2", -1, pos+Vec2f(0,-16.0));
		else if (r == 1)
			server_CreateBlob("grave1", -1, pos+Vec2f(0,-16.0));
		else if (r == 2)
			server_CreateBlob("grave2", -1, pos+Vec2f(0,-16.0));
		else if (r == 3)
			server_CreateBlob("grave3", -1, pos+Vec2f(0,-16.0));
		else if (r == 4)
			server_CreateBlob("grave4", -1, pos+Vec2f(0,-16.0));
		else if (r == 5)
			server_CreateBlob("grave5", -1, pos+Vec2f(0,-16.0));
		else if (r == 6)
			server_CreateBlob("grave6", -1, pos+Vec2f(0,-16.0));
		else if (r == 7)
			server_CreateBlob("casket1", -1, pos+Vec2f(0,-16.0));		
	}
}


void Reset(CRules@ this)
{
    printf("Restarting rules script: " + getCurrentScriptName() );
	this.set_f32("forceDayTime", -1.0f);
	int playerCount = getPlayerCount();
	for(u16 i = 0; i < playerCount; i++)
	{
		CPlayer@ p = getPlayer(i);
		p.Untag("zombify");
	}
    ZombiesSpawns spawns();
    ZombiesCore core(this, spawns);
    Config(core);
	Vec2f[] zombiePlaces;
	getMap().getMarkers("zombie portal", zombiePlaces );
	if (zombiePlaces.length>0)
	{
		for (int i=0; i<zombiePlaces.length; i++)
		{
			spawnPortal(zombiePlaces[i]);
		}
	}
	Vec2f[] gravePlaces;
	getMap().getMarkers("grave", gravePlaces );
	if (gravePlaces.length>0)
	{
		for (int i=0; i<gravePlaces.length; i++)
		{
			spawnGraves(gravePlaces[i]);
		}
	}
	
	//switching all players to survivors on game start
	/*for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.server_setTeamNum(0);
		}
	}*/

    //this.SetCurrentState(GAME);
    
    this.set("core", @core);
    this.set("start_gametime", getGameTime() + core.warmUpTime);
    this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}
