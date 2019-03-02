#include "RunnerCommon.as";
void onInit(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	RunnerMoveVars moveVars;
	blob.get("moveVars", moveVars);
	
	moveVars.wallrun_length = 14;
	blob.set("moveVars", moveVars);
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	RunnerMoveVars moveVars;
	blob.get("moveVars", moveVars);
	if(blob.isKeyPressed(key_action1))
	{
		moveVars.walkFactor = 0.15f;
		moveVars.swimspeed = 0.2f;
		moveVars.swimforce = 5.0f;
		moveVars.jumpFactor = 0.4f;
	}
	else if(blob.isKeyPressed(key_action2))
	{
		moveVars.walkFactor = 0.5f;
		moveVars.swimspeed = 0.6f;
		moveVars.swimforce = 10.0f;
		moveVars.jumpFactor = 0.8f;
	}
	else
	{
		moveVars.swimspeed = 1.2f;
		moveVars.swimforce = 30.0f;
	}
	blob.set("moveVars", moveVars);
}