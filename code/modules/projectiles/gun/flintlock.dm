/obj/item/gun/flintlock
	abstract_type = /obj/item/gun/flintlock
	icon = 'icons/obj/items/flintlock.dmi'
	var/powder_loaded = FALSE
	var/ball_loaded = FALSE
	var/rammed = FALSE
	var/spawn_loaded = FALSE

/obj/item/gun/flintlock/Initialize()
	. = ..()
	if(spawn_loaded)
		spawn_load()

/obj/item/gun/flintlock/examine(mob/user)
	. = ..()
	if(powder_loaded)
		. += SPAN_NOTICE("There seems to be gunpowder loaded inside.")
	if(ball_loaded)
		. += SPAN_NOTICE("There's a lead ball in the barrel.")
	if(rammed)
		. += SPAN_NOTICE("The contents of the barrel are rammed tight to the end.")

/obj/item/gun/flintlock/after_projectile_fire()
	powder_loaded = FALSE
	ball_loaded = FALSE
	rammed = FALSE

/obj/item/gun/flintlock/is_loaded()
	if(!is_flintlock_loaded())
		return FALSE
	return ..()

#define GUNPOWDER_AMT_TO_LOAD 5

/obj/item/gun/flintlock/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = item
		if(powder_loaded)
			to_chat(user, SPAN_WARNING("There's already gunpowder loaded!"))
			return TRUE
		if(!container.is_open_container())
			to_chat(user, SPAN_WARNING("\The [container] is not open!"))
			return TRUE
		if(!container.reagents.has_reagent(/datum/reagent/gunpowder, GUNPOWDER_AMT_TO_LOAD))
			to_chat(user, SPAN_WARNING("\The [container] has no gunpowder!"))
			return TRUE
		to_chat(user, SPAN_NOTICE("You load some gunpowder from \the [container] into the barrel of \the [src]."))
		container.reagents.remove_reagent(/datum/reagent/gunpowder, GUNPOWDER_AMT_TO_LOAD)
		powder_loaded = TRUE
		return TRUE
	else if(istype(item, /obj/item/stack/lead_ball))
		var/obj/item/stack/lead_ball/ball = item
		if(ball_loaded)
			to_chat(user, SPAN_WARNING("There's already a lead ball loaded!"))
			return TRUE
		if(!powder_loaded)
			to_chat(user, SPAN_WARNING("First load some gunpowder into the barrel!"))
			return TRUE
		to_chat(user, SPAN_NOTICE("You insert a lead ball into the barrel of \the [src]."))
		playsound(src, 'sound/weapons/gun/shotgun/insert_shell.ogg', 50)
		ball.use(1)
		ball_loaded = TRUE
		return TRUE
	else if(istype(item, /obj/item/ramrod))
		var/obj/item/ramrod/rod = item
		if(!rod_checks(rod, user))
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] begins to ram the contents of \the [src]'s barrel down with a ramrod."),
			SPAN_NOTICE("You begin to ram the contents of \the [src]'s barrel down with a ramrod.")
			)
		if(do_after(user, 5 SECONDS, target = src))
			if(!rod_checks(rod, user))
				return TRUE
			to_chat(user, SPAN_NOTICE("You tightly ram the contents of \the [src]'s barrel down, making it ready to fire."))
			rammed = TRUE
		return TRUE
	return ..()

/obj/item/gun/flintlock/proc/rod_checks(obj/item/ramrod/rod, mob/user)
	if(rammed)
		to_chat(user, SPAN_WARNING("The contents are already rammed down!"))
		return FALSE
	if(!powder_loaded)
		to_chat(user, SPAN_WARNING("First load some gunpowder!"))
		return FALSE
	if(!ball_loaded)
		to_chat(user, SPAN_WARNING("First load a lead ball!"))
		return FALSE
	return TRUE

#undef GUNPOWDER_AMT_TO_LOAD

/obj/item/gun/flintlock/proc/spawn_load()
	powder_loaded = TRUE
	ball_loaded = TRUE
	rammed = TRUE

/obj/item/gun/flintlock/proc/is_flintlock_loaded()
	return (powder_loaded && ball_loaded && rammed)

/obj/item/gun/flintlock/pistol
	name = "pistol"
	desc = "A compact pistol with a flintlock firing mechanism."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT

/obj/item/gun/flintlock/musket
	name = "musket"
	desc = "A bulky musket with a flintlock firing mechanism."
	icon_state = "musket"
	inhand_icon_state = "musket"
	worn_icon_state = "musket"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

/obj/item/gun/flintlock/musket/regal
	name = "regal musket"
	icon_state = "musket_prime"
	inhand_icon_state = "musket_prime"
	worn_icon_state = "musket_prime"
