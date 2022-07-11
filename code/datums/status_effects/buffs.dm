//Largely beneficial effects go here, even if they have drawbacks.

/datum/status_effect/wish_granters_gift //Fully revives after ten seconds.
	id = "wish_granters_gift"
	duration = 50
	alert_type = /atom/movable/screen/alert/status_effect/wish_granters_gift

/datum/status_effect/wish_granters_gift/on_apply()
	to_chat(owner, SPAN_NOTICE("Death is not your end! The Wish Granter's energy suffuses you, and you begin to rise..."))
	return ..()


/datum/status_effect/wish_granters_gift/on_remove()
	owner.revive(full_heal = TRUE, admin_revive = TRUE)
	owner.visible_message(SPAN_WARNING("[owner] appears to wake from the dead, having healed all wounds!"), SPAN_NOTICE("You have regenerated."))


/atom/movable/screen/alert/status_effect/wish_granters_gift
	name = "Wish Granter's Immortality"
	desc = "You are being resurrected!"
	icon_state = "wish_granter"

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blooddrunk

/atom/movable/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, BLOODDRUNK_TRAIT)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.physiology.brute_mod *= 0.1
			H.physiology.burn_mod *= 0.1
			H.physiology.tox_mod *= 0.1
			H.physiology.oxy_mod *= 0.1
			H.physiology.clone_mod *= 0.1
			H.physiology.stamina_mod *= 0.1
		owner.log_message("gained blood-drunk stun immunity", LOG_ATTACK)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1, use_reverb = FALSE)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= 10
		H.physiology.burn_mod *= 10
		H.physiology.tox_mod *= 10
		H.physiology.oxy_mod *= 10
		H.physiology.clone_mod *= 10
		H.physiology.stamina_mod *= 10
	owner.log_message("lost blood-drunk stun immunity", LOG_ATTACK)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, BLOODDRUNK_TRAIT);
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

/datum/status_effect/sword_spin
	id = "Bastard Sword Spin"
	duration = 50
	tick_interval = 8
	alert_type = null


/datum/status_effect/sword_spin/on_apply()
	owner.visible_message(SPAN_DANGER("[owner] begins swinging the sword with inhuman strength!"))
	var/oldcolor = owner.color
	owner.color = "#ff0000"
	owner.add_stun_absorption("bloody bastard sword", duration, 2, "doesn't even flinch as the sword's power courses through them!", "You shrug off the stun!", " glowing with a blazing red aura!")
	owner.spin(duration,1)
	animate(owner, color = oldcolor, time = duration, easing = EASE_IN)
	addtimer(CALLBACK(owner, /atom/proc/update_atom_colour), duration)
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	return ..()


/datum/status_effect/sword_spin/tick()
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	var/obj/item/slashy
	slashy = owner.get_active_held_item()
	for(var/mob/living/M in orange(1,owner))
		slashy.attack(M, owner)

/datum/status_effect/sword_spin/on_remove()
	owner.visible_message(SPAN_WARNING("[owner]'s inhuman strength dissipates and the sword's runes grow cold!"))


//Used by changelings to rapidly heal
//Heals 10 brute and oxygen damage every second, and 5 fire
//Being on fire will suppress this healing
/datum/status_effect/fleshmend
	id = "fleshmend"
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend

/datum/status_effect/fleshmend/tick()
	if(owner.on_fire)
		linked_alert.icon_state = "fleshmend_fire"
		return
	else
		linked_alert.icon_state = "fleshmend"
	owner.adjustBruteLoss(-10, FALSE)
	owner.adjustFireLoss(-5, FALSE)
	owner.adjustOxyLoss(-10)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	QDEL_LIST(C.all_scars)

/atom/movable/screen/alert/status_effect/fleshmend
	name = "Fleshmend"
	desc = "Our wounds are rapidly healing. <i>This effect is prevented if we are on fire.</i>"
	icon_state = "fleshmend"

/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS

/datum/status_effect/good_music
	id = "Good Music"
	alert_type = null
	duration = 6 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/good_music/tick()
	if(owner.can_hear())
		owner.dizziness = max(0, owner.dizziness - 2)
		owner.jitteriness = max(0, owner.jitteriness - 2)
		owner.set_confusion(max(0, owner.get_confusion() - 1))

/datum/status_effect/antimagic
	id = "antimagic"
	duration = 10 SECONDS
	examine_text = SPAN_NOTICE("They seem to be covered in a dull, grey aura.")

/datum/status_effect/antimagic/on_apply()
	owner.visible_message(SPAN_NOTICE("[owner] is coated with a dull aura!"))
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	//glowing wings overlay
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	return ..()

/datum/status_effect/antimagic/on_remove()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	owner.visible_message(SPAN_WARNING("[owner]'s dull aura fades away..."))

/datum/status_effect/crucible_soul
	id = "Blessing of Crucible Soul"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	examine_text = SPAN_NOTICE("They don't seem to be all here.")
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul
	var/turf/location

/datum/status_effect/crucible_soul/on_apply()
	. = ..()
	to_chat(owner,SPAN_NOTICE("You phase through reality, nothing is out of bounds!"))
	owner.alpha = 180
	owner.pass_flags |= PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS
	location = get_turf(owner)

/datum/status_effect/crucible_soul/on_remove()
	to_chat(owner,SPAN_NOTICE("You regain your physicality, returning you to your original location..."))
	owner.alpha = initial(owner.alpha)
	owner.pass_flags &= ~(PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS)
	owner.forceMove(location)
	location = null
	return ..()

/datum/status_effect/duskndawn
	id = "Blessing of Dusk and Dawn"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	alert_type =/atom/movable/screen/alert/status_effect/duskndawn

/datum/status_effect/duskndawn/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, STATUS_EFFECT_TRAIT)
	owner.update_sight()

/datum/status_effect/duskndawn/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, STATUS_EFFECT_TRAIT)
	owner.update_sight()
	return ..()

/datum/status_effect/marshal
	id = "Blessing of Wounded Soldier"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/marshal

/datum/status_effect/marshal/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)

/datum/status_effect/marshal/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, STATUS_EFFECT_TRAIT)

/datum/status_effect/marshal/tick()
	. = ..()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbie = owner

	for(var/BP in carbie.bodyparts)
		var/obj/item/bodypart/part = BP
		for(var/W in part.wounds)
			var/datum/wound/wound = W
			var/heal_amt = 0

			switch(wound.severity)
				if(WOUND_SEVERITY_MODERATE)
					heal_amt = 1
				if(WOUND_SEVERITY_SEVERE)
					heal_amt = 3
				if(WOUND_SEVERITY_CRITICAL)
					heal_amt = 6
			if(wound.wound_type == WOUND_BURN)
				carbie.adjustFireLoss(-heal_amt)
			else
				carbie.adjustBruteLoss(-heal_amt)
				carbie.blood_volume += carbie.blood_volume >= BLOOD_VOLUME_NORMAL ? 0 : heal_amt*3


/atom/movable/screen/alert/status_effect/crucible_soul
	name = "Blessing of Crucible Soul"
	desc = "You phased through the reality, you are halfway to your final destination..."
	icon_state = "crucible"

/atom/movable/screen/alert/status_effect/duskndawn
	name = "Blessing of Dusk and Dawn"
	desc = "Many things hide beyond the horizon, with Owl's help i managed to slip past sun's guard and moon's watch."
	icon_state = "duskndawn"

/atom/movable/screen/alert/status_effect/marshal
	name = "Blessing of Wounded Soldier"
	desc = "Some people seek power through redemption, one thing many people don't know is that battle is the ultimate redemption and wounds let you bask in eternal glory."
	icon_state = "wounded_soldier"

/datum/status_effect/lightningorb
	id = "Lightning Orb"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/lightningorb

/datum/status_effect/lightningorb/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/yellow_orb)
	to_chat(owner, SPAN_NOTICE("You feel fast!"))

/datum/status_effect/lightningorb/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/yellow_orb)
	to_chat(owner, SPAN_NOTICE("You slow down."))

/atom/movable/screen/alert/status_effect/lightningorb
	name = "Lightning Orb"
	desc = "The speed surges through you!"
	icon_state = "lightningorb"

/datum/status_effect/speed_boost
	id = "speed_boost"
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/speed_boost/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/datum/status_effect/speed_boost/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_speed_boost, update = TRUE)
	return ..()

/datum/status_effect/speed_boost/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_speed_boost, update = TRUE)

/datum/movespeed_modifier/status_speed_boost
	multiplicative_slowdown = -1

