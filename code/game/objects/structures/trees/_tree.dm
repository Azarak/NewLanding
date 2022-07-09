/obj/structure/tree
	abstract_type = /obj/structure/tree
	name = "tree"
	desc = "A large tree."
	icon = 'icons/obj/structures/tree_big.dmi'
	icon_state = "tree"
	density = TRUE
	anchored = TRUE
	layer = FLY_LAYER
	/// What stump will this tree turn into after being chopped down.
	var/stump_type = /obj/structure/tree_stump
	/// What log will drop from the tree when its chopped down.
	var/log_type = /obj/structure/tree_log
	/// Progress towards chopping this down.
	var/chop_progress = 0
	var/logs_to_drop = 1

/obj/structure/tree/Initialize()
	. = ..()
	/// convert pixel x and pixel y into a matrix translation to make do_after bars and animations display correctly.
	var/matrix/new_matrix = new
	new_matrix.Translate(pixel_x, pixel_y)
	transform = new_matrix
	pixel_x = 0
	pixel_y = 0
	icon_state = "tree[rand(1,6)]"

/obj/structure/tree/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return
	chop_down()

/obj/structure/tree/attackby(obj/item/tool, mob/user, params)
	if(tool.tool_behaviour == TOOL_AXE)
		var/chopping_loop = TRUE
		to_chat(user, SPAN_NOTICE("You start chopping \the [src] down."))
		while(TRUE)
			if(tool.use_tool(src, user, 2 SECONDS, volume = 30))
				user.do_attack_animation(src)
				user.visible_message(
					SPAN_NOTICE("[user] chops \the [src] with \the [tool]."),
					SPAN_NOTICE("You chops \the [src] with \the [tool].")
					)
				add_chop_progress(rand(7,12))
				if(QDELETED(src))
					chopping_loop = FALSE
			else
				chopping_loop = FALSE
			if(!chopping_loop)
				to_chat(user, SPAN_NOTICE("You finish woodcutting."))
				break
		return TRUE
	return ..()

/obj/structure/tree/proc/add_chop_progress(progress)
	chop_progress += progress
	if(chop_progress >= 100)
		chop_down()

/obj/structure/tree/proc/chop_down()
	visible_message(SPAN_WARNING("\The [src] falls down!"))
	var/fall_direction = pick(GLOB.cardinals_diagonals)
	var/turf/drop_turf = loc
	for(var/i in 1 to 2)
		var/turf/evaluate_turf = get_step(drop_turf, fall_direction)
		if(evaluate_turf && !evaluate_turf.density)
			drop_turf = evaluate_turf
		new log_type(drop_turf)
	new stump_type(loc)
	qdel(src)

/obj/structure/tree/small
	icon = 'icons/obj/structures/tree_small.dmi'
	pixel_x = -32
	pixel_y = -6
	logs_to_drop = 1

/obj/structure/tree/big
	icon = 'icons/obj/structures/tree_big.dmi'
	pixel_x = -48
	pixel_y = -20
	logs_to_drop = 2

/obj/structure/tree_stump
	name = "tree stump"
	desc = "A tree stump."
	icon = 'icons/obj/structures/tree_stump.dmi'
	icon_state = "stump"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE | LETPASSTHROW

/obj/structure/tree_stump/Initialize()
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/tree_stump/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return
	qdel(src)

/obj/structure/tree_stump/attackby(obj/item/tool, mob/user, params)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		user.visible_message(
					SPAN_NOTICE("[user] begins to dig out \the [src] with \the [tool]."),
					SPAN_NOTICE("You begin to dig out \the [src] with \the [tool].")
					)
		if(tool.use_tool(src, user, 6 SECONDS, volume = 20))
			user.visible_message(
				SPAN_NOTICE("[user] digs out the \the [src] with \the [tool]."),
				SPAN_NOTICE("You dig out the \the [src] with \the [tool].")
				)
			new /obj/item/grown/log(loc)
			qdel(src)
		return TRUE
	return ..()

/obj/structure/tree_log
	name = "tree log"
	desc = "A tree log."
	icon = 'icons/obj/structures/tree_log.dmi'
	icon_state = "log"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE | LETPASSTHROW
	/// Progress towards chopping this down.
	var/chop_progress = 0

/obj/structure/tree_log/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("You could roll the log around by dragging it with your mouse.")

/obj/structure/tree_log/mouse_drop_onto(atom/dropped, mob/user)
	. = ..()
	if(.)
		return
	if(!isturf(dropped))
		return
	var/turf/dropped_turf = dropped
	if(mouse_drop_fail(dropped_turf))
		to_chat(user, SPAN_WARNING("You can't roll the log there!"))
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts rolling \the [src] onto \the [dropped_turf]."),
		SPAN_NOTICE("You start rolling \the [src] onto \the [dropped_turf].")
		)
	user.face_atom(src)
	if(do_after(user, 4 SECONDS, target = src))
		if(QDELETED(src) || mouse_drop_fail(dropped_turf))
			return
		user.visible_message(
			SPAN_NOTICE("[user] rolls \the [src] onto \the [dropped_turf]."),
			SPAN_NOTICE("You rolls \the [src] onto \the [dropped_turf].")
			)
		forceMove(dropped_turf)
		user.face_atom(src)
	return TRUE

/obj/structure/tree_log/proc/mouse_drop_fail(turf/dropped_turf)
	if(dropped_turf.is_blocked_turf())
		return TRUE
	if(!Adjacent(dropped_turf))
		return TRUE
	return FALSE

/obj/structure/tree_log/Initialize()
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/tree_log/attackby(obj/item/tool, mob/user, params)
	if(tool.tool_behaviour == TOOL_AXE)
		var/chopping_loop = TRUE
		to_chat(user, SPAN_NOTICE("You start chopping \the [src] down."))
		while(TRUE)
			if(tool.use_tool(src, user, 2 SECONDS, volume = 20))
				user.do_attack_animation(src)
				user.visible_message(
					SPAN_NOTICE("[user] chops \the [src] with \the [tool]."),
					SPAN_NOTICE("You chops \the [src] with \the [tool].")
					)
				add_chop_progress(rand(15,20))
				if(QDELETED(src))
					chopping_loop = FALSE
			else
				chopping_loop = FALSE
			if(!chopping_loop)
				to_chat(user, SPAN_NOTICE("You finish woodcutting."))
				break
		return TRUE
	return ..()

/obj/structure/tree_log/proc/add_chop_progress(progress)
	chop_progress += progress
	if(chop_progress >= 100)
		chop_down()

/obj/structure/tree_log/proc/chop_down()
	new /obj/item/grown/log(loc)
	new /obj/item/grown/log(loc)
	qdel(src)

/obj/structure/tree_log/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return
	chop_down()
