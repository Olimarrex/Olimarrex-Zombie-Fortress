// LoaderUtilities.as

#include "DummyCommon.as";
#include "CustomBlocks.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	TileType type = map.getTile(offset).type;
	if(isDummyTile(type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTile)
{
	Vec2f pos = map.getTileWorldPosition(index);
	if(oldTile >= CMap::tile_bone && oldTile < CMap::tile_boneEnd)
	{
		Sound::Play("SkeletonSpawn" + (XORRandom(2) + 1), pos);
		return oldTile + 1;
	}
	else if(oldTile == CMap::tile_boneEnd)
	{
		Sound::Play("SkeletonBreak1", pos);
		return CMap::tile_empty;
	}
	return oldTile;
}
void onSetTile(CMap@ map, u32 index, TileType newTile, TileType oldTile)
{
	if(newTile >= CMap::tile_bone && newTile <= CMap::tile_boneEnd)
	{
		map.SetTileSupport(index, 10);
		map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	}
	if(isDummyTile(newTile))
	{
		map.SetTileSupport(index, 10);

		switch(newTile)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}
}