/*
All ShuttleMove procs go here
*/

/************************************Base procs************************************/

// Called on every turf in the shuttle region, returns a bitflag for allowed movements of that turf
// returns the new move_mode (based on the old)
/turf/proc/fromShuttleMove(turf/newT, move_mode)
	if(!(move_mode & MOVE_AREA) || !isshuttleturf(src))
		return move_mode

	return move_mode | MOVE_TURF | MOVE_CONTENTS

// Called from the new turf before anything has been moved
// Only gets called if fromShuttleMove returns true first
// returns the new move_mode (based on the old)
/turf/proc/toShuttleMove(turf/oldT, move_mode, obj/docking_port/mobile/shuttle)
	. = move_mode
	if(!(. & MOVE_TURF))
		return

	var/shuttle_dir = shuttle.dir
	for(var/i in contents)
		var/atom/movable/thing = i
		if(ismob(thing))
			if(isliving(thing))
				var/mob/living/M = thing
				if(M.buckled)
					M.buckled.unbuckle_mob(M, 1)
				if(M.pulledby)
					M.pulledby.stop_pulling()
				M.stop_pulling()
				M.visible_message(SPAN_WARNING("[shuttle] slams into [M]!"))
				SSblackbox.record_feedback("tally", "shuttle_gib", 1, M.type)
				log_attack("[key_name(M)] was shuttle gibbed by [shuttle].")
				M.gib()


		else //non-living mobs shouldn't be affected by shuttles, which is why this is an else
			if(!thing.anchored)
				step(thing, shuttle_dir)
			else
				qdel(thing)

// Called on the old turf to move the turf data
/turf/proc/onShuttleMove(turf/newT, list/movement_force, move_dir)
	if(newT == src) // In case of in place shuttle rotation shenanigans.
		return
	//Destination turf changes
	//Baseturfs is definitely a list or this proc wouldnt be called
	var/shuttle_boundary = baseturfs.Find(/turf/baseturf_skipover/shuttle)
	if(!shuttle_boundary)
		CRASH("A turf queued to move via shuttle somehow had no skipover in baseturfs. [src]([type]):[loc]")
	var/depth = baseturfs.len - shuttle_boundary + 1
	newT.CopyOnTop(src, 1, depth, TRUE)
	newT.blocks_air = TRUE
	newT.air_update_turf(TRUE, FALSE)
	blocks_air = TRUE
	air_update_turf(TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_TURF_ON_SHUTTLE_MOVE, newT)

	return TRUE

// Called on the new turf after everything has been moved
/turf/proc/afterShuttleMove(turf/oldT, rotation)
	//Dealing with the turf we left behind
	oldT.TransferComponents(src)

	SSexplosions.wipe_turf(src)
	var/shuttle_boundary = baseturfs.Find(/turf/baseturf_skipover/shuttle)
	if(shuttle_boundary)
		oldT.ScrapeAway(baseturfs.len - shuttle_boundary + 1)

	if(rotation)
		shuttleRotate(rotation) //see shuttle_rotate.dm

	return TRUE

/turf/proc/lateShuttleMove(turf/oldT)
	blocks_air = initial(blocks_air)
	air_update_turf(TRUE, blocks_air)
	oldT.blocks_air = initial(oldT.blocks_air)
	oldT.air_update_turf(TRUE, oldT.blocks_air)


/////////////////////////////////////////////////////////////////////////////////////

// Called on every atom in shuttle turf contents before anything has been moved
// returns the new move_mode (based on the old)
// WARNING: Do not leave turf contents in beforeShuttleMove or dock() will runtime
/atom/movable/proc/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	return move_mode

// Called on atoms to move the atom to the new location
/atom/movable/proc/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return

	if(loc != oldT) // This is for multi tile objects
		return

	abstract_move(newT)

	return TRUE

// Called on atoms after everything has been moved
/atom/movable/proc/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)

	var/turf/newT = get_turf(src)
	if (newT.z != oldT.z)
		onTransitZ(oldT.z, newT.z)

	if(light)
		update_light()
	if(rotation)
		shuttleRotate(rotation)
	if(proximity_monitor)
		proximity_monitor.HandleMove()

	return TRUE

/atom/movable/proc/lateShuttleMove(turf/oldT, list/movement_force, move_dir)
	if(!movement_force || anchored)
		return
	var/throw_force = movement_force["THROW"]
	if(!throw_force)
		return
	var/turf/target = get_edge_target_turf(src, move_dir)
	var/range = throw_force * 10
	range = CEILING(rand(range-(range*0.1), range+(range*0.1)), 10)/10
	var/speed = range/5
	safe_throw_at(target, range, speed, force = MOVE_FORCE_EXTREMELY_STRONG)

/////////////////////////////////////////////////////////////////////////////////////

// Called on areas before anything has been moved
// returns the new move_mode (based on the old)
/area/proc/beforeShuttleMove(list/shuttle_areas)
	if(!shuttle_areas[src])
		return NONE
	return MOVE_AREA

// Called on areas to move their turf between areas
/area/proc/onShuttleMove(turf/oldT, turf/newT, area/underlying_old_area)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return TRUE

	var/area/target_area = oldT.underlying_area ? oldT.underlying_area : underlying_old_area
	contents -= oldT
	target_area.contents += oldT
	oldT.change_area(src, target_area)
	oldT.underlying_area = null
	//The old turf has now been given back to the area that turf originaly belonged to
	if(oldT.shuttle_roof)
		QDEL_NULL(oldT.shuttle_roof)

	var/area/old_dest_area = newT.loc

	old_dest_area.contents -= newT
	contents += newT
	newT.change_area(old_dest_area, src)
	newT.underlying_area = old_dest_area

	var/turf/above_turf = newT.above()
	if(above_turf)
		newT.shuttle_roof = new(above_turf)
	return TRUE

// Called on areas after everything has been moved
/area/proc/afterShuttleMove()
	UpdateDayNightTurfs(find_controller = TRUE)
	return TRUE

/area/proc/lateShuttleMove()
	return

/************************************Turf move procs************************************/

/************************************Area move procs************************************/

/************************************Item move procs************************************/

/************************************Mob move procs************************************/

/mob/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if(!move_on_shuttle)
		return
	. = ..()

/mob/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	if(!move_on_shuttle)
		return
	. = ..()
	if(client && movement_force)
		var/shake_force = max(movement_force["THROW"], movement_force["KNOCKDOWN"])
		if(buckled)
			shake_force *= 0.25
		shake_camera(src, shake_force, 1)

/mob/living/lateShuttleMove(turf/oldT, list/movement_force, move_dir)
	if(buckled)
		return

	. = ..()

	var/knockdown = movement_force["KNOCKDOWN"]
	if(knockdown)
		Paralyze(knockdown)


/mob/living/simple_animal/hostile/megafauna/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	. = ..()
	message_admins("Megafauna [src] [ADMIN_FLW(src)] moved via shuttle from [ADMIN_COORDJMP(oldT)] to [ADMIN_COORDJMP(loc)]")

/************************************Structure move procs************************************/

/obj/structure/grille/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(. & MOVE_AREA)
		. |= MOVE_CONTENTS

/obj/structure/ladder/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if (!(resistance_flags & INDESTRUCTIBLE))
		disconnect()

/obj/structure/ladder/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if (!(resistance_flags & INDESTRUCTIBLE))
		LateInitialize()

/obj/structure/ladder/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if (resistance_flags & INDESTRUCTIBLE)
		// simply don't be moved
		return FALSE
	return ..()

/************************************Misc move procs************************************/

/obj/docking_port/mobile/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(moving_dock == src)
		. |= MOVE_CONTENTS

// Never move the stationary docking port, otherwise things get WEIRD
/obj/docking_port/stationary/onShuttleMove()
	return FALSE

// Special movable stationary port, for your mothership shenanigans
/obj/docking_port/stationary/movable/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if(!moving_dock.can_move_docking_ports || old_dock == src)
		return FALSE

	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return

	if(loc != oldT) // This is for multi tile objects
		return

	abstract_move(newT)

	return TRUE

/obj/docking_port/stationary/public_mining_dock/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	id = "mining_public" //It will not move with the base, but will become enabled as a docking point.

/obj/effect/abstract/proximity_checker/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	//timer so it only happens once
	addtimer(CALLBACK(monitor, /datum/proximity_monitor/proc/SetRange, monitor.current_range, TRUE), 0, TIMER_UNIQUE)
