void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.set_string("required class", "bonechucker");
	this.Tag("zombies_only");
}