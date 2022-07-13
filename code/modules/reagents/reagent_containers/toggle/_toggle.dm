/obj/item/reagent_containers/toggle
	abstract_type = /obj/item/reagent_containers/toggle
	icon = 'icons/obj/items/reagent_containers/toggle.dmi'
	reagent_flags = OPENCONTAINER | REFILLABLE | DRAINABLE
	volume = 50
	var/open_overlay_state
	var/closed_overlay_state
	var/starts_open = FALSE

/obj/item/reagent_containers/toggle/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("You can open or close the container by interacting with it with Alt-Click.")

/obj/item/reagent_containers/toggle/Initialize(mapload, vol)
	. = ..()
	if(starts_open)
		reagent_flags = OPENCONTAINER | REFILLABLE | DRAINABLE
	else
		reagent_flags = NONE
	update_appearance()

/obj/item/reagent_containers/toggle/update_overlays()
	. = ..()
	if(reagent_flags & OPENCONTAINER)
		if(open_overlay_state)
			. += mutable_appearance(icon, open_overlay_state)
	else
		if(closed_overlay_state)
			. += mutable_appearance(icon, closed_overlay_state)

/obj/item/reagent_containers/toggle/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return ..()
	toggle_open_container(user)
	return TRUE

/obj/item/reagent_containers/toggle/proc/toggle_open_container(mob/living/user)
	reagent_flags ^= OPENCONTAINER
	if(reagent_flags & OPENCONTAINER)
		to_chat(user, SPAN_NOTICE("You open \the [src]."))
	else
		to_chat(user, SPAN_NOTICE("You close \the [src]."))
	update_appearance()
