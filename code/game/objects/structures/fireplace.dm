#define LOG_BURN_TIMER 4500
#define PAPER_BURN_TIMER 150
#define MAXIMUM_BURN_TIMER 90000

/obj/structure/fireplace
	name = "fireplace"
	desc = "A large stone brick fireplace."
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "fireplace"
	density = FALSE
	anchored = TRUE
	pixel_x = -16
	resistance_flags = FIRE_PROOF
	var/lit = FALSE

	var/fuel_added = 0
	var/flame_expiry_timer

/obj/structure/fireplace/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/structure/fireplace/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/fireplace/proc/try_light(obj/item/O, mob/user)
	if(lit)
		to_chat(user, SPAN_WARNING("It's already lit!"))
		return FALSE
	if(!fuel_added)
		to_chat(user, SPAN_WARNING("[src] needs some fuel to burn!"))
		return FALSE
	var/msg = O.ignition_effect(src, user)
	if(msg)
		visible_message(msg)
		ignite()
		return TRUE

/obj/structure/fireplace/attackby(obj/item/T, mob/user)
	if(istype(T, /obj/item/stack/sheet/wood))
		var/space_for_logs = space_for_wood(T, user)
		if(!space_for_logs)
			return
		var/obj/item/stack/sheet/wood/wood = T
		var/logs_used = min(space_for_logs, wood.amount)
		wood.use(logs_used)
		adjust_fuel_timer(LOG_BURN_TIMER * logs_used)
		user.visible_message("<span class='notice'>[user] tosses some \
			wood into [src].</span>", "<span class='notice'>You add \
			some fuel to [src].</span>")
	else if(istype(T, /obj/item/paper_bin))
		var/obj/item/paper_bin/paper_bin = T
		user.visible_message("<span class='notice'>[user] throws [T] into \
			[src].</span>", "<span class='notice'>You add [T] to [src].\
			</span>")
		adjust_fuel_timer(PAPER_BURN_TIMER * paper_bin.total_paper)
		qdel(paper_bin)
	else if(istype(T, /obj/item/paper))
		user.visible_message("<span class='notice'>[user] throws [T] into \
			[src].</span>", "<span class='notice'>You throw [T] into [src].\
			</span>")
		adjust_fuel_timer(PAPER_BURN_TIMER)
		qdel(T)
	else if (istype(T, /obj/item/grown/log))
		var/obj/item/grown/log/log = T
		var/plank_amount = log.get_plank_amount()
		if(!space_for_wood(T, user, plank_amount))
			return
		adjust_fuel_timer(LOG_BURN_TIMER * plank_amount)
		qdel(log)
		user.visible_message("<span class='notice'>[user] tosses a \
			log into [src].</span>", "<span class='notice'>You add \
			a log to [src].</span>")
	else if(try_light(T,user))
		return
	else
		. = ..()

/// Returns 0 if there isn't enough space for wood, or the amount of space worth in planks if there is. Gives user feedback.
/obj/structure/fireplace/proc/space_for_wood(obj/item/item, mob/user, log_amount = 1)
	var/space_remaining = MAXIMUM_BURN_TIMER - burn_time_remaining()
	var/space_for_logs = round(space_remaining / LOG_BURN_TIMER)
	if(space_for_logs < log_amount)
		to_chat(user, SPAN_WARNING("You can't fit any more of [item] in [src]!"))
		return 0
	return space_for_logs

/obj/structure/fireplace/update_overlays()
	. = ..()
	if(!lit)
		return

	switch(burn_time_remaining())
		if(0 to 500)
			. += "fireplace_fire0"
		if(500 to 1000)
			. += "fireplace_fire1"
		if(1000 to 1500)
			. += "fireplace_fire2"
		if(1500 to 2000)
			. += "fireplace_fire3"
		if(2000 to MAXIMUM_BURN_TIMER)
			. += "fireplace_fire4"
	. += "fireplace_glow"

/obj/structure/fireplace/proc/adjust_light()
	if(!lit)
		set_light(0)
		return

	switch(burn_time_remaining())
		if(0 to 500)
			set_light(1)
		if(500 to 1000)
			set_light(2)
		if(1000 to 1500)
			set_light(3)
		if(1500 to 2000)
			set_light(4)
		if(2000 to MAXIMUM_BURN_TIMER)
			set_light(6)

/obj/structure/fireplace/process(delta_time)
	if(!lit)
		return
	if(world.time > flame_expiry_timer)
		put_out()
		return

	var/turf/T = get_turf(src)
	T.hotspot_expose(700, 2.5 * delta_time)
	update_appearance()
	adjust_light()

/obj/structure/fireplace/extinguish()
	if(lit)
		var/fuel = burn_time_remaining()
		flame_expiry_timer = 0
		put_out()
		adjust_fuel_timer(fuel)
	. = ..()

/obj/structure/fireplace/proc/adjust_fuel_timer(amount)
	if(lit)
		flame_expiry_timer += amount
		if(burn_time_remaining() < MAXIMUM_BURN_TIMER)
			flame_expiry_timer = world.time + MAXIMUM_BURN_TIMER
	else
		fuel_added = clamp(fuel_added + amount, 0, MAXIMUM_BURN_TIMER)

/obj/structure/fireplace/proc/burn_time_remaining()
	if(lit)
		return max(0, flame_expiry_timer - world.time)
	else
		return max(0, fuel_added)

/obj/structure/fireplace/proc/ignite()
	lit = TRUE
	set_ambience(AMBIENCE_FIRE)
	desc = "A large stone brick fireplace, warm and cozy."
	flame_expiry_timer = world.time + fuel_added
	fuel_added = 0
	update_appearance()
	adjust_light()

/obj/structure/fireplace/proc/put_out()
	lit = FALSE
	set_ambience(null)
	update_appearance()
	adjust_light()
	desc = initial(desc)
