/obj/item/gun
	abstract_type = /obj/item/gun
	name = "gun"
	desc = "It's gonna shoot something, alright."
	icon = 'icons/obj/guns/ballistic.dmi'
	icon_state = "detective"
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("strikes", "hits", "bashes")
	attack_verb_simple = list("strike", "hit", "bash")
	/// Projectile type that the gun shoots out.
	var/projectile_type = /obj/projectile/bullet/lead_ball
	/// Delay between shots
	var/shoot_delay = CLICK_CD_RANGE
	var/firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
	/// Sound to play when firing the thing.
	var/fire_sound = 'sound/weapons/gun/pistol/shot.ogg'
	var/vary_fire_sound = TRUE
	var/fire_sound_volume = 50

	var/empty_fire_sound = 'sound/weapons/gun/general/dry_fire.ogg'
	var/empty_vary_fire_sound = TRUE
	var/empty_fire_sound_volume = 20

/obj/item/gun/afterattack(atom/target, mob/living/user, flag, params)
	if(attempt_shoot_at(target, user, flag, params))
		return TRUE
	return ..()

/obj/item/gun/proc/can_fire_gun(mob/living/user)
	return TRUE

/obj/item/gun/proc/can_shoot()
	return TRUE

/obj/item/gun/proc/is_loaded()
	return TRUE

/obj/item/gun/proc/after_projectile_fire()
	return

/obj/item/gun/proc/after_empty_fire()
	return

/obj/item/gun/proc/attempt_shoot_at(atom/movable/target, mob/living/user, flag, params)
	if(!can_fire_gun(user))
		return FALSE
	if(!can_shoot())
		return FALSE
	//It's adjacent, is the user, or is on the user's person
	if(flag)
		//can't shoot stuff inside us.
		if(target in user.contents)
			return FALSE
		//so we can't shoot ourselves (unless mouth selected)
		if(target == user && user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
			return FALSE
	if(is_loaded())
		fire_projectile(target, user, params)
		after_projectile_fire()
	else
		fire_empty(target, user, params)
		after_empty_fire()
	user.changeNext_move(shoot_delay)
	return TRUE

/obj/item/gun/proc/fire_empty(atom/movable/target, mob/living/user, params)
	to_chat(user, SPAN_DANGER("*click*"))
	playsound(user, empty_fire_sound, empty_fire_sound_volume, empty_vary_fire_sound)

/obj/item/gun/proc/fire_projectile(atom/movable/target, mob/living/user, params)
	var/zone_selected = user.zone_selected
	SEND_SIGNAL(user, COMSIG_MOB_FIRED_GUN, src, target, params, zone_selected)
	SEND_SIGNAL(src, COMSIG_GUN_FIRED, user, target, params, zone_selected)
	user.visible_message(SPAN_DANGER("[user] fires [src]!"), \
		SPAN_DANGER("You fire [src]!"), \
		SPAN_HEAR("You hear a gunshot!"), COMBAT_MESSAGE_RANGE)
	playsound(user, fire_sound, fire_sound_volume, vary_fire_sound)
	var/turf/start_loc = get_turf(src)
	var/firing_dir = get_dir(user, target)
	new firing_effect_type(start_loc, firing_dir)
	var/obj/projectile/proj = new projectile_type(start_loc)
	proj.starting = start_loc
	proj.firer = user
	proj.fired_from = src
	proj.yo = target.y - start_loc.y
	proj.xo = target.x - start_loc.x
	proj.original = target
	proj.def_zone = zone_selected
	proj.preparePixelProjectile(target, user)
	proj.fire()
