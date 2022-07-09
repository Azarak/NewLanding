/obj/structure/obstruction
	abstract_type = /obj/structure/obstruction
	name = "obstruction"
	icon = 'icons/obj/structures/obstruction.dmi'
	desc = "Something obstructing your way, in one way or another."
	max_integrity = 300
	anchored = TRUE
	integrity_failure = 0.5
	/// Icon state to use when the obstruction is cleared.
	var/clear_icon_state = "empty"
	/// Icon state of an overlay to apply on the floor layer.
	var/floor_overlay
	/// Icon state of an overlay to apply on the floor layer, when cleared.
	var/clear_floor_overlay
	/// Obstruction state. Internal variable
	var/obstructs

	/// Whether the obstruction regrows over time
	var/regrows = TRUE
	/// Minimum amount of time to regrow.
	var/regrow_time_low = 30 MINUTES
	/// Maximum amount of time to regrow.
	var/regrow_time_high = 50 MINUTES

	/// Whether the obstruction can be cleared by attack.
	var/clear_by_attack = FALSE
	/// Required sharpness to clear it attack.
	var/required_sharpness = FALSE
	/// Required force to clear it by attack
	var/required_force = 0

	/// Whether the obstruction can be cleared by an action.
	var/clear_by_action = FALSE
	/// Required tool to clear it by action.
	var/required_tool
	/// How long does the action clear take.
	var/clear_action_time = 5 SECONDS

	/// What explosion severity can clear the obstruction.
	var/explosion_clear_severity

	/// Whether the obstruction is dense.
	var/obstruction_dense = FALSE
	/// Whether the obstruction is opaque.
	var/obstruction_opaque = FALSE
	/// Whether the obstruction obstructs multi-z openspaces.
	var/obstruction_multiz = FALSE
	/// How much slowdown do we apply when obstructing.
	var/obstruction_slowdown = 0
	/// Whether the obstruction can be climbed on.
	var/obstruction_climbable = FALSE
	/// How long does it take to climb on the obstruction.
	var/obstruction_climb_time = 2 SECONDS

/obj/structure/obstruction/Initialize()
	. = ..()
	/// If it's climbable, it should allow things to pass through it
	if(obstruction_climbable)
		pass_flags_self = PASSTABLE | LETPASSTHROW

/obj/structure/obstruction/ex_act(severity, target)
	if(isnull(explosion_clear_severity) || severity < explosion_clear_severity)
		return
	set_obstruction_state(FALSE)

/obj/structure/obstruction/update_icon_state()
	. = ..()
	if(obstructs)
		icon_state = get_base_icon_state()
	else
		icon_state = get_clear_icon_state()

/obj/structure/obstruction/proc/get_base_icon_state()
	return base_icon_state

/obj/structure/obstruction/proc/get_clear_icon_state()
	return clear_icon_state

/obj/structure/obstruction/update_overlays()
	. = ..()
	var/state_to_use
	if(obstructs)
		state_to_use = floor_overlay
	else
		state_to_use = clear_floor_overlay
	if(state_to_use)
		. += mutable_appearance(icon, state_to_use, plane = FLOOR_PLANE, layer = ABOVE_NORMAL_TURF_LAYER)

/obj/structure/obstruction/Initialize()
	. = ..()
	set_obstruction_state(TRUE)

/obj/structure/obstruction/attackby(obj/item/item, mob/living/user, params)
	if(!obstructs)
		return TRUE
	if(clear_by_attack)
		if(required_sharpness && !item.sharpness)
			to_chat(user, SPAN_WARNING("\The [item] is not sharp enough to damage [src]!"))
			return TRUE
		if(item.force < required_force)
			to_chat(user, SPAN_WARNING("\The [item] is too weak to damage [src]!"))
			return TRUE
		return ..()
	if(clear_by_action)
		user_clear_action(user, item)
	return TRUE

/obj/structure/obstruction/obj_break(damage_flag)
	. = ..()
	set_obstruction_state(FALSE)

/obj/structure/obstruction/obj_fix()
	. = ..()
	set_obstruction_state(TRUE)

/obj/structure/obstruction/deconstruct(disassembled = TRUE)
	return

/obj/structure/obstruction/proc/user_clear_action(mob/living/user, obj/item/item)
	if(required_tool && item.tool_behaviour != required_tool)
		to_chat(user, SPAN_WARNING("You can't quite figure out how to clear \the [src] with \the [item]."))
		return TRUE
	user.visible_message(
		SPAN_NOTICE("[user] starts clearing \the [src] with \the [item]."), 
		SPAN_NOTICE("You start clearing \the [src] with \the [item].")
		)
	if(item.use_tool(src, user, clear_action_time, volume = 50))
		if(!obstructs)
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] clears \the [src]."), 
			SPAN_NOTICE("You clear \the [src].")
			)
		set_obstruction_state(FALSE)
	return TRUE

/obj/structure/obstruction/proc/set_obstruction_state(new_state)
	if(new_state == obstructs)
		return
	obstructs = new_state
	obstruction_state_effects()
	update_appearance()
	if(!obstructs)
		if(regrows)
			addtimer(CALLBACK(src, .proc/timed_regrow), rand(regrow_time_low, regrow_time_high))
		else
			qdel(src)

/obj/structure/obstruction/proc/obstruction_state_effects()
	var/turf/my_turf = loc
	if(obstructs)
		my_turf.slowdown += obstruction_slowdown
		opacity = obstruction_opaque
		density = obstruction_dense
		if(obstruction_multiz)
			obj_flags |= FULL_BLOCK_Z_BELOW
		if(obstruction_climbable)
			AddElement(/datum/element/climbable, obstruction_climb_time)
	else
		my_turf.slowdown -= obstruction_slowdown
		opacity = FALSE
		density = FALSE
		if(obstruction_multiz)
			obj_flags &= ~FULL_BLOCK_Z_BELOW
		if(obstruction_climbable)
			RemoveElement(/datum/element/climbable, obstruction_climb_time)
	if(obstruction_multiz)
		my_turf.update_turf_transparency()

/obj/structure/obstruction/proc/timed_regrow()
	if(QDELETED(src))
		return
	repair_damage(max_integrity)
