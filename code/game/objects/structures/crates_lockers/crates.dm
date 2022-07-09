/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "wood"
	base_icon_state = "wood"
	horizontal = TRUE
	allow_objects = TRUE
	allow_dense = TRUE
	dense_when_open = TRUE
	open_sound = 'sound/structure/closet/crate_open.ogg'
	close_sound = 'sound/structure/closet/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	material_drop = /obj/item/stack/sheet/steel
	material_drop_amount = 2
	drag_slowdown = 0
	pass_flags_self = PASSSTRUCTURE | LETPASSTHROW
	var/crate_climb_time = 20

/obj/structure/closet/crate/Initialize()
	. = ..()
	if(icon_state == "[base_icon_state]_open")
		opened = TRUE
		AddElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)
	else
		AddElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	update_appearance()

/obj/structure/closet/crate/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!istype(mover, /obj/structure/closet))
		var/obj/structure/closet/crate/locatedcrate = locate(/obj/structure/closet/crate) in get_turf(mover)
		if(locatedcrate) //you can walk on it like tables, if you're not in an open crate trying to move to a closed crate
			if(opened) //if we're open, allow entering regardless of located crate openness
				return TRUE
			if(!locatedcrate.opened) //otherwise, if the located crate is closed, allow entering
				return TRUE

/obj/structure/closet/crate/update_icon_state()
	if(opened)
		icon_state = "[base_icon_state]_open"
	else
		icon_state = base_icon_state
	return ..()

/obj/structure/closet/crate/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(lock) //We have a lock
		. += "lock"

/obj/structure/closet/crate/after_open(mob/living/user, force)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	AddElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)

/obj/structure/closet/crate/after_close(mob/living/user, force)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)
	AddElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)

/obj/structure/closet/crate/wood
	name = "wooden crate"
	desc = "A rectangular wooden crate."
	icon_state = "wood"
	base_icon_state = "wood"

/obj/structure/closet/crate/steel
	name = "steel crate"
	desc = "A rectangular steel crate."
	icon_state = "steel"
	base_icon_state = "steel"

/obj/structure/closet/crate/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	base_icon_state = "coffin"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/wood
	material_drop_amount = 5
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
