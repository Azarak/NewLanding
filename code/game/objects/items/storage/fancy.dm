/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * Contains:
 * Donut Box
 * Egg Box
 * Candle Box
 * Cigarette Box
 * Cigar Case
 * Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox"
	base_icon_state = "donutbox"
	resistance_flags = FLAMMABLE
	/// Used by examine to report what this thing is holding.
	var/contents_tag = "errors"
	/// What type of thing to fill this storage with.
	var/spawn_type = null
	/// Whether the container is open or not
	var/is_open = FALSE
	/// What this container folds up into when it's empty.
	var/obj/fold_result

/obj/item/storage/fancy/PopulateContents()
	if(!spawn_type)
		return
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/fancy/update_icon_state()
	icon_state = "[base_icon_state][is_open ? contents.len : null]"
	return ..()

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	if(!is_open)
		return
	if(length(contents) == 1)
		. += "There is one [contents_tag] left."
	else
		. += "There are [contents.len <= 0 ? "no" : "[contents.len]"] [contents_tag]s left."

/obj/item/storage/fancy/attack_self(mob/user)
	is_open = !is_open
	update_appearance()
	. = ..()
	if(contents.len)
		return
	new fold_result(user.drop_location())
	to_chat(user, SPAN_NOTICE("You fold the [src] into [initial(fold_result.name)]."))
	user.put_in_active_hand(fold_result)
	qdel(src)

/obj/item/storage/fancy/Exited(atom/movable/gone, direction)
	. = ..()
	is_open = TRUE
	update_appearance()

/obj/item/storage/fancy/Entered(atom/movable/arrived, direction)
	. = ..()
	is_open = TRUE
	update_appearance()
