// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "PotionCommon.as";
#include "PlantCommon.as";
// void onInit(CRules@ this)
// {
// }
// void onCommand( CRules@ this, u8 cmd, CBitStream @params )
// {
// }
bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;

	string name = player.getUsername();
	
	const bool superadmin = getSecurity().getPlayerSeclev(player).getName() == "Super Admin";
	const bool admin = getSecurity().getPlayerSeclev(player).getName() == "Admin";		

	CBlob@ blob = player.getBlob();
	CMap@ map = getMap();
	if (blob is null)
	{
		return true;
	}
	
	string[] command = text_in.toLower().split(" ");
	//commands that don't rely on sv_test
	bool isMod = player.isMod();
	if(isMod)
	{
		if(command[0] == "!forcetime" && command.length >= 2)
		{
			this.set_f32("forceDayTime", parseFloat(command[1]));
			this.Sync("forceDayTime", true);
		}
		else if (text_in == "!debug")
		{
			// print all blobs
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ blob = all[i];
				print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
			}
		}
		else if (text_in == "!bot") // TODO: whoaaa check seclevs
		{
			CPlayer@ bot = AddBot("Henry");
			return true;
		}
	}
	
	

	//spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	if (sv_test)
	{
		if(text_in == "!killall")
		{
			// print all blobs
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ allblob = all[i];
				if(getNet().isServer())
				{
					allblob.server_Hit(allblob, allblob.getPosition(), Vec2f(0, 0), 10.0f, 0);
				}
			}
			return true;
		}
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();

		if (text_in == "!tree")
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
		else if (text_in == "!btree")
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob("Entities/Materials/MaterialStone.cfg", team, pos);

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if (text_in == "!whitepage")
		{
			CBlob@ b = server_CreateBlob("whitepage", team, pos);

			if (b !is null)
			{
				b.server_SetQuantity(5);
			}
		}		
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob("Entities/Materials/MaterialArrows.cfg", team, pos);

				if (b !is null)
				{
					b.server_SetQuantity(60);
				}
			}
		}
		else if (text_in == "!bombs")
		{
			//  for (int i = 0; i < 3; i++)
			CBlob@ b = server_CreateBlob("Entities/Materials/MaterialBombs.cfg", team, pos);

			if (b !is null)
			{
				b.server_SetQuantity(5);
			}
		}
		else if (text_in == "!spawnwater" && isMod)
		{
			map.server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 200);
		}
		else if(command[0] == "!potion" && command.length >= 2)
		{
			int index = getPotionIndex(command[1]);
			f32 strength = 1.0f;
			if(command.length >= 3)
			{
				strength = parseFloat(command[2]);
			}
			if(index != -1)
			{
				CBlob@ pot = server_CreatePotion(blob.getPosition(), index, strength);
			}
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have command

			if (command.length > 1)
			{
				if (command[0] == "!crate")
				{
					int frame = command[1] == "catapult" ? 1 : 0;
					string description = command.length > 2 ? command[2] : command[1];
					server_MakeCrate(command[1], description, frame, -1, Vec2f(pos.x, pos.y));
				}
				else if (command[0] == "!team")
				{
					int team = parseInt(command[1]);
					blob.server_setTeamNum(team);
				}
				else if (command[0] == "!scroll")
				{
					string s = command[1];
					for (uint i = 2; i < command.length; i++)
						s += " " + command[i];
					server_MakePredefinedScroll(pos, s);
				}
			}

			// try to spawn an actor with this name !actor
			
			string name = command[0].substr(1, command[0].size());
			if (server_CreateBlob(name, team, pos) is null)
			{
				//client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
				return true;
			}
			if(isMod && command.length >= 2)
			{
				int number = parseFloat(command[1]);
				for(int i = 1; i < number; i++)
				{
					server_CreateBlob(name, team, pos);
				}
			}
			
		}
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	return true;
}