#define LOCKER_FULL -1

/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/structures/closet.dmi'
	icon_state = "wood"
	base_icon_state = "wood"
	density = TRUE
	drag_slowdown = 1.5 // Same as a prone mob
	max_integrity = 200
	integrity_failure = 0.25
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 70, ACID = 60)
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

	var/enable_door_overlay = TRUE
	var/has_opened_overlay = TRUE
	var/has_closed_overlay = TRUE
	var/opened = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/breakout_time = 1200
	var/message_cooldown
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/open_sound = 'sound/structure/closet/closet_open.ogg'
	var/close_sound = 'sound/structure/closet/closet_close.ogg'
	var/open_sound_volume = 35
	var/close_sound_volume = 50
	var/material_drop = /obj/item/stack/sheet/iron
	var/material_drop_amount = 2
	var/anchorable = TRUE
	/// Whether a skittish person can dive inside this closet. Disable if opening the closet causes "bad things" to happen or that it leads to a logical inconsistency.
	var/divable = TRUE
	/// true whenever someone with the strong pull component is dragging this, preventing opening
	var/strong_grab = FALSE
	var/can_have_lock = TRUE
	/// The installed lock if any.
	var/obj/item/lock/lock
	/// Name of the lock overlay to look for in the icon file
	var/lock_overlay = "lock"

/obj/structure/closet/Initialize(mapload)
	if(mapload && !opened) // if closed, any item at the crate's loc is put in the contents
		addtimer(CALLBACK(src, .proc/take_contents), 0)
	. = ..()
	update_appearance()
	PopulateContents()

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/handle_atom_del(atom/A)
	if(A == lock)
		lock = null
		update_appearance()
	return ..()

/obj/structure/closet/Destroy()
	if(lock)
		qdel(lock)
	dump_contents()
	return ..()

/obj/structure/closet/update_icon()
	. = ..()
	layer = opened ? BELOW_OBJ_LAYER : OBJ_LAYER

/obj/structure/closet/update_overlays()
	. = ..()
	closet_update_overlays(.)

/obj/structure/closet/proc/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(enable_door_overlay)
		if(opened && has_opened_overlay)
			var/mutable_appearance/door_overlay = mutable_appearance(icon, "[base_icon_state]_open", alpha = src.alpha)
			. += door_overlay
			door_overlay.overlays += emissive_blocker(door_overlay.icon, door_overlay.icon_state, alpha = door_overlay.alpha) // If we don't do this the door doesn't block emissives and it looks weird.
		else if(has_closed_overlay)
			. += "[base_icon_state]_door"

	if(opened)
		return

	if(lock)
		. += "lock"

/obj/structure/closet/examine(mob/user)
	. = ..()
	if(anchored)
		. += SPAN_NOTICE("It is <b>bolted</b> to the ground.")
	if(HAS_TRAIT(user, TRAIT_SKITTISH) && divable)
		. += SPAN_NOTICE("If you bump into [p_them()] while running, you will jump inside.")
	if(lock)
		. += SPAN_NOTICE("There is a lock installed.")

/obj/structure/closet/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(wall_mounted)
		return TRUE

/obj/structure/closet/proc/can_open(mob/living/user, force = FALSE)
	if(force)
		return TRUE
	if(lock && lock.locked)
		playsound(src, 'sound/structure/door/door_locked.ogg', 30, FALSE, FALSE)
		to_chat(user, SPAN_WARNING("\The [src] is locked!"))
		user.changeNext_move(CLICK_CD_MELEE)
		return FALSE
	if(strong_grab)
		to_chat(user, SPAN_DANGER("[pulledby] has an incredibly strong grip on [src], preventing it from opening."))
		return FALSE
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, SPAN_DANGER("There's something large on top of [src], preventing it from opening."))
			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
	var/turf/T = get_turf(src)
	for(var/obj/structure/closet/closet in T)
		if(closet != src && !closet.wall_mounted)
			return FALSE
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, SPAN_DANGER("There's something too large in [src], preventing it from closing."))
			return FALSE
	return TRUE

/obj/structure/closet/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && insert(AM) == LOCKER_FULL) // limit reached
			break
	for(var/i in reverseRange(L.GetAllContents()))
		var/atom/movable/thing = i
		SEND_SIGNAL(thing, COMSIG_TRY_STORAGE_HIDE_ALL)

/obj/structure/closet/proc/open(mob/living/user, force = FALSE)
	if(!can_open(user, force))
		return
	if(opened)
		return
	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	opened = TRUE
	if(!dense_when_open)
		set_density(FALSE)
	dump_contents()
	update_appearance()
	after_open(user, force)
	return TRUE

///Proc to override for effects after opening a door
/obj/structure/closet/proc/after_open(mob/living/user, force = FALSE)
	return

/obj/structure/closet/proc/insert(atom/movable/inserted)
	if(length(contents) >= storage_capacity)
		return LOCKER_FULL
	if(!insertion_allowed(inserted))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_CLOSET_INSERT, inserted) & COMPONENT_CLOSET_INSERT_INTERRUPT)
		return TRUE
	inserted.forceMove(src)
	return TRUE

/obj/structure/closet/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || L.buckled || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(horizontal && L.density)
				return FALSE
			if(L.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return FALSE
		L.stop_pulling()

	else if(istype(AM, /obj/structure/closet))
		return FALSE
	else if(isobj(AM))
		if((!allow_dense && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!allow_objects)
			return FALSE
	else
		return FALSE

	return TRUE

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened || !can_close(user))
		return FALSE
	take_contents()
	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	opened = FALSE
	set_density(TRUE)
	update_appearance()
	after_close(user)
	return TRUE

///Proc to override for effects after closing a door
/obj/structure/closet/proc/after_close(mob/living/user)
	return


/obj/structure/closet/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags_1 & NODECONSTRUCT_1))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		bust_open()

/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	if(istype(W, /obj/item/lockpick))
		var/obj/item/lockpick/lockpick_item = W
		if(!lock)
			to_chat(user, SPAN_WARNING("\The [src] does not have a lock!"))
			return
		lock.attempt_lockpick(user, lockpick_item)
		return
	if(istype(W, /obj/item/lock))
		var/obj/item/lock/lock_item = W
		if(!can_have_lock)
			to_chat(user, SPAN_WARNING("You can't figure out how to install a lock on \the [src]."))
			return
		if(lock)
			to_chat(user, SPAN_WARNING("\The [src] already has a lock!"))
			return
		to_chat(user, SPAN_NOTICE("You install \the [lock_item] on \the [src]."))
		install_lock(lock_item)
		return
	if(istype(W, /obj/item/key))
		var/obj/item/key/key_item = W
		if(!lock)
			to_chat(user, SPAN_WARNING("\The [src] does not have a lock!"))
			return
		if(opened)
			to_chat(user, SPAN_WARNING("Close \the [src] first!"))
			return
		lock.attempt_key_toggle(user, key_item)
		return
	if(tool_interact(W,user))
		return TRUE // No afterattack
	else
		return ..()

/obj/structure/closet/proc/tool_interact(obj/item/W, mob/living/user)//returns TRUE if attackBy call shouldn't be continued (because tool was used/closet was of wrong type), FALSE if otherwise
	. = TRUE
	if(W.tool_behaviour == TOOL_WRENCH && anchorable)
		if(isinspace() && !anchored)
			return
		set_anchored(!anchored)
		W.play_tool_sound(src, 75)
		user.visible_message(SPAN_NOTICE("[user] [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground."), \
						SPAN_NOTICE("You [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground."), \
						SPAN_HEAR("You hear a ratchet."))
	else
		return FALSE

/obj/structure/closet/proc/after_weld(weld_state)
	return

/obj/structure/closet/mouse_dropped(atom/movable/O, mob/living/user, params)
	if(!istype(O) || O.anchored || istype(O, /atom/movable/screen))
		return
	if(!istype(user) || user.incapacitated() || user.body_position == LYING_DOWN)
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = FALSE
	if(isliving(O))
		actuallyismob = TRUE
	else if(!isitem(O))
		return
	var/turf/T = get_turf(src)
	var/list/targets = list(O, src)
	add_fingerprint(user)
	user.visible_message(SPAN_WARNING("[user] [actuallyismob ? "tries to ":""]stuff [O] into [src]."), \
		SPAN_WARNING("You [actuallyismob ? "try to ":""]stuff [O] into [src]."), \
		SPAN_HEAR("You hear clanging."))
	if(actuallyismob)
		if(do_after_mob(user, targets, 4 SECONDS))
			user.visible_message(SPAN_NOTICE("[user] stuffs [O] into [src]."), \
				SPAN_NOTICE("You stuff [O] into [src]."), \
				SPAN_HEAR("You hear a loud metal bang."))
			var/mob/living/L = O
			L.Paralyze(4 SECONDS)
			O.forceMove(T)
			close()
	else
		O.forceMove(T)
	return TRUE

/obj/structure/closet/relaymove(mob/living/user, direction)
	if(user.stat || !isturf(loc))
		return
	container_resist_act(user)

/obj/structure/closet/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.body_position == LYING_DOWN && get_dist(src, user) > 0)
		return

	toggle(user)


/obj/structure/closet/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	if(attack_hand(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/closet/verb/verb_toggleopen()
	set src in view(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(iscarbon(usr))
		return toggle(usr)
	else
		to_chat(usr, SPAN_WARNING("This mob type can't use this verb."))

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/leaving, direction)
	open()
	if(leaving.loc == src)
		return FALSE
	return TRUE

/obj/structure/closet/container_resist_act(mob/living/user)
	if(opened)
		return
	if(ismovable(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist_act(user, src)
		return
	if(!(lock && lock.locked))
		open()
		return

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(SPAN_WARNING("[src] begins to shake violently!"), \
		SPAN_NOTICE("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
		SPAN_HEAR("You hear banging from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || !(lock && lock.locked))
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message(SPAN_DANGER("[user] successfully broke out of [src]!"),
							SPAN_NOTICE("You successfully break out of [src]!"))
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, SPAN_WARNING("You fail to break out of [src]!"))

/obj/structure/closet/proc/bust_open()
	SIGNAL_HANDLER
	if(lock)
		lock.set_locked_state(FALSE)
	open()

/obj/structure/closet/proc/install_lock(obj/item/lock/lock_item)
	if(lock)
		qdel(lock)
	lock = lock_item
	lock.moveToNullspace()
	lock.installed = src
	update_appearance()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, HUD_IMPAIRMENT_HALF_BLIND)

/obj/structure/closet/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in src)
			O.emp_act(severity)

/obj/structure/closet/contents_explosion(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += contents
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += contents
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += contents

/obj/structure/closet/AllowDrop()
	return TRUE

/obj/structure/closet/return_temperature()
	return

#undef LOCKER_FULL

/obj/structure/closet/wood
	name = "wooden closet"
	desc = "It's a basic storage unit."
	icon_state = "wood"
	base_icon_state = "wood"

/obj/structure/closet/steel
	name = "steel closet"
	desc = "It's a basic storage unit."
	icon_state = "steel"
	base_icon_state = "steel"
