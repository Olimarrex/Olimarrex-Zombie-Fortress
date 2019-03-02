#include "RespawnCommandCommon.as";

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == SpawnCmd::changeClass)
	{
		this.server_Die();
	}
}