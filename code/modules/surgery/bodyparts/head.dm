/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "default_human_head"
	max_damage = 200
	body_zone = BODY_ZONE_HEAD
	body_part = HEAD
	w_class = WEIGHT_CLASS_BULKY //Quite a hefty load
	slowdown = 1 //Balancing measure
	throw_range = 2 //No head bowling
	px_x = 0
	px_y = -8
	wound_resistance = 5
	disabled_wound_penalty = 25
	scars_covered_by_clothes = FALSE
	grind_results = null

	var/mob/living/brain/brainmob //The current occupant.
	var/obj/item/organ/brain/brain //The brain organ
	var/obj/item/organ/eyes/eyes
	var/obj/item/organ/ears/ears
	var/obj/item/organ/tongue/tongue

	//Limb appearance info:
	var/real_name = "" //Replacement name

	var/lip_style
	var/lip_color = "white"

	var/stored_lipstick_trait


/obj/item/bodypart/head/Destroy()
	QDEL_NULL(brainmob) //order is sensitive, see warning in handle_atom_del() below
	QDEL_NULL(brain)
	QDEL_NULL(eyes)
	QDEL_NULL(ears)
	QDEL_NULL(tongue)
	return ..()

/obj/item/bodypart/head/handle_atom_del(atom/head_atom)
	if(head_atom == brain)
		brain = null
		update_icon_dropped()
		if(!QDELETED(brainmob)) //this shouldn't happen without badminnery.
			message_admins("Brainmob: ([ADMIN_LOOKUPFLW(brainmob)]) was left stranded in [src] at [ADMIN_VERBOSEJMP(src)] without a brain!")
			log_game("Brainmob: ([key_name(brainmob)]) was left stranded in [src] at [AREACOORD(src)] without a brain!")
	if(head_atom == brainmob)
		brainmob = null
	if(head_atom == eyes)
		eyes = null
		update_icon_dropped()
	if(head_atom == ears)
		ears = null
	if(head_atom == tongue)
		tongue = null
	return ..()

/obj/item/bodypart/head/examine(mob/user)
	. = ..()
	if(status == BODYPART_ORGANIC)
		if(!brain)
			. += SPAN_INFO("The brain has been removed from [src].")
		else if(brain.suicided || brainmob?.suiciding)
			. += SPAN_INFO("There's a miserable expression on [real_name]'s face; they must have really hated life. There's no hope of recovery.")
		else if(brainmob?.health <= HEALTH_THRESHOLD_DEAD)
			. += SPAN_INFO("It's leaking some kind of... clear fluid? The brain inside must be in pretty bad shape.")
		else if(brainmob)
			if(brainmob.key || brainmob.get_ghost(FALSE, TRUE))
				. += SPAN_INFO("Its muscles are twitching slightly... It seems to have some life still in it.")
			else
				. += SPAN_INFO("It's completely lifeless. Perhaps there'll be a chance for them later.")
		else if(brain?.decoy_override)
			. += SPAN_INFO("It's completely lifeless. Perhaps there'll be a chance for them later.")
		else
			. += SPAN_INFO("It's completely lifeless.")

		if(!eyes)
			. += SPAN_INFO("[real_name]'s eyes have been removed.")

		if(!ears)
			. += SPAN_INFO("[real_name]'s ears have been removed.")

		if(!tongue)
			. += SPAN_INFO("[real_name]'s tongue has been removed.")


/obj/item/bodypart/head/can_dismember(obj/item/item)
	if(owner.stat < UNCONSCIOUS)
		return FALSE
	return ..()

/obj/item/bodypart/head/drop_organs(mob/user, violent_removal)
	var/turf/head_turf = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(head_turf, 'sound/misc/splort.ogg', 50, TRUE, -1)
	for(var/obj/item/head_item in src)
		if(head_item == brain)
			if(user)
				user.visible_message(SPAN_WARNING("[user] saws [src] open and pulls out a brain!"), SPAN_NOTICE("You saw [src] open and pull out a brain."))
			if(brainmob)
				brainmob.forceMove(brain)
				brain.brainmob = brainmob
				brainmob = null
			if(violent_removal && prob(rand(80, 100))) //ghetto surgery can damage the brain.
				to_chat(user, SPAN_WARNING("[brain] was damaged in the process!"))
				brain.setOrganDamage(brain.maxHealth)
			brain.forceMove(head_turf)
			brain = null
			update_icon_dropped()
		else
			if(istype(head_item, /obj/item/reagent_containers/pill))
				for(var/datum/action/item_action/hands_free/activate_pill/pill_action in head_item.actions)
					qdel(pill_action)
			head_item.forceMove(head_turf)
	eyes = null
	ears = null
	tongue = null

/obj/item/bodypart/head/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/head_owner
	if(source)
		head_owner = source
	else
		head_owner = owner

	real_name = head_owner.real_name
	if(HAS_TRAIT(head_owner, TRAIT_HUSK))
		real_name = "Unknown"
		lip_style = null
		stored_lipstick_trait = null

	else if(!animal_origin)
		var/mob/living/carbon/human/human_head_owner = head_owner
		var/datum/species/owner_species = human_head_owner.dna.species
		// lipstick
		if(human_head_owner.lip_style && (LIPS in owner_species.species_traits))
			lip_style = human_head_owner.lip_style
			lip_color = human_head_owner.lip_color
		else
			lip_style = null
			lip_color = "white"
	..()

/obj/item/bodypart/head/update_icon_dropped()
	var/list/standing = get_limb_icon(TRUE)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/img in standing)
		img.pixel_x = px_x
		img.pixel_y = px_y
	add_overlay(standing)

/obj/item/bodypart/head/get_limb_icon(dropped)
	cut_overlays()
	. = ..()
	if(dropped) //certain overlays only appear when the limb is being detached from its owner.

		if(status != BODYPART_ROBOTIC) //having a robotic head hides certain features.

			//Applies the debrained overlay if there is no brain
			if(!brain)
				var/image/debrain_overlay = image(layer = -HAIR_LAYER, dir = SOUTH)
				if(animal_origin == ALIEN_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_alien"
				else if(animal_origin == LARVA_BODYPART)
					debrain_overlay.icon = 'icons/mob/animal_parts.dmi'
					debrain_overlay.icon_state = "debrained_larva"
				else if(!(NOBLOOD in species_flags_list))
					debrain_overlay.icon = 'icons/mob/sprite_accessory/human_face.dmi'
					debrain_overlay.icon_state = "debrained"
				. += debrain_overlay


		// lipstick
		if(lip_style)
			var/image/lips_overlay = image('icons/mob/sprite_accessory/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, SOUTH)
			lips_overlay.color = lip_color
			. += lips_overlay

/obj/item/bodypart/head/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_head"
	animal_origin = MONKEY_BODYPART

