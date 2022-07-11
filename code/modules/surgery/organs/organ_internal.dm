/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	var/zone = BODY_ZONE_CHEST
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/organ_flags = ORGAN_EDIBLE
	var/maxHealth = STANDARD_ORGAN_THRESHOLD
	var/damage = 0 //total damage this organ has sustained
	///Healing factor and decay factor function on % of maxhealth, and do not work by applying a static number per tick
	var/healing_factor = 0 //fraction of maxhealth healed per on_life(), set to 0 for generic organs
	var/decay_factor = 0 //same as above but when without a living owner, set to 0 for generic organs
	var/high_threshold = STANDARD_ORGAN_THRESHOLD * 0.45 //when severe organ damage occurs
	var/low_threshold = STANDARD_ORGAN_THRESHOLD * 0.1 //when minor organ damage occurs
	var/severe_cooldown //cooldown for severe effects, used for synthetic organ emp effects.
	///Organ variables for determining what we alert the owner with when they pass/clear the damage thresholds
	var/prev_damage = 0
	var/low_threshold_passed
	var/high_threshold_passed
	var/now_failing
	var/now_fixed
	var/high_threshold_cleared
	var/low_threshold_cleared

	///When you take a bite you cant jam it in for surgery anymore.
	var/useable = TRUE
	var/list/food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	///The size of the reagent container
	var/reagent_vol = 10

	var/failure_time = 0

	/// Whether the organ is fully internal and should not be seen by bare eyes.
	var/visible_organ = FALSE
	/// Description when the organ is visible and examined while it's attached to a bodypart.
	var/bodypart_desc = "This is an organ."
	/// Icon of the organ when it's on a bodypart.
	var/bodypart_icon
	/// Icon state of the organ when it's on a bodypart.
	var/bodypart_icon_state
	/// Layer of the overlay this organs renders for being on limbs.
	var/bodypart_layer = BODY_LAYER
	/// Instead of creating an overlay from above variables we can use a sprite accessory.
	var/accessory_type
	/// Color list string for complex overlay generation through sprite accessory.
	var/accessory_colors
	/// Whether the bodypart organ overlay is an emissive blocker
	var/bodypart_emissive_blocker = TRUE
	/// Type of organ DNA that this organ will create.
	var/organ_dna_type = /datum/organ_dna
	/// Whether the organ will run its `randomize_appearance()` proc on Initialization.
	var/randomize_appearance = TRUE

/obj/item/organ/Initialize()
	. = ..()
	if(accessory_type)
		set_accessory_type(accessory_type)
	if(randomize_appearance)
		randomize_appearance()
		update_appearance()
	if(organ_flags & ORGAN_EDIBLE)
		AddComponent(/datum/component/edible,\
			initial_reagents = food_reagents,\
			foodtypes = RAW | MEAT | GROSS,\
			volume = reagent_vol,\
			after_eat = CALLBACK(src, .proc/OnEatFrom))
/*
 * Insert the organ into the select mob.
 *
 * reciever - the mob who will get our organ
 * special - "quick swapping" an organ out - when TRUE, the mob will be unaffected by not having that organ for the moment
 * drop_if_replaced - if there's an organ in the slot already, whether we drop it afterwards
 */
/obj/item/organ/proc/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	if(!iscarbon(reciever) || owner == reciever)
		return

	var/obj/item/organ/replaced = reciever.getorganslot(slot)
	if(replaced)
		replaced.Remove(reciever, special = TRUE)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(reciever))
		else
			qdel(replaced)

	SEND_SIGNAL(reciever, COMSIG_CARBON_GAIN_ORGAN, src, special)

	owner = reciever
	reciever.internal_organs |= src
	reciever.internal_organs_slot[slot] = src
	moveToNullspace()
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/on_owner_examine)
	for(var/datum/action/action as anything in actions)
		action.Grant(reciever)
	update_accessory_colors()
	STOP_PROCESSING(SSobj, src)

/*
 * Remove the organ from the select mob.
 *
 * organ_owner - the mob who owns our organ, that we're removing the organ from.
 * special - "quick swapping" an organ out - when TRUE, the mob will be unaffected by not having that organ for the moment
 */
/obj/item/organ/proc/Remove(mob/living/carbon/organ_owner, special = FALSE)

	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)

	owner = null
	if(organ_owner)
		organ_owner.internal_organs -= src
		if(organ_owner.internal_organs_slot[slot] == src)
			organ_owner.internal_organs_slot.Remove(slot)
		if((organ_flags & ORGAN_VITAL) && !special && !(organ_owner.status_flags & GODMODE))
			organ_owner.death()
	for(var/datum/action/action as anything in actions)
		action.Remove(organ_owner)

	SEND_SIGNAL(organ_owner, COMSIG_CARBON_LOSE_ORGAN, src, special)

	START_PROCESSING(SSobj, src)


/obj/item/organ/proc/on_owner_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	return

/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/process(delta_time, times_fired)
	on_death(delta_time, times_fired) //Kinda hate doing it like this, but I really don't want to call process directly.

/obj/item/organ/proc/on_death(delta_time, times_fired) //runs decay when outside of a person
	if(organ_flags & (ORGAN_SYNTHETIC | ORGAN_FROZEN))
		return
	applyOrganDamage(decay_factor * maxHealth * delta_time)

/obj/item/organ/proc/on_life(delta_time, times_fired) //repair organ damage if the organ is not failing
	if(organ_flags & ORGAN_FAILING)
		handle_failing_organs(delta_time)
		return

	if(failure_time > 0)
		failure_time--

	if(organ_flags & ORGAN_SYNTHETIC_EMP) //Synthetic organ has been emped, is now failing.
		applyOrganDamage(decay_factor * maxHealth * delta_time)
		return
	///Damage decrements by a percent of its maxhealth
	var/healing_amount = healing_factor
	///Damage decrements again by a percent of its maxhealth, up to a total of 4 extra times depending on the owner's health
	healing_amount += (owner.satiety > 0) ? (4 * healing_factor * owner.satiety / MAX_SATIETY) : 0
	applyOrganDamage(-healing_amount * maxHealth * delta_time, damage) // pass curent damage incase we are over cap

/obj/item/organ/examine(mob/user)
	. = ..()

	. += SPAN_NOTICE("It should be inserted in the [parse_zone(zone)].")

	if(organ_flags & ORGAN_FAILING)
		if(status == ORGAN_ROBOTIC)
			. += SPAN_WARNING("[src] seems to be broken.")
			return
		. += SPAN_WARNING("[src] has decayed for too long, and has turned a sickly color. It probably won't work without repairs.")
		return

	if(damage > high_threshold)
		. += SPAN_WARNING("[src] is starting to look discolored.")

/obj/item/organ/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/Destroy()
	if(owner)
		// The special flag is important, because otherwise mobs can die
		// while undergoing transformation into different mobs.
		Remove(owner, special=TRUE)
	else
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/organ/proc/OnEatFrom(eater, feeder)
	useable = FALSE //You can't use it anymore after eating it you spaztic

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

///Adjusts an organ's damage by the amount "damage_amount", up to a maximum amount, which is by default max damage
/obj/item/organ/proc/applyOrganDamage(damage_amount, maximum = maxHealth) //use for damaging effects
	if(!damage_amount) //Micro-optimization.
		return
	if(maximum < damage)
		return
	damage = clamp(damage + damage_amount, 0, maximum)
	var/mess = check_damage_thresholds(owner)
	prev_damage = damage
	if(mess && owner && owner.stat == CONSCIOUS)
		to_chat(owner, mess)

///SETS an organ's damage to the amount "damage_amount", and in doing so clears or sets the failing flag, good for when you have an effect that should fix an organ if broken
/obj/item/organ/proc/setOrganDamage(damage_amount) //use mostly for admin heals
	applyOrganDamage(damage_amount - damage)

/** check_damage_thresholds
 * input: mob/organ_owner (a mob, the owner of the organ we call the proc on)
 * output: returns a message should get displayed.
 * description: By checking our current damage against our previous damage, we can decide whether we've passed an organ threshold.
 *  If we have, send the corresponding threshold message to the owner, if such a message exists.
 */
/obj/item/organ/proc/check_damage_thresholds(mob/organ_owner)
	if(damage == prev_damage)
		return
	var/delta = damage - prev_damage
	if(delta > 0)
		if(damage >= maxHealth)
			organ_flags |= ORGAN_FAILING
			return now_failing
		if(damage > high_threshold && prev_damage <= high_threshold)
			return high_threshold_passed
		if(damage > low_threshold && prev_damage <= low_threshold)
			return low_threshold_passed
	else
		organ_flags &= ~ORGAN_FAILING
		if(prev_damage > low_threshold && damage <= low_threshold)
			return low_threshold_cleared
		if(prev_damage > high_threshold && damage <= high_threshold)
			return high_threshold_cleared
		if(prev_damage == maxHealth)
			return now_fixed

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/mob/living/proc/regenerate_organs()
	return FALSE

/mob/living/carbon/regenerate_organs()
	if(dna?.species)
		dna.species.regenerate_organs(src)
		return

	else
		var/obj/item/organ/lungs/lungs = getorganslot(ORGAN_SLOT_LUNGS)
		if(!lungs)
			lungs = new()
			lungs.Insert(src)
		lungs.setOrganDamage(0)

		var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
		if(!heart)
			heart = new()
			heart.Insert(src)
		heart.setOrganDamage(0)

		var/obj/item/organ/tongue/tongue = getorganslot(ORGAN_SLOT_TONGUE)
		if(!tongue)
			tongue = new()
			tongue.Insert(src)
		tongue.setOrganDamage(0)

		var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
		if(!eyes)
			eyes = new()
			eyes.Insert(src)
		eyes.setOrganDamage(0)

		var/obj/item/organ/ears/ears = getorganslot(ORGAN_SLOT_EARS)
		if(!ears)
			ears = new()
			ears.Insert(src)
		ears.setOrganDamage(0)

///Organs don't die instantly, and neither should you when you get fucked up
/obj/item/organ/proc/handle_failing_organs(delta_time)
	if(owner.stat == DEAD)
		return

	failure_time += delta_time
	organ_failure(delta_time)

/** organ_failure
 * generic proc for handling dying organs
 *
 * Arguments:
 * delta_time - seconds since last tick
 */
/obj/item/organ/proc/organ_failure(delta_time)
	return

/** get_availability
 * returns whether the species should innately have this organ.
 *
 * regenerate organs works with generic organs, so we need to get whether it can accept certain organs just by what this returns.
 * This is set to return true or false, depending on if a species has a specific organless trait. stomach for example checks if the species has NOSTOMACH and return based on that.
 * Arguments:
 * owner_species - species, needed to return whether the species has an organ specific trait
 */
/obj/item/organ/proc/get_availability(datum/species/owner_species)
	return TRUE

/// Gets organ description for when its attached to a bodypart.
/obj/item/organ/proc/get_bodypart_desc()
	return bodypart_desc

/// Whether the organ is visible and should appear on a bodypart.
/obj/item/organ/proc/is_visible()
	/// It's an internal organ, always hidden.
	if(!visible_organ)
		return FALSE
	/// Doesn't have an owner so it couldn't be covered by anything.
	if(!owner)
		return TRUE
	if(!is_visible_on_owner())
		return FALSE
	return TRUE

/obj/item/organ/proc/is_visible_on_owner()
	return TRUE

/// Gets the organ overlay.
/obj/item/organ/proc/get_bodypart_overlay(obj/item/bodypart/bodypart)
	if(!bodypart_icon && !accessory_type)
		return

	if(accessory_type)
		var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
		var/list/appearances = accessory.get_appearance(src, bodypart)
		if(!appearances)
			return
		for(var/standing in appearances)
			bodypart_icon(standing)
			bodypart_overlays(standing)
		return appearances
	else
		var/mutable_appearance/organ_overlay = mutable_appearance(bodypart_icon, bodypart_icon_state, layer = -bodypart_layer)
		organ_overlay.color = color
		bodypart_icon(organ_overlay)

		if(bodypart_emissive_blocker)
			organ_overlay.overlays += emissive_blocker(bodypart_icon, bodypart_icon_state)

		bodypart_overlays(organ_overlay)
		return organ_overlay

/// Proc to customize the base icon of the organ.
/obj/item/organ/proc/bodypart_icon(mutable_appearance/standing)
	return

/// This proc can add overlays to the organ image that is to be attached to a bodypart.
/obj/item/organ/proc/bodypart_overlays(mutable_appearance/standing)
	return

/// Sets an accessory type and optionally colors too.
/obj/item/organ/proc/set_accessory_type(new_accessory_type, colors)
	accessory_type = new_accessory_type
	if(!isnull(colors))
		accessory_colors = colors
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
	accessory.validate_organ_color_keys(src)
	update_accessory_colors()

/obj/item/organ/proc/build_colors_for_accessory(list/source_key_list)
	if(!accessory_type)
		return
	if(!source_key_list)
		if(!owner)
			return
		source_key_list = color_key_source_list_from_dna(owner.dna)
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
	accessory_colors = accessory.get_default_colors(source_key_list)
	accessory.validate_organ_color_keys(src)
	update_accessory_colors()

/// Creates, imprints and returns an organ DNA datum.
/obj/item/organ/proc/create_organ_dna()
	var/datum/organ_dna/organ_dna = new organ_dna_type()
	imprint_organ_dna(organ_dna)
	return organ_dna

/// Imprints an organ DNA datum.
/obj/item/organ/proc/imprint_organ_dna(datum/organ_dna/organ_dna)
	organ_dna.organ_type = type
	if(accessory_type)
		organ_dna.accessory_type = accessory_type
		organ_dna.accessory_colors = accessory_colors

/obj/item/organ/proc/update_accessory_colors()
	return

/obj/item/organ/proc/randomize_appearance()
	return
