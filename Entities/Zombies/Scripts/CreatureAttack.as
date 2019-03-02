// Aphelion \\

#include "Hitters.as";
#include "TileCommon.as";

void onInit(CBlob@ this)
{
	if (!this.exists("attack frequency"))
		 this.set_u8("attack frequency", 30);
	
	if (!this.exists("attack distance"))
	     this.set_f32("attack distance", 0.5f);
	     
	if (!this.exists("attack damage"))
		 this.set_f32("attack damage", 1.0f);
		
	if (!this.exists("attack hitter"))
		 this.set_u8("attack hitter", Hitters::bite);
	
	if (!this.exists("attack sound"))
		 this.set_string("attack sound", "ZombieBite");
	
	this.getCurrentScript().removeIfTag	= "dead";
}

void onTick( CBlob@ this )
{
	f32 damage = this.get_f32("attack damage");
	u8 hitter = this.get_u8("attack hitter");
	CBlob@ target = this.getBrain().getTarget();
	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	
	//Randomly break background blocks at the zombie's position.
	if(XORRandom(100 / damage) == 1 && this.hasTag("BreakBlocks") && map.isTileBackground(map.getTile(pos)) && !map.isTileGroundBack(map.getTile(pos).type))
	{								
		damageTile(this, pos, map, hitter);
	}
	
	if(target !is null)
	{
		if (getGameTime() >= this.get_u32("next_attack"))
		{
            const f32 radius = this.getRadius();
            const f32 attack_distance = radius + this.get_f32("attack distance");

			Vec2f vec = this.getAimPos() - pos;
			f32 angle = vec.Angle();
            
		    HitInfo@[] hitInfos;

			bool hitSolid = false;
			bool breakBlocks = this.hasTag("BreakBlocks");
		    if (map.getHitInfosFromArc(pos, -angle, 90.0f, radius + attack_distance, this, @hitInfos))
		    {
				for(uint i = 0; i < hitInfos.length; i++)
			    {
				    HitInfo@ hi = hitInfos[i];
				    
				    CBlob@ b = hi.blob;
					if(b is target)
					{
						HitTarget(this, b);
					}
					else if(breakBlocks)
					{
						if(b !is null && isWallBlob(b, this) && !hitSolid)
						{
							HitTarget(this, b);
							hitSolid = true;
						}
						else if(moddedIsTileSolid(map, hi.tile))
						{
							if(!hitSolid)
							{
								this.set_u32("next_attack", getGameTime() + this.get_u8("attack frequency"));
								hitSolid = true;
								
								damageTile(this, hi.hitpos, map, damage);
							}
						}
					}
				    if(breakBlocks)
					{
						
					}
			    }
		    }
		}
	}
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

bool isWallBlob(CBlob@ blob, CBlob@ this)
{
	if(blob.getShape().isStatic() && this.doesCollideWithBlob(blob) && (blob.hasTag("stone") || blob.hasTag("wooden")))
	{
		return true;
	}
	else
	return false;
}


void HitTarget( CBlob@ this, CBlob@ target )
{
	Vec2f hitvel = Vec2f( this.isFacingLeft() ? -1.0 : 1.0, 0.0f );
	
	this.server_Hit( target, target.getPosition(), hitvel, this.get_f32("attack damage"), this.get_u8("attack hitter"), true);
	this.set_u32("next_attack", getGameTime() + this.get_u8("attack frequency"));
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{		 
	if (damage > 0.0f)
	{
		this.getSprite().PlayRandomSound(this.get_string("attack sound"));
	}
}