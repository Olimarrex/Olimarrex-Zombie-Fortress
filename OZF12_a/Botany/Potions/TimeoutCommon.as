
/*
//example usage
void myFunc(CBlob@ this)
{
	print("Dis happun in 100 ticks");
}
void onInit(CBlob@ this)
{
	setTimeout(this, 300, @myFunc);
}
*/

funcdef void timeoutCallback( CBlob@ );

void/*bool*/ setTimeout( CBlob@ effectedBlob, u32 duration, timeoutCallback@ callback )
{
	if(effectedBlob.hasTag("hastimeouts"))
	{
		timeout[]@ timeouts;
		effectedBlob.get("timeouts", @timeouts);
		timeouts.push_back(timeout( callback, duration ));		
	}
	else
	{
		warn("Blob: " + effectedBlob.getName() + " Doesn't have the Effectable script and cannot set timeouts!");
	}
	//return true;
}

shared class timeout
{
	timeoutCallback@ callback;
	u32 duration;
	u32 gameTimeInited;
	
	//Constructor
	timeout(
	timeoutCallback@ _callback,
	u32 _duration)
	{
		callback = _callback;
		duration = _duration;
		gameTimeInited = getGameTime();
	}
}