void onTick( CBrain@ this )
{
	CBlob@ blob = this.getBlob();
	CBlob@ target = this.getTarget();

	// do we have a target?
	if (target !is null)
	{
		// should we be mad?
		if (blob.getDistanceTo(target) < blob.get_f32("explosive_radius"))
		{
			// get mad
			Enrage(blob);
		}
	}
}

void Enrage( CBlob@ this )
{
	this.Tag("enraged");
	this.Sync("enraged", true);
}