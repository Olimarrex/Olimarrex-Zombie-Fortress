#include "CustomBlocks.as";

bool moddedIsTileSolid(CMap@ map, TileType tile)
{
	return map.isTileSolid(tile) || (tile >= CMap::tile_bone && tile <= CMap::tile_boneEnd);
}

bool moddedIsTileSolid(CMap@ map, int tile)
{
	return map.isTileSolid(tile) || (tile >= CMap::tile_bone && tile <= CMap::tile_boneEnd);
}

bool moddedIsTileSolid(CMap@ map, Tile tile)
{
	return map.isTileSolid(tile) || (tile.type >= CMap::tile_bone && tile.type <= CMap::tile_boneEnd);
}

bool isTileBone(TileType tile)
{
	return tile >= CMap::tile_bone && tile <= CMap::tile_boneEnd;
}