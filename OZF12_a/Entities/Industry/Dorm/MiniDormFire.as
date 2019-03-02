void onInit(CSprite@ this)
{
	CSpriteLayer@ fire = this.addSpriteLayer("fire", 4, 4);
	if(fire !is null)
	{
		fire.addAnimation("default", 3, true);
		int[] frames = {12, 13, 14};
		fire.animation.AddFrames(frames);
		fire.SetOffset(Vec2f( 2, 2));
		fire.SetRelativeZ(0.1f);
	}
}