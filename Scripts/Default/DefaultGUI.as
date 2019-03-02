#include "CustomBlocks.as";
#include "TileCommon.as";
// DefaultGUI.as

void LoadDefaultGUI()
{
    if (v_driver > 0)
    {
		// add color tokens
		AddColorToken("$RED$", SColor(255, 105, 25, 5));
		AddColorToken("$GREEN$", SColor(255, 5, 105, 25));
		AddColorToken("$GREY$", SColor(255, 195, 195, 195));

		// add default icon tokens
		string interaction = "InteractionIcons.png";
		AddIconToken("$NONE$", interaction, Vec2f(32, 32), 9);
		AddIconToken("$TIME$", interaction, Vec2f(32, 32), 0);
		AddIconToken("$COIN$", "coins.png", Vec2f(16, 16), 1);
		AddIconToken("$TEAMS$", "MenuItems.png", Vec2f(32, 32), 1);
		AddIconToken("$SPECTATOR$", "MenuItems.png", Vec2f(32, 32), 19);
		AddIconToken("$FLAG$", CFileMatcher("flag.png").getFirst(), Vec2f(32, 16), 0);
		AddIconToken("$DISABLED$", interaction, Vec2f(32, 32), 9, 1);
		AddIconToken("$CANCEL$", "MenuItems.png", Vec2f(32, 32), 29);
		AddIconToken("$RESEARCH$", interaction, Vec2f(32, 32), 27);
		AddIconToken("$ALERT$", interaction, Vec2f(32, 32), 10);
		AddIconToken("$down_arrow$", "ArrowDown.png", Vec2f(8, 8), 0);
		AddIconToken("$ATTACK_LEFT$", interaction, Vec2f(32, 32), 18, 1);
		AddIconToken("$ATTACK_RIGHT$", interaction, Vec2f(32, 32), 17, 1);
		AddIconToken("$ATTACK_THIS$", interaction, Vec2f(32, 32), 19, 1);
		AddIconToken("$DEFEND_LEFT$", interaction, Vec2f(32, 32), 18, 2);
		AddIconToken("$DEFEND_RIGHT$", interaction, Vec2f(32, 32), 17, 2);
		AddIconToken("$DEFEND_THIS$", interaction, Vec2f(32, 32), 19, 2);
		AddIconToken("$CLASSCHANGE$", "TutorialImages.png", Vec2f(32, 32), 7);
		AddIconToken("$BUILD$", interaction, Vec2f(32, 32), 15);
		AddIconToken("$STONE$", "World.png", Vec2f(8, 8), 48);
		AddIconToken("$!!!$", "Emoticons.png", Vec2f(22, 22), 48);
		
		//Mod Icons
		AddIconToken( "$chuckershack$", "ChuckerShack.png", Vec2f(40, 24), 0 );
		AddIconToken( "$guardshack$", "GuardShack.png", Vec2f(40, 24), 0 );
		AddIconToken( "$necrostool$", "NecroStool.png", Vec2f(40, 24), 0 );
		AddIconToken( "$vehicleshop$", "VehicleShopIcon.png", Vec2f(40,24), 0 );
		AddIconToken( "$defenseshop$", "DefenseShop.png", Vec2f(40,24), 0 );
		AddIconToken( "$priestshop$", "PriestShop.png", Vec2f(40,24), 0 );
		AddIconToken( "$undeadtunnel$", "UndeadTunnel.png", Vec2f(40,24), 0 );
		AddIconToken( "$undeadtradershop$", "UndeadTraderShop.png", Vec2f(40,24), 0 );
		AddIconToken( "$horror$", "UndeadTraderIcons.png", Vec2f(16,16), 0 );
		AddIconToken( "$abomination$", "UndeadTraderIcons.png", Vec2f(16,16), 1 );
		AddIconToken( "$undeadbarracks$", "UndeadBarracks.png", Vec2f(40,24), 0 );
		AddIconToken( "$undeadbuilding$", "UndeadBuilding.png", Vec2f(40,24), 0 );
		AddIconToken( "$ZP$", "ZPIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$change_class$", "InteractionIcons.png", Vec2f(32, 32), 12, 2);
		AddIconToken( "$tradershop$", "tradershopIcon.png", Vec2f(40,24), 0 );
		AddIconToken( "$grainshop$", "grainnursery.png", Vec2f(40,24), 0 );
		AddIconToken( "$botanyworkshop$", "AlchemyStation.png", Vec2f(40,24), 0 );
		AddIconToken( "$apothecary$", "Apothecary.png", Vec2f(40,24), 0 );
		AddIconToken( "$bonetunnel$", "BoneTunnel.png", Vec2f(40,24), 0 );
		AddIconToken( "$minibuilding$", "MiniBuilding.png", Vec2f(40,24), 0 );
		AddIconToken( "$minibuildershop$", "MiniBuilderShop.png", Vec2f(16,16), 0 );
		AddIconToken( "$minipriestshop$", "MiniPriestShop.png", Vec2f(16,16), 0 );
		AddIconToken( "$miniknightshop$", "MiniKnightShop.png", Vec2f(16,16), 0 );
		AddIconToken( "$miniarchershop$", "MiniArcherShop.png", Vec2f(16,16), 0 );
		AddIconToken( "$minidorm$", "MiniDorm.png", Vec2f(16,16), 0 );
		AddIconToken( "$minidefenseshop$", "MiniDefenseShop.png", Vec2f(16,16), 0 );
		AddIconToken( "$minitradershop$", "MiniTraderShop.png", Vec2f(16,16), 0 );
		AddIconToken( "$minitunnel$", "MiniTunnel.png", Vec2f(16,16), 0 );
		AddIconToken( "$minifarm$", "MiniFarm.png", Vec2f(16,16), 0 );
		AddIconToken( "$minivehicleshop$", "MiniVehicleShop.png", Vec2f(16,16), 0 );
		AddIconToken( "$chainsaw$", "ChainsawIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$drill$", "DrillIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$golddrill$", "GoldDrillIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$bomb_satchel$", "BombSatchel.png", Vec2f(16,16), 0 );
		AddIconToken( "$divinghelmet$", "DivingHelmetIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$bluelantern$", "BlueLantern.png", Vec2f(8,8), 0 );
		AddIconToken( "$fireplace$", "Fireplace.png", Vec2f(16, 16), 0);
		AddIconToken( "$megasaw$", "MS Icon.png", Vec2f(16,16), 0 );
		AddIconToken( "$saw$", "SawIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$trampoline$", "TrampolineIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$ballista$", "BallistaIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$dinghy$", "DinghyIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$longboat$", "LongboatIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$warboat$", "WarboatIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$raft$", "RaftIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$catapult$", "CatapultIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$glider$", "GliderIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$balloon$", "BalloonIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$zeppelin$", "ZeppelinIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$tank$", "TankIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$torch$", "Torch.png", Vec2f(8, 8), 0);
		AddIconToken( "$caravel$", "CaravelIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mounted_bow$", "MB Icon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mounted_crossbow$", "MCbIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mounted_bazooka$", "MBz Icon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mounted_cannon$", "MCnIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mat_crossbolts$", "CrossboltIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mat_rarrows$", "rArrowIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mat_rockets$", "rocketicon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mat_cannonballs$", "cannonballicon.png", Vec2f(16,16), 0 );
		AddIconToken( "$mat_orbs$", "Orbs_mat.png", Vec2f(16,16), 12 );
		AddIconToken( "$mat_fireorbs$", "Orbs_mat.png", Vec2f(16,16), 13 );
		AddIconToken( "$mat_bomborbs$", "Orbs_mat.png", Vec2f(16,16), 14 );
		AddIconToken( "$mat_waterorbs$", "Orbs_mat.png", Vec2f(16,16), 15 );
		AddIconToken( "$fire_trap_block$", "FireTrapBlockIcon.png", Vec2f(8,8), 0 );
		AddIconToken( "$carnage$", "ScrollCarnage.png", Vec2f(16,16), 0 );
		AddIconToken( "$midas$", "ScrollOfMidas.png", Vec2f(16,16), 0 );
		AddIconToken( "$sreinforce$", "ScrollReinforce.png", Vec2f(16,16), 0 );
		AddIconToken( "$whitebook$", "WhiteBook.png", Vec2f(16,16), 0 );
		AddIconToken( "$whitepage$", "WhitePageIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$sslayer$", "ScrollSlayer.png", Vec2f(16,16), 0 );
		AddIconToken( "$snecromancer$", "ScrollNecromancer.png", Vec2f(16,16), 0 );
		AddIconToken( "$sgargoyle$", "ScrollGargoyle.png", Vec2f(16,16), 0 );
		AddIconToken( "$sbunny$", "ScrollBunny.png", Vec2f(16,16), 0 );		
		AddIconToken( "$drought$", "ScrollDrought.png", Vec2f(16,16), 0 );
		AddIconToken( "$sreturn$", "ScrollReturn.png", Vec2f(16,16), 0 );
		AddIconToken( "$szombie$", "ScrollZombie.png", Vec2f(16,16), 0 );
		AddIconToken( "$sskeleton$", "ScrollSkeleton.png", Vec2f(16,16), 0 );
		AddIconToken( "$smeteor$", "ScrollMeteor.png", Vec2f(16,16), 0 );
		AddIconToken( "$schicken$", "ScrollChicken.png", Vec2f(16,16), 0 );
		AddIconToken( "$sburd$", "ScrollBurd.png", Vec2f(16,16), 0 );
		AddIconToken( "$spyro$", "ScrollPyro.png", Vec2f(16,16), 0 );
		AddIconToken( "$scrossbow$", "ScrollCrossbow.png", Vec2f(16,16), 0 );
		AddIconToken( "$sassassin$", "ScrollAssassin.png", Vec2f(16,16), 0 );
		//AddIconToken( "$necro$", "ScrollNecro.png", Vec2f(16,16), 0 );
		AddIconToken( "$booster$", "Booster.png", Vec2f(8,8), 0 );
		AddIconToken( "$flamer$", "Flamer.png", Vec2f(8,8), 0 );
		AddIconToken( "$conveyor$", "Conveyor.png", Vec2f(8,8), 0 );
		AddIconToken( "$conveyortriangle$", "ConveyorTriangle.png", Vec2f(8,8), 0 );
		AddIconToken( "$nmigrant$", "SummonIcons.png", Vec2f(16,16), 0 );
		AddIconToken( "$narsonist$", "SummonIcons.png", Vec2f(16,16), 1 );
		AddIconToken( "$nwarrior$", "SummonIcons.png", Vec2f(16,16), 2 );
		AddIconToken( "$ngarg$", "SummonIcons.png", Vec2f(16,16), 3 );
		AddIconToken( "$mage$", "MageIcon.png", Vec2f(16,16), 0 );
		//AddIconToken( "$archerbot$", "ArcherBotIcon.png", Vec2f(16,16), 0 );
		AddIconToken( "$piglet$", "Piglet.png", Vec2f(16,16), 0 );
		AddIconToken( "$birb$", "Birb.png", Vec2f(16,16), 0 );
		AddIconToken( "$bunny$", "Bunny.png", Vec2f(16,16), 0 );
		AddIconToken( "$chicken$", "Chicken.png", Vec2f(16,16), 0 );
		AddIconToken( "$bison$", "MiniIcons.png", Vec2f(16,16), 21 );
		AddIconToken( "$shark$", "MiniIcons.png", Vec2f(16,16), 22 );
		AddIconToken( "$seedicon$", "SeedIcon.png", Vec2f(16,16), 0 );
				
		
		// classes

		AddIconToken( "$ARCHER$", "ClassIcons.png", Vec2f(16,16), 2 );
		AddIconToken( "$KNIGHT$", "ClassIcons.png", Vec2f(16,16), 1 );
		AddIconToken( "$BUILDER$", "ClassIcons.png", Vec2f(16,16), 0 );

		// blocks

		AddIconToken( "$stone_block$", "World.png", Vec2f(8,8), CMap::tile_castle );
		AddIconToken( "$moss_block$", "World.png", Vec2f(8,8), CMap::tile_castle_moss );
		AddIconToken( "$back_stone_block$", "World.png", Vec2f(8,8), CMap::tile_castle_back );
		AddIconToken( "$wood_block$", "World.png", Vec2f(8,8), CMap::tile_wood );
		AddIconToken( "$back_wood_block$", "World.png", Vec2f(8,8), CMap::tile_wood_back );
		AddIconToken( "$dirt_block$", "World.png", Vec2f(8,8), CMap::tile_ground );
		
		{
			//Modded blocks
			AddIconToken( "$bone_block$", "World.png", Vec2f(8,8), CMap::tile_bone );
		}
		// techs

		AddIconToken( "$tech_stone$", "TechnologyIcons.png", Vec2f(16,16), 16 );

		// keys
		const Vec2f keyIconSize(16,16);
		AddIconToken( "$KEY_W$", "Keys.png", keyIconSize, 6 );
		AddIconToken( "$KEY_A$", "Keys.png", keyIconSize, 0 );
		AddIconToken( "$KEY_S$", "Keys.png", keyIconSize, 1 );
		AddIconToken( "$KEY_D$", "Keys.png", keyIconSize, 2 );
		AddIconToken( "$KEY_E$", "Keys.png", keyIconSize, 3 );
		AddIconToken( "$KEY_F$", "Keys.png", keyIconSize, 4 );
		AddIconToken( "$KEY_C$", "Keys.png", keyIconSize, 5 );
		AddIconToken( "$LMB$", "Keys.png", keyIconSize, 8 );
		AddIconToken( "$RMB$", "Keys.png", keyIconSize, 9 );
		AddIconToken( "$KEY_SPACE$", "Keys.png", Vec2f(24,16), 8 );
		AddIconToken( "$KEY_HOLD$", "Keys.png", Vec2f(24,16), 9 );
		AddIconToken( "$KEY_TAP$", "Keys.png", Vec2f(24,16), 10 );
		AddIconToken( "$KEY_F1$", "Keys.png", Vec2f(24,16), 12 );
		AddIconToken( "$KEY_ESC$", "Keys.png", Vec2f(24,16), 13 );
		
		//Buttons
		AddIconToken( "$SeedMerge$", "SeedMerge.png", Vec2f(16,16), 0 );
		
		AddIconToken( "$triangle$", "Triangle.png", Vec2f(8, 8), 0 );
		AddIconToken( "$teambridge$", "TeamBridge.png", Vec2f(8, 8), 0 );
		
		//MODDED MESS
		AddIconToken( "$Blink$", "aSpellIcons.png", Vec2f(16,16), 0 );
		AddIconToken("$BUILDER_CLEAR$", "BuilderIcons.png", Vec2f(32, 32), 2);
		AddIconToken( "$Orb0$", "jitem.png", Vec2f(16,16), 27, 0);
		AddIconToken( "$Orb1$", "jitem.png", Vec2f(16,16), 27, 1);
		AddIconToken( "$Blink$", "wSpellIcons.png", Vec2f(16,16), 1 );
		AddIconToken( "$HealSpell$", "wSpellIcons.png", Vec2f(16,16), 0 );
		AddIconToken( "$Orb$", "OrbIcons", Vec2f(16,16), 0 );
		AddIconToken( "$FireOrb$", "OrbIcons", Vec2f(16,16), 1 );
		AddIconToken( "$BombOrb$", "OrbIcons", Vec2f(16,16), 2 );
		AddIconToken( "$WaterOrb$", "OrbIcons", Vec2f(16,16), 3 );
		AddIconToken( "$Firewalk$", "pSpellIcons.png", Vec2f(16,16), 0 );
		AddIconToken( "$Firebolt$", "pSpellIcons.png", Vec2f(16,16), 1 );
		AddIconToken( "$Flaming$", "pSpellIcons.png", Vec2f(16,16), 2 );
		AddIconToken("$stone_moss_block$", "World.png", Vec2f(8, 8), CMap::tile_castle_moss);
		AddIconToken("$back_stone_moss_block$", "World.png", Vec2f(8, 8), CMap::tile_castle_back_moss);
		AddIconToken("$BUILDER_CLEAR$", "BuilderIcons.png", Vec2f(32, 32), 2);
		AddIconToken( "$Grab$", "HelpIcons.png", Vec2f(16,16), 5 );	
		AddIconToken( "$Release$", "HelpIcons.png", Vec2f(16,16), 4 );	
		AddIconToken( "$Dash$", "HelpIcons.png", Vec2f(16,16), 7 );	
		AddIconToken( "$Fball$", "BlackFireBall.png", Vec2f(16,16), 0 );	
		AddIconToken( "$Stalk$", "usSpellIcons.png", Vec2f(16,16), 0 );
		AddIconToken( "$Screech$", "usSpellIcons.png", Vec2f(16,16), 1 );
		AddIconToken("$builder_class_icon$", "MenuItems.png", Vec2f(32, 32), 8);
		AddIconToken("$knight_class_icon$", "MenuItems.png", Vec2f(32, 32), 12);
		AddIconToken("$archer_class_icon$", "MenuItems.png", Vec2f(32, 32), 16);
		AddIconToken("$priest_class_icon$", "MenuItems.png", Vec2f(32, 32), 15);
		AddIconToken("$necromancer_class_icon$", "MenuItems.png", Vec2f(32, 32), 18);
		AddIconToken("$last_charge_slider$", "VehicleChargeBar.png", Vec2f(32, 10), 1);
		AddIconToken("$red_last_charge_slider$", "VehicleChargeBar.png", Vec2f(32, 10), 2);
		AddIconToken("$empty_charge_bar$", "VehicleChargeBar.png", Vec2f(24, 8), 0);
		AddIconToken( "$migrant_standground$", "Orders.png", Vec2f(32,32), 2 );
		AddIconToken( "$migrant_continue$", "Orders.png", Vec2f(32,32), 4 );
		AddIconToken("$lever_0$", "Lever.png", Vec2f(16, 16), 4);
		AddIconToken("$lever_1$", "Lever.png", Vec2f(16, 16), 5);
		AddIconToken("$insert_coin$", "InteractionIcons.png", Vec2f(32, 32), 26);
		AddIconToken("$Succumb$", "GraveHand.png", Vec2f(16, 16), 0);
		AddIconToken("$lantern on$", "Lantern.png", Vec2f(8, 8), 0);
		AddIconToken("$lantern off$", "Lantern.png", Vec2f(8, 8), 3);
		AddIconToken("$stonequarry$", "Quarry.png", Vec2f(40, 24), 4);
		AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);
		AddIconToken("$undead_builder_class_icon$", "ExtraMenuItems.png", Vec2f(32, 32), 0);
		AddIconToken("$undead_knight_class_icon$", "ExtraMenuItems.png", Vec2f(32, 32), 1);
		AddIconToken("$undead_archer_class_icon$", "ExtraMenuItems.png", Vec2f(32, 32), 2);
		AddIconToken("$undead_mystic_class_icon$", "ExtraMenuItems.png", Vec2f(32, 32), 3);	
		AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
		AddIconToken("$pushbutton_1$", "PushButton.png", Vec2f(16, 16), 2);
    }
}
