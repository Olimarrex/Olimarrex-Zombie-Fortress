#include "nActorHUDStartPos.as";

void ManageCursors()
{
	// set cursor
	if (getHUD().hasButtons()) {
		getHUD().SetDefaultCursor();
	}
	else
	{
		// set cursor
		getHUD().SetCursorImage("BoneChuckerCursor.png", Vec2f(32,32));
		getHUD().SetCursorOffset( Vec2f(-32, -32) );
		// frame set in logic
	}
}

void onRender( CSprite@ this )
{
	if(g_videorecording)
		return;
	if(this.getBlob().isMyPlayer())
	{
		ManageCursors();
	}
}