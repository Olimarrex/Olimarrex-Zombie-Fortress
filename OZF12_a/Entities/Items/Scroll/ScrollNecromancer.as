// scroll script that makes enemies insta gib within some radius

#include "Hitters.as";
#include "RespawnCommandCommon.as"
#include "StandardRespawnCommand.as"
void onInit( CBlob@ this )
{
	this.set_string("required class", "undeadnecromancer");
	this.Tag("zombies_only");
}