// Bandit logic

#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "MaterialCommon.as";
#include "CommonReaperBlocks.as";
#include "BuildBlock.as";
#include "Requirements.as";
#include "Costs.as";
#include "TileCommon.as";

u8 hit_frame = 2;

void onInit(CBlob@ this)
{
	BuildBlock[][] blocks;
	addCommonBuilderBlocks(blocks);
	this.set(blocks_property, blocks);
	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("undeadplayer");
	this.Tag("flesh");
	this.addCommandID("smack");

	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.set_bool("JustBit", false);
}

void damageTile(CBlob@ this, Vec2f pos, CMap@ map, u8 hitter, int _damge_ = 1)
{
	for(int i = 0; i < _damge_; i++)
	{
		map.server_DestroyTile(pos, 0.1f, this);
	}
	if(hitter == Hitters::fire)
	{
		map.server_setFireWorldspace(pos, true);
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 2, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	const bool ismyplayer = this.isMyPlayer();
	CSprite@ sprite = this.getSprite();
	// no damage cause we just check hit for cursor display

	
	if(ismyplayer && sprite.isAnimation("bite"))
	{
		bool justCheck = !sprite.isFrameIndex(hit_frame);
		bool adjusttime = sprite.getFrameIndex() < hit_frame - 1;
		if (!adjusttime)
		{
			if (!justCheck)
			{
				smackCommand(this);
			}
		}
	}
	
	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	// if (!getNet().isClient()) return;

	// if (this.isInInventory()) return;

	// RunnerMoveVars@ moveVars;
	// if (!this.get("moveVars", @moveVars))
	// {
		// return;
	// }
}

void smackCommand(CBlob@ this)
{
	this.SendCommand(this.getCommandID("smack"));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("smack"))
	{
		bite(this);
	}
}

void bite(CBlob@ this)
{
	if(getNet().isServer())
	{
		CMap@ map = this.getMap();
		Vec2f pos = this.getPosition();
		
		const f32 radius = this.getRadius();
		const f32 attack_distance = radius + 5;
		
		Vec2f vec = this.getAimPos() - pos;
		f32 angle = vec.Angle();
		
		u8 team = this.getTeamNum();
		
		HitInfo@[] hitInfos;
		if (map.getHitInfosFromArc(pos, -angle, 100.0f, radius + attack_distance, this, @hitInfos))
		{
			for(uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				
				if(hi.blob !is null)
				{
					this.server_Hit(hi.blob, pos, this.getVelocity(), 0.75f, Hitters::muscles);
					if(hi.blob.hasTag("flesh") && hi.blob.getTeamNum() != team)
					{
						Material::createFor(this, 'mat_bones', 10.0f);
						this.server_Heal(0.5f);
					}
				}
				//if(moddedIsTileSolid(map, hi.tile))
				{ 
					if(moddedIsTileSolid(map, hi.tile) && !map.isTileGroundStuff(hi.tile))
					{
						SetKnocked(this, 50);
					}
					damageTile(this, hi.hitpos, map, 1);
				}
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
}
/*
CPlayer@ p = getPlayerByUsername('ollimarrex'); CBlob@ s = server_CreateBlob('bonereaper', 1, p.getBlob().getPosition()); p.getBlob().server_Die(); s.server_SetPlayer(p);
*/