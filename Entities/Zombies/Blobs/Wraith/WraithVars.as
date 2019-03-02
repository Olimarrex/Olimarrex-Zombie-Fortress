void onInit(CBlob@ this)
{
	// explosiveness
	this.set_f32("explosive_radius", 50.0f);
	this.set_f32("explosive_damage", 10.0f);
	this.set_string("custom_explosion_sound", "Entities/Items/Explosives/KegExplosion.ogg");
	this.set_f32("map_damage_radius", 40.0f);
	this.set_f32("map_damage_ratio", 0.4f);
	this.set_bool("map_damage_raycast", true);
	this.set_bool("explosive_teamkill", true);
}