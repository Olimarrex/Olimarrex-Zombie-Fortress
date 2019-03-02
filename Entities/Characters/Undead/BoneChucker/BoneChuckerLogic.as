// Bandit logic

#include "ThrowCommon.as"
#include "Knocked.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "BombCommon.as";
#include "BoneChuckerCommon.as";

const u16 maxPower = 100.0f;
const f32 shootRatio = 30.0f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", 0.0f);
	this.Tag("player");
	this.Tag("undeadplayer");
	this.Tag("flesh");

	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
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
	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	u8 team = this.getTeamNum();
	CPlayer@ player = this.getPlayer();
	bool ismyplayer = this.isMyPlayer();
	int frame = 0;
	u16 shootTime = getShotStrength(this);
	
	const bool onLand = (this.isOnGround() || this.isOnLadder() || this.isInWater());
	bool dashed = this.get_bool("dashed");
	
	if(dashed && onLand)
	{
		dashed = false;
		this.set_bool("on land", dashed);
	}

	
	if(this.isKeyPressed(key_action1))
	{
		if(shootTime % shootRatio == 0 && shootTime > 0)
		{
			this.server_Hit(this, this.getPosition(), this.getVelocity(), 0.5f, Hitters::crush);
			this.getSprite().PlaySound("SkeletonSpawn" + (XORRandom(2) + 1) + ".ogg", 3.0f);
		}
		this.set_u16("shootTime", shootTime + 1);
		frame = Maths::Min(9, Maths::Floor(shootTime / shootRatio) * 2);
	}
	else if(this.isKeyPressed(key_action2))
	{
		this.set_u16("shootTime", Maths::Min(maxPower, shootTime + 1));
		frame = (float(shootTime) / float(maxPower)) * 10.0f;
	}
	
	u32 healTime = getGameTime() - this.get_u32("healStartedTime");
	if(healTime > 160)
	{
		if(healTime % 60 == 0)
		{
			if(this.getHealth() < this.getInitialHealth())
			{
				this.server_Heal(0.5f);
				this.getSprite().PlaySound("heart.ogg");
			}
		}
	}
	//frame = Maths::Min((healTime / 120.0f) * 10.0f, 10);
	
	if(this.isKeyJustReleased(key_action1))
	{
		if(getNet().isServer() && shootTime > 0)
		{
			int power = Maths::Floor((shootTime - 1) / shootRatio);
			for(int i = 0; i < power * 2; i++)
			{
				CBlob@ bone = server_CreateBlob("bone", team, pos);
				if(bone !is null)
				{
					if(player !is null)
					{
						bone.SetDamageOwnerPlayer(player);
					}
					Vec2f vel = getNormAimVel(this);
					vel *= 9 + (XORRandom(10) / 30.0f);
					vel.RotateBy(XORRandom(11) - 5);
					bone.setVelocity(vel);
				}
			}
		}
		this.set_u16("shootTime", 0);
	}
	else if(this.isKeyJustReleased(key_action2))
	{
		f32 power = (float(shootTime) / float(maxPower)) * 10.0f;
		if(power > 3)
		{
			Vec2f vel = getNormAimVel(this) * (power + 2.0f);
			this.setVelocity(vel);
		}
		this.set_u16("shootTime", 0);
	}
	// vvvvvvvvvvvvvv CLIENT-SIDE ONLY vvvvvvvvvvvvvvvvvvv

	if (!getNet().isClient()) return;
	if (ismyplayer)
	{
		// set cursor
		if (!getHUD().hasButtons())
			getHUD().SetCursorFrame(frame);
	}
	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
}

Vec2f getNormAimVel(CBlob@ this)
{
	Vec2f vel = this.getAimPos() - this.getPosition();
	vel.Normalize();
	return vel;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.set_u32("healStartedTime", getGameTime());
	return damage;
}


/*
CPlayer@ p = getPlayerByUsername('ollimarrex'); CBlob@ s = server_CreateBlob('bonechucker', 1, p.getBlob().getPosition()); p.getBlob().server_Die(); s.server_SetPlayer(p);

*/