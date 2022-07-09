/obj/structure/wheelbarrow
	name = "wheelbarrow"
	desc = "A wooden wheelbarrow. Useful in moving heavy things around."
	icon = 'icons/obj/structures/wheelbarrow.dmi'
	icon_state = "wheelbarrow"
	base_icon_state = "wheelbarrow"
	density = TRUE
	anchored = FALSE
	pass_flags_self = PASSTABLE | LETPASSTHROW
	layer = TABLE_LAYER
	drag_slowdown = 2
	/// The contained items of the wheelbarrow.
	var/list/contained_items = list()
	/// The contained mobs of the wheelbarrow.
	var/list/contained_mobs = list()

/obj/structure/wheelbarrow/Initialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)
	AddElement(/datum/element/climbable)
	update_appearance()

/obj/structure/wheelbarrow/Destroy()
	for(var/obj/item/item as anything in contained_items)
		remove_item(item)
	for(var/mob/living/living as anything in contained_mobs)
		remove_mob(living)
	return ..()

/obj/structure/wheelbarrow/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "[base_icon_state]_overlay", layer = ABOVE_OBJ_LAYER)

/obj/structure/wheelbarrow/Moved(atom/oldloc, dir, forced)
	. = ..()
	if(loc == oldloc)
		return
	for(var/obj/item/item as anything in contained_items)
		item.glide_size = glide_size
		item.forceMove(loc)
	for(var/mob/living/living as anything in contained_mobs)
		living.glide_size = glide_size
		living.forceMove(loc)

/obj/structure/wheelbarrow/attackby(obj/item/item, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if(!user.combat_mode && !(item.item_flags & ABSTRACT))
		if(user.transferItemToLoc(item, loc, silent = FALSE, user_click_modifiers = modifiers))
			return TRUE
	return ..()

/obj/structure/wheelbarrow/proc/on_entered(datum/source, atom/movable/crossing)
	SIGNAL_HANDLER
	try_contain_atom(crossing)

#define MAXIMUM_W_CLASS_DRAG 25
#define MAXIMUM_CONTAINED_MOBS 2

/obj/structure/wheelbarrow/proc/try_contain_atom(atom/movable/contain)
	if(isitem(contain))
		if(contain in contained_items)
			return FALSE
		if(get_contained_total_w_class() > MAXIMUM_W_CLASS_DRAG)
			return FALSE
		contain_item(contain)
		return TRUE
	if(isliving(contain))
		if(contain in contained_mobs)
			return FALSE
		if(contained_mobs.len >= MAXIMUM_CONTAINED_MOBS)
			return FALSE
		contain_mob(contain)
		return TRUE
	return FALSE

#undef MAXIMUM_CONTAINED_MOBS
#undef MAXIMUM_W_CLASS_DRAG

/obj/structure/wheelbarrow/proc/contain_item(obj/item/contained)
	contained_items += contained
	RegisterSignal(contained, COMSIG_MOVABLE_MOVED, .proc/on_item_move)

/obj/structure/wheelbarrow/proc/remove_item(obj/item/contained)
	contained_items -= contained
	UnregisterSignal(contained, COMSIG_MOVABLE_MOVED)

/obj/structure/wheelbarrow/proc/get_contained_total_w_class()
	var/total_w_class = 0
	for(var/obj/item/item_thing as anything in contained_items)
		total_w_class += item_thing.w_class
	return total_w_class

/obj/structure/wheelbarrow/proc/on_item_move(obj/item/item, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(item.loc != loc)
		remove_item(item)

/obj/structure/wheelbarrow/proc/contain_mob(mob/living/living)
	contained_mobs += living
	RegisterSignal(living, COMSIG_MOVABLE_MOVED, .proc/on_mob_move)

/obj/structure/wheelbarrow/proc/remove_mob(mob/living/living)
	contained_mobs -= living
	UnregisterSignal(living, COMSIG_MOVABLE_MOVED)

/obj/structure/wheelbarrow/proc/on_mob_move(mob/living/living, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(living.loc != loc)
		remove_mob(living)
