/obj/structure/ore_vein
	abstract_type = /obj/structure/ore_vein
	name = "ore vein"
	desc = "A large rock with chunks of ore."
	icon = 'icons/obj/structures/ore_vein_gags.dmi'
	icon_state = "ore_vein"
	density = TRUE
	anchored = TRUE
	max_integrity = 400
	resistance_flags = FIRE_PROOF
	greyscale_config = /datum/greyscale_config/ore_vein
	greyscale_colors = "#332213#404040"
	armor = list(MELEE = 40, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	/// Ore type to drop
	var/ore_type = /obj/item/stack/ore/iron
	/// Progress to mining the next chunk of ore
	var/mine_progress = 0
	/// Ores remaining to drop from this vein
	var/ores_remaining = 0
	/// When rolling how much ores this has, this is the upper bound
	var/ores_high = 35
	/// When rolling how much ores this has, this is the lower bound
	var/ores_low = 20

#define DEVASTATE_ORE_DROP_LOW 10
#define DEVASTATE_ORE_DROP_HIGH 20
#define HEAVY_ORE_DROP_LOW 5
#define HEAVY_ORE_DROP_HIGH 10
#define LIGHT_ORE_DROP_LOW 3
#define LIGHT_ORE_DROP_HIGH 5

/obj/structure/ore_vein/ex_act(severity, target)
	var/chunks_to_drop
	switch(severity)
		if(EXPLODE_DEVASTATE)
			chunks_to_drop = rand(DEVASTATE_ORE_DROP_LOW, DEVASTATE_ORE_DROP_HIGH)
		if(EXPLODE_HEAVY)
			chunks_to_drop = rand(HEAVY_ORE_DROP_LOW, HEAVY_ORE_DROP_HIGH)
		if(EXPLODE_LIGHT)
			chunks_to_drop = rand(HEAVY_ORE_DROP_LOW, HEAVY_ORE_DROP_HIGH)
	drop_ore_chunks(chunks_to_drop)

/obj/structure/ore_vein/attackby(obj/item/tool, mob/user, params)
	if(tool.tool_behaviour == TOOL_MINING)
		var/mining_loop = TRUE
		to_chat(user, SPAN_NOTICE("You begin mining \the [src]."))
		while(TRUE)
			if(tool.use_tool(src, user, 2 SECONDS, volume = 30))
				user.do_attack_animation(src)
				user.visible_message(
					SPAN_NOTICE("[user] strikes \the [src] with \the [tool]."),
					SPAN_NOTICE("You strike \the [src] with \the [tool].")
					)
				add_mine_progress(rand(15,25))
				if(QDELETED(src))
					mining_loop = FALSE
			else
				mining_loop = FALSE
			if(!mining_loop)
				to_chat(user, SPAN_NOTICE("You finish mining."))
				break
		return TRUE
	return ..()


#undef DEVASTATE_ORE_DROP_LOW
#undef DEVASTATE_ORE_DROP_HIGH
#undef HEAVY_ORE_DROP_LOW
#undef HEAVY_ORE_DROP_HIGH
#undef LIGHT_ORE_DROP_LOW
#undef LIGHT_ORE_DROP_HIGH

/obj/structure/ore_vein/Initialize(mapload)
	. = ..()
	ores_remaining = rand(ores_low, ores_high)
	icon_state = "[initial(icon_state)][rand(1,3)]"

#define ORE_DROP_LOW 1
#define ORE_DROP_HIGH 2

/obj/structure/ore_vein/proc/add_mine_progress(progress)
	mine_progress += progress
	if(mine_progress >= 100)
		mine_progress -= 100
		drop_ore_chunks(rand(ORE_DROP_LOW, ORE_DROP_HIGH))

#undef ORE_DROP_LOW
#undef ORE_DROP_HIGH

/obj/structure/ore_vein/proc/drop_ore_chunks(drop_amount)
	playsound(src, 'sound/effects/break_stone.ogg', 30, TRUE)
	var/actual_yield = min(drop_amount, ores_remaining)
	ores_remaining -= actual_yield

	var/turf/drop_turf = loc

	visible_message(SPAN_NOTICE("Chunks of ore splinter off \the [src]."))
	new ore_type(drop_turf, drop_amount)

	/// We ran out of ores, delete self
	if(!ores_remaining)
		visible_message(SPAN_WARNING("\The [src] breaks down!"))
		qdel(src)

/// Large, opaque and more rich veins
/obj/structure/ore_vein/large
	name = "large ore vein"
	abstract_type = /obj/structure/ore_vein/large
	greyscale_config = /datum/greyscale_config/ore_vein_large
	opacity = TRUE
	ores_low = 30
	ores_high = 45
