const int radius = 250;
void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.getCurrentScript().tickFrequency = 225.0f;
	this.SetLight(true);
	this.SetLightRadius(radius / 2.0f);
}
void onInit(CSprite@ this)
{
	this.getCurrentScript().tickFrequency = 4.0f;
	CSpriteLayer@ layer = this.addSpriteLayer("default", "StoolFlames.png", 40, 24);
	if(layer !is null)
	{
		Animation@ anim = layer.addAnimation("test", 2, true);
		if(anim !is null)
		{
			anim.AddFrame(0);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
		}
		layer.SetAnimation(anim);
	}
}
void onTick(CBlob@ this)
{
	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), radius, blobs);
	for(int i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if(blob !is null && (blob.hasTag("zombie") || blob.hasTag("undeadplayer")))
		{
			blob.server_Heal(0.5f);
		}
	}
}
void onTick(CSprite@ this)
{
	Vec2f pos = this.getBlob().getPosition();
	pos += Vec2f(XORRandom(radius * 2) - radius, XORRandom(radius * 2) - radius);
	ParticleAnimated(CFileMatcher("HeartAnim.png").getFirst(), pos, Vec2f_zero, 0, 0.5f, 20, 0.0f, false);
}