/obj/structure/forage
	abstract_type = /obj/structure/forage
	icon = 'icons/obj/structures/forage.dmi'
	anchored = TRUE
	density = TRUE
	pass_flags_self = PASSTABLE | LETPASSTHROW
	layer = TABLE_LAYER
	/// Icon state to be used when the structure is foraged.
	var/foraged_icon_state
	/// Whether it is possible to forage by hand
	var/forage_by_hand = FALSE

	/// Whether it is possible to forage by tool.
	var/forage_by_tool = FALSE
	/// What tool is required to do a forage.
	var/required_tool

	/// How much time the user needs to spend to forage.
	var/forage_time = 3 SECONDS

	/// Lower bound of how much time until we regrow.
	var/regrow_time_low = 10 MINUTES
	/// Upper bound of how much time until we regrow.
	var/regrow_time_high = 20 MINUTES
	/// Whether we delete ourselves after we are foraged.
	var/one_time_forage = FALSE

	/// What type of item is foraged.
	var/result_type = /obj/item/grown/log
	/// How many of the item is foraged.
	var/result_amount = 1

	/// Internal state of whether the plant is foraged.
	var/foraged = FALSE

/obj/structure/forage/update_icon_state()
	if(foraged)
		icon_state = foraged_icon_state
	else
		icon_state = base_icon_state

/obj/structure/forage/attackby(obj/item/tool, mob/user, params)
	if(foraged)
		return ..()
	if(forage_by_tool && tool.tool_behaviour == required_tool)
		user.visible_message(
			SPAN_NOTICE("[user] begins foraging from \the [src] with \the [tool]."),
			SPAN_NOTICE("You begin foraging \the [src] with \the [tool].")
			)
		if(tool.use_tool(src, user, forage_time, volume = 30))
			if(QDELETED(src) || foraged)
				return
			user.visible_message(
				SPAN_NOTICE("[user] forages from \the [src] with \the [tool]."),
				SPAN_NOTICE("You forage \the [src] with \the [tool].")
				)
			do_forage()
		return TRUE
	return ..()

/obj/structure/forage/attack_hand(mob/user, list/modifiers)
	if(foraged)
		return ..()
	if(forage_by_hand)
		user.visible_message(
			SPAN_NOTICE("[user] begins foraging from \the [src]."),
			SPAN_NOTICE("You begin foraging \the [src].")
			)
		if(do_after(user, forage_time, target = src))
			if(QDELETED(src) || foraged)
				return
			user.visible_message(
				SPAN_NOTICE("[user] forages from \the [src]."),
				SPAN_NOTICE("You forage \the [src].")
				)
			do_forage()
		return TRUE
	return ..()

/obj/structure/forage/proc/do_forage()
	if(foraged)
		return
	foraged = TRUE
	for(var/i in 1 to result_amount)
		new result_type(loc)
	if(one_time_forage)
		qdel(src)
	else
		addtimer(CALLBACK(src, .proc/regrow), rand(regrow_time_low, regrow_time_high))
		update_appearance()
	
/obj/structure/forage/proc/regrow()
	if(QDELETED(src))
		return
	foraged = FALSE
	update_appearance()
