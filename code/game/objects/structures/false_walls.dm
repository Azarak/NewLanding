/*
 * False Walls
 */
/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = TRUE
	icon = 'icons/turf/walls/solid_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	layer = LOW_OBJ_LAYER
	density = TRUE
	opacity = TRUE
	max_integrity = 100
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SHUTTERS_BLASTDOORS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_WINDOW_FULLTILE)
	can_be_unanchored = FALSE
	CanAtmosPass = ATMOS_PASS_DENSITY
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	rad_insulation = RAD_MEDIUM_INSULATION
	var/opening = FALSE
	/// Typecache of the neighboring objects that we want to neighbor stripe overlay with
	var/static/list/neighbor_typecache

/obj/structure/falsewall/Initialize()
	. = ..()
	air_update_turf(TRUE, TRUE)

/obj/structure/falsewall/attack_hand(mob/user, list/modifiers)
	if(opening)
		return
	. = ..()
	if(.)
		return

	opening = TRUE
	update_appearance()
	if(!density)
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = FALSE
			return
	addtimer(CALLBACK(src, /obj/structure/falsewall/proc/toggle_open), 5)

/obj/structure/falsewall/proc/toggle_open()
	if(!QDELETED(src))
		set_density(!density)
		set_opacity(density)
		opening = FALSE
		update_appearance()
		air_update_turf(TRUE, !density)

/obj/structure/falsewall/update_icon(updates=ALL)//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	. = ..()
	if(!density || !(updates & UPDATE_SMOOTHING))
		return

	if(opening)
		smoothing_flags = NONE
		clear_smooth_overlays()
	else
		smoothing_flags = SMOOTH_BITMASK
		QUEUE_SMOOTH(src)

/obj/structure/falsewall/update_icon_state()
	if(opening)
		icon_state = "fwall_[density ? "opening" : "closing"]"
		return ..()
	icon_state = density ? "[base_icon_state]-[smoothing_junction]" : "fwall_open"
	return ..()

/// Partially copypasted from /turf/closed/wall
/obj/structure/falsewall/update_overlays()
	//Updating the unmanaged wall overlays (unmanaged for optimisations)
	overlays.Cut()
	if(density)
		var/neighbor_stripe = NONE
		if(!neighbor_typecache)
			neighbor_typecache = typecacheof(list(/obj/structure/window/reinforced/fulltile, /obj/structure/window/fulltile))
		for(var/cardinal in GLOB.cardinals)
			var/turf/step_turf = get_step(src, cardinal)
			for(var/atom/movable/movable_thing as anything in step_turf)
				if(neighbor_typecache[movable_thing.type])
					neighbor_stripe ^= cardinal
					break
		if(neighbor_stripe)
			var/mutable_appearance/neighb_stripe_appearace = mutable_appearance('icons/turf/walls/neighbor_stripe.dmi', "[neighbor_stripe]", appearance_flags = RESET_COLOR)
			neighb_stripe_appearace.color = color
			overlays += neighb_stripe_appearace
		//And letting anything else that may want to render on the wall to work (ie components)
	return ..()

/obj/structure/falsewall/attackby(obj/item/W, mob/user, params)
	if(opening)
		to_chat(user, SPAN_WARNING("You must wait until the door has stopped moving!"))
		return

	else if(W.tool_behaviour == TOOL_WELDER)
		if(W.use_tool(src, user, 0, volume=50))
			dismantle(user, TRUE)
	else
		return ..()

/obj/structure/falsewall/proc/dismantle(mob/user, disassembled=TRUE, obj/item/tool = null)
	user.visible_message(SPAN_NOTICE("[user] dismantles the false wall."), SPAN_NOTICE("You dismantle the false wall."))
	if(tool)
		tool.play_tool_sound(src, 100)
	else
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
	deconstruct(disassembled)

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	qdel(src)

/obj/structure/falsewall/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/obj/structure/falsewall/examine_status(mob/user) //So you can't detect falsewalls by examine.
	to_chat(user, SPAN_NOTICE("The outer plating is <b>welded</b> firmly in place."))
	return null

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A huge chunk of wood used to separate rooms."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	color = "#533213"

/obj/structure/falsewall/stone
	name = "stone wall"
	desc = "A huge chunk of stone bricks used to separate rooms."
	icon = 'icons/turf/walls/stone_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	color = "#5e5e5e"

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A huge chunk of sandstone bricks used to separate rooms."
	icon = 'icons/turf/walls/stone_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	color = "#c4b982"
