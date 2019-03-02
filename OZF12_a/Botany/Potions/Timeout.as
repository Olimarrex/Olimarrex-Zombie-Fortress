//Effectable.as
//Allows to apply timeout effects, initially for poisons, but works for other things.
#include "TimeoutCommon.as";
void onInit(CBlob@ this)
{
	timeout[] timeouts = {};
	this.set("timeouts", @timeouts);
	this.Tag("hastimeouts");
}

void onTick(CBlob@ this)
{
	timeout[]@ timeouts;
	this.get("timeouts", @timeouts);
	u32 gametime = getGameTime();
	for(int i = 0; i < timeouts.length; i++)
	{
		timeout timeout = timeouts[i];
		if(timeout.gameTimeInited + timeout.duration < gametime)
		{
			timeout.callback(this);
			timeouts.removeAt(i);
		}
	}
}