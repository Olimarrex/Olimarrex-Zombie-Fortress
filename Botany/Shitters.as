
namespace BigHitters
{
	shared enum hits
	{
nothing = 0,

		//env
		crush = 1, //(required to be 1 for engine reasons)
		fall,
		water,      //just fire
		water_stun, //splash
		water_stun_force, //splash
		drown,
		fire,   //initial burst (should ignite things)
		burn,   //burn damage
		flying,

		//common actor
		stomp,
		suicide = 11, //(required to be 11 for engine reasons)

		//natural
		bite,

		//builders
		builder,

		//knight
		sword,
		shield,
		bomb,

		//archer
		stab,

		//arrows and similar projectiles
		arrow,
		bomb_arrow,
		ballista,

		//cata
		cata_stones,
		cata_boulder,
		boulder,

		//siege
		ram,

		// explosion
		explosion,
		keg,
		mine,
		mine_special,

		//traps
		spikes,

		//machinery
		saw,
		drill,

		//barbarian
		muscles,

		// scrolls
		suddengib,
		
		///MODDDEED
		// plant
		infection,
		
		orb,
		fire_orb,
		bomb_orb,
		water_orb,
		wizexplosion,
		
		cannon,
		mega_bomb,
		explosive_trap,
		wooden_spikes,
		
		chainsaw,
		mega_drill,
		
		bison,
		shark,
		skeleton,
		zombie,
		chaparral
		
	};
}

//u8 customData
//If only we did set theory :-;

bool isSolidHit(u8 hit)
{
	return hit == BigHitters::muscles ||
	hit == BigHitters::crush ||
	hit == BigHitters::fall ||
	hit == BigHitters::stomp ||
	hit == BigHitters::bite ||
	hit == BigHitters::builder ||
	hit == BigHitters::sword ||
	hit == BigHitters::shield ||
	hit == BigHitters::bomb ||
	hit == BigHitters::stab ||
	hit == BigHitters::arrow ||
	hit == BigHitters::bomb_arrow ||
	hit == BigHitters::nothing ||
	hit == BigHitters::keg ||
	hit == BigHitters::ballista ||
	hit == BigHitters::cata_stones ||
	hit == BigHitters::cata_boulder ||
	hit == BigHitters::boulder ||
	hit == BigHitters::mine ||
	hit == BigHitters::explosion ||
	hit == BigHitters::mine_special ||
	hit == BigHitters::spikes ||
	hit == BigHitters::saw ||
	hit == BigHitters::cannon ||
	hit == BigHitters::mega_bomb ||
	hit == BigHitters::explosive_trap ||
	hit == BigHitters::wooden_spikes ||
	hit == BigHitters::chainsaw ||
	hit == BigHitters::mega_drill ||
	hit == BigHitters::bison ||
	hit == BigHitters::shark ||
	hit == BigHitters::skeleton ||
	hit == BigHitters::zombie ||
	hit == BigHitters::chaparral;
}