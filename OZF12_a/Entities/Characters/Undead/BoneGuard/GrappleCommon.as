//TODO: move vars into  e Stuff namespace
const f32 grapple_length = 50.0f;
const f32 grapple_slack = 15.0f;
const f32 grapple_throw_speed = 17.0f;

const f32 grapple_force = 2.0f;
const f32 grapple_accel_limit = 1.5f;
const f32 grapple_stiffness = 0.1f;

const string grapple_sync_cmd = "grapple sync";

shared class GrappleInfo
{
	f32 cache_angle;
	bool grappling;
	u16 id;
	f32 ratio;
	Vec2f pos;
	Vec2f vel;

	GrappleInfo()
	{
		grappling = false;
	}
};

void initGrapple(CBlob@ this)
{
	GrappleInfo grapple;
	this.set("grappleInfo", @grapple);
	
	this.addCommandID(grapple_sync_cmd);
}

void HandleGrappleCommand(CBlob@ this, CBitStream@ params, bool apply)
{
	GrappleInfo@ grapple;
	if (!this.get("grappleInfo", @grapple)) { return; }

	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	grappling = params.read_bool();

	if (grappling)
	{
		grapple_id = params.read_u16();
		u8 temp = params.read_u8();
		grapple_ratio = temp / 250.0f;
		grapple_pos = params.read_Vec2f();
		grapple_vel = params.read_Vec2f();
	}

	if (apply)
	{
		grapple.grappling = grappling;
		if (grapple.grappling)
		{
			grapple.id = grapple_id;
			grapple.ratio = grapple_ratio;
			grapple.pos = grapple_pos;
			grapple.vel = grapple_vel;
		}
	}
}

void ManageGrapple(CBlob@ this, GrappleInfo@ grapple)
{
	CSprite@ sprite = this.getSprite();
	Vec2f pos = this.getPosition();

	const bool right_click = this.isKeyJustPressed(key_action2);
	if (right_click)
	{
		if (canSend(this)) //otherwise grapple
		{
			grapple.grappling = true;
			grapple.id = 0xffff;
			grapple.pos = pos;

			grapple.ratio = 1.0f; //allow fully extended

			Vec2f direction = this.getAimPos() - pos;

			//aim in direction of cursor
			f32 distance = direction.Normalize();
			if (distance > 1.0f)
			{
				grapple.vel = direction * grapple_throw_speed;
			}
			else
			{
				grapple.vel = Vec2f_zero;
			}

			SyncGrapple(this);
		}

		//grapple.charge_state = charge_state;
	}

	if (grapple.grappling)
	{
		//update grapple
		//TODO move to its own script?

		if (!this.isKeyPressed(key_action2))
		{
			if (canSend(this))
			{
				grapple.grappling = false;
				SyncGrapple(this);
			}
		}
		else
		{
			const f32 grapple_range = grapple_length * grapple.ratio;
			const f32 grapple_force_limit = this.getMass() * grapple_accel_limit;

			CMap@ map = this.getMap();

			//reel in
			//TODO: sound
			if (grapple.ratio > 0.2f)
				grapple.ratio -= 1.0f / getTicksASecond();

			//get the force and offset vectors
			Vec2f force;
			Vec2f offset;
			f32 dist;
			{
				force = grapple.pos - this.getPosition();
				dist = force.Normalize();
				f32 offdist = dist - grapple_range;
				if (offdist > 0)
				{
					offset = force * Maths::Min(8.0f, offdist * grapple_stiffness);
					force *= Maths::Min(grapple_force_limit, Maths::Max(0.0f, offdist + grapple_slack) * grapple_force);
				}
				else
				{
					force.Set(0, 0);
				}
			}

			//left map? too long? close grapple
			if (grapple.pos.x < 0 ||
			        grapple.pos.x > (map.tilemapwidth)*map.tilesize ||
			        dist > grapple_length * 3.0f)
			{
				if (canSend(this))
				{
					grapple.grappling = false;
					SyncGrapple(this);
				}
			}
			else if (grapple.id == 0xffff) //not stuck
			{
				const f32 drag = map.isInWater(grapple.pos) ? 0.7f : 0.90f;
				const Vec2f gravity(0, 1);

				grapple.vel = (grapple.vel * drag) + gravity - (force * (2 / this.getMass()));

				Vec2f next = grapple.pos + grapple.vel;
				next -= offset;

				Vec2f dir = next - grapple.pos;
				f32 delta = dir.Normalize();
				bool found = false;
				const f32 step = map.tilesize * 0.5f;
				while (delta > 0 && !found) //fake raycast
				{
					if (delta > step)
					{
						grapple.pos += dir * step;
					}
					else
					{
						grapple.pos = next;
					}
					delta -= step;
					found = checkGrappleStep(this, grapple, map, dist);
				}

			}
			else //stuck -> pull towards pos
			{

				//wallrun/jump reset to make getting over things easier
				//at the top of grapple
				if (this.isOnWall()) //on wall
				{
					//close to the grapple point
					//not too far above
					//and moving downwards
					Vec2f dif = pos - grapple.pos;
					if (this.getVelocity().y > 0 &&
					        dif.y > -10.0f &&
					        dif.Length() < 24.0f)
					{
						//need move vars
						RunnerMoveVars@ moveVars;
						if (this.get("moveVars", @moveVars))
						{
							moveVars.walljumped_side = Walljump::NONE;
							moveVars.wallrun_start = pos.y;
							moveVars.wallrun_current = pos.y;
						}
					}
				}

				CBlob@ b = null;
				if (grapple.id != 0)
				{
					@b = getBlobByNetworkID(grapple.id);
					if (b is null)
					{
						grapple.id = 0;
					}
				}

				if (b !is null)
				{
					grapple.pos = b.getPosition();
					if (b.isKeyJustPressed(key_action1) ||
					        b.isKeyJustPressed(key_action2) ||
					        this.isKeyPressed(key_use))
					{
						if (canSend(this))
						{
							grapple.grappling = false;
							SyncGrapple(this);
						}
					}
				}
				else if (shouldReleaseGrapple(this, grapple, map))
				{
					if (canSend(this))
					{
						grapple.grappling = false;
						SyncGrapple(this);
					}
				}

				this.AddForce(force);
				Vec2f target = (this.getPosition() + offset);
				if (!map.rayCastSolid(this.getPosition(), target) &&
					(this.getVelocity().Length() > 2 || !this.isOnMap()))
				{
					this.setPosition(target);
				}

				if (b !is null)
					b.AddForce(-force * (b.getMass() / this.getMass()));

			}
		}

	}
}

bool canSend(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}

bool shouldReleaseGrapple(CBlob@ this, GrappleInfo@ grapple, CMap@ map)
{
	return !grappleHitMap(grapple, map) || this.isKeyPressed(key_use);
}

bool grappleHitMap(GrappleInfo@ grapple, CMap@ map, const f32 dist = 16.0f)
{
	return  map.isTileSolid(grapple.pos + Vec2f(0, -3)) ||			//fake quad
	        map.isTileSolid(grapple.pos + Vec2f(3, 0)) ||
	        map.isTileSolid(grapple.pos + Vec2f(-3, 0)) ||
	        map.isTileSolid(grapple.pos + Vec2f(0, 3)) ||
	        (dist > 10.0f && map.getSectorAtPosition(grapple.pos, "tree") !is null);   //tree stick
}

void SyncGrapple(CBlob@ this)
{
	GrappleInfo@ grapple;
	if (!this.get("grappleInfo", @grapple)) { return; }

	CBitStream params;
	params.write_bool(grapple.grappling);

	if (grapple.grappling)
	{
		params.write_u16(grapple.id);
		params.write_u8(u8(grapple.ratio * 250));
		params.write_Vec2f(grapple.pos);
		params.write_Vec2f(grapple.vel);
	}

	this.SendCommand(this.getCommandID(grapple_sync_cmd), params);
}

bool checkGrappleStep(CBlob@ this, GrappleInfo@ grapple, CMap@ map, const f32 dist)
{
	if (map.getSectorAtPosition(grapple.pos, "barrier") !is null)  //red barrier
	{
		if (canSend(this))
		{
			grapple.grappling = false;
			SyncGrapple(this);
		}
	}
	else if (grappleHitMap(grapple, map, dist))
	{
		grapple.id = 0;

		grapple.ratio = Maths::Max(0.2, Maths::Min(grapple.ratio, dist / grapple_length));

		grapple.pos.y = Maths::Max(0.0, grapple.pos.y);

		if (canSend(this)) SyncGrapple(this);

		return true;
	}
	else
	{
		CBlob@ b = map.getBlobAtPosition(grapple.pos);
		if (b !is null)
		{
			if (b is this)
			{
				//can't grapple self if not reeled in
				if (grapple.	ratio > 0.5f)
					return false;

				if (canSend(this))
				{
					grapple.grappling = false;
					SyncGrapple(this);
				}

				return true;
			}
			else if (b.isCollidable() && b.getShape().isStatic() && !b.hasTag("ignore_arrow"))
			{
				//TODO: Maybe figure out a way to grapple moving blobs
				//		without massive desync + forces :)

				grapple.ratio = Maths::Max(0.2, Maths::Min(grapple.ratio, b.getDistanceTo(this) / grapple_length));

				grapple.id = b.getNetworkID();
				if (canSend(this))
				{
					SyncGrapple(this);
				}

				return true;
			}
		}
	}

	return false;
}

//To be called on tick.
void AnimateRope(CSprite@ this, CBlob@ blob, GrappleInfo@ grapple)
{
	CSpriteLayer@ rope = this.getSpriteLayer("rope");
	CSpriteLayer@ hook = this.getSpriteLayer("hook");

	bool visible = grapple !is null && grapple.grappling;

	rope.SetVisible(visible);
	hook.SetVisible(visible);
	if (!visible)
	{
		return;
	}

	Vec2f adjusted_pos = Vec2f(grapple.pos.x, Maths::Max(0.0, grapple.pos.y));
	Vec2f off = adjusted_pos - blob.getPosition();

	f32 ropelen = Maths::Max(0.1f, off.Length() / 32.0f);
	if (ropelen > 200.0f)
	{
		rope.SetVisible(false);
		hook.SetVisible(false);
		return;
	}

	rope.ResetTransform();
	rope.ScaleBy(Vec2f(ropelen, 1.0f));

	rope.TranslateBy(Vec2f(ropelen * 16.0f, 0.0f));

	rope.RotateBy(-off.Angle() , Vec2f());

	hook.ResetTransform();
	if (grapple.id == 0xffff) //still in air
	{
		grapple.cache_angle = -grapple.vel.Angle();
	}
	hook.RotateBy(grapple.cache_angle , Vec2f());

	hook.TranslateBy(off);
	hook.SetIgnoreParentFacing(true);
	hook.SetFacingLeft(false);

	//GUI::DrawLine(blob.getPosition(), grapple.pos, SColor(255,255,255,255));
}