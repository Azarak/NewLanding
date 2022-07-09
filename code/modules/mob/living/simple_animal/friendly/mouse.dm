/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeak!","SQUEAK!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("squeaks.")
	emote_see = list("runs in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	var/body_color //brown, gray and white, leave blank for random
	gold_core_spawnable = FRIENDLY_SPAWN
	var/chew_probability = 1
	can_be_held = TRUE
	held_state = "mouse_gray"
	faction = list("rat")

/mob/living/simple_animal/mouse/Initialize()
	. = ..()
	AddElement(/datum/element/animal_variety, "mouse", pick("brown","gray","white"), FALSE)
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg' = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever
	add_cell_sample()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)

/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.icon_dead = "mouse_[body_color]_splat"
	death()

/mob/living/simple_animal/mouse/death(gibbed, toast)
	if(!ckey)
		..(TRUE)
		if(!gibbed)
			var/obj/item/food/deadmouse/M = new(loc)
			M.icon_state = icon_dead
			M.name = name
			if(toast)
				M.add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
				M.desc = "It's toast."
		qdel(src)


/mob/living/simple_animal/mouse/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, SPAN_NOTICE("[icon2html(src, M)] Squeak!"))


/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	body_color = "white"
	icon_state = "mouse_white"
	held_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"
	held_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/mouse/brown/tom/Initialize()
	. = ..()
	AddElement(/datum/element/pet_bonus, "squeaks happily!")
	// Tom fears no cable.
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, SPECIES_TRAIT)

/obj/item/food/deadmouse
	name = "dead mouse"
	desc = "It looks like somebody dropped the bass on it. A lizard's favorite meal."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray_dead"
	bite_consumption = 3
	eatverbs = list("devour")
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GROSS | MEAT | RAW
	grind_results = list(/datum/reagent/blood = 20, /datum/reagent/liquidgibs = 5)

/obj/item/food/deadmouse/examine(mob/user)
	. = ..()
	if (reagents?.has_reagent(/datum/reagent/yuck) || reagents?.has_reagent(/datum/reagent/fuel))
		. += SPAN_WARNING("It's dripping with fuel and smells terrible.")

/obj/item/food/deadmouse/attackby(obj/item/I, mob/living/user, params)
	if(I.get_sharpness() && user.combat_mode)
		if(isturf(loc))
			new /obj/item/food/meat/slab/mouse(loc)
			to_chat(user, SPAN_NOTICE("You butcher [src]."))
			qdel(src)
		else
			to_chat(user, SPAN_WARNING("You need to put [src] on a surface to butcher it!"))
	else
		return ..()

/obj/item/food/deadmouse/afterattack(obj/target, mob/living/user, proximity_flag)
	if(proximity_flag && reagents && target.is_open_container())
		// is_open_container will not return truthy if target.reagents doesn't exist
		var/datum/reagents/target_reagents = target.reagents
		var/trans_amount = reagents.maximum_volume - reagents.total_volume * (4 / 3)
		if(target_reagents.has_reagent(/datum/reagent/fuel) && target_reagents.trans_to(src, trans_amount))
			to_chat(user, SPAN_NOTICE("You dip [src] into [target]."))
			reagents.trans_to(target, reagents.total_volume)
		else
			to_chat(user, SPAN_WARNING("That's a terrible idea."))
	else
		return ..()

/obj/item/food/deadmouse/on_grind()
	. = ..()
	reagents.clear_reagents()
