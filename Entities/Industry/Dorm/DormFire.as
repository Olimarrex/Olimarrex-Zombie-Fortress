void onInit(CSprite@ this)
{
	this.SetFrame(0);

	CSpriteLayer@ fire = this.addSpriteLayer( "fire", 8,8 );
	if(fire !is null)
	{
		fire.addAnimation("default",3,true);
		int[] frames = {10,11,42,43};
		fire.animation.AddFrames(frames);
		fire.SetOffset(Vec2f(-9, 5));
		fire.SetRelativeZ(0.1f);
	}
}