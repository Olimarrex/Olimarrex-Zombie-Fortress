void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	CBlob@ blob = this.getBlob();
	SpriteConsts@ consts = this.getConsts();
	CSpriteLayer@ front = this.addSpriteLayer("front layer", this.getFilename(), consts.frameWidth, consts.frameHeight, blob.getTeamNum(), blob.getSkinNum());

	if (front !is null)
	{
		Animation@ anim = front.addAnimation("default", 0, false);
		anim.AddFrame(4);
		front.SetRelativeZ(1000);
	}
}