
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_bone = 384,
		tile_bone1,
		tile_boneEnd
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	print("Not sure where this comes into play?");
	//change this in your mod
}