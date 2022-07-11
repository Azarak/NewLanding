//The contant in the rate of reagent transfer on life ticks
#define STOMACH_METABOLISM_CONSTANT 0.25

/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb_continuous = list("gores", "squishes", "slaps", "digests")
	attack_verb_simple = list("gore", "squish", "slap", "digest")
	desc = "Onaka ga suite imasu."

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 1.15 // ~13 minutes, the stomach is one of the first organs to die

	low_threshold_passed = SPAN_INFO("Your stomach flashes with pain before subsiding. Food doesn't seem like a good idea right now.")
	high_threshold_passed = SPAN_WARNING("Your stomach flares up with constant pain- you can hardly stomach the idea of food right now!")
	high_threshold_cleared = SPAN_INFO("The pain in your stomach dies down for now, but food still seems unappealing.")
	low_threshold_cleared = SPAN_INFO("The last bouts of pain in your stomach have died out.")

	food_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue = 5)
	//This is a reagent user and needs more then the 10u from edible component
	reagent_vol = 1000

	///The rate that disgust decays
	var/disgust_metabolism = 1

	///The rate that the stomach will transfer reagents to the body
	var/metabolism_efficiency = 0.05 // the lowest we should go is 0.05


/obj/item/organ/stomach/Initialize()
	. = ..()
	//None edible organs do not get a reagent holder by default
	if(!reagents)
		create_reagents(reagent_vol, REAGENT_HOLDER_ALIVE)
	else
		reagents.flags |= REAGENT_HOLDER_ALIVE

/obj/item/organ/stomach/on_life(delta_time, times_fired)
	. = ..()

	//Manage species digestion
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/humi = owner
		if(!(organ_flags & ORGAN_FAILING))
			humi.dna.species.handle_digestion(humi, delta_time, times_fired)

	var/mob/living/carbon/body = owner

	// digest food, sent all reagents that can metabolize to the body
	for(var/datum/reagent/bit as anything in reagents.reagent_list)

		// If the reagent does not metabolize then it will sit in the stomach
		// This has an effect on items like plastic causing them to take up space in the stomach
		if(bit.metabolization_rate <= 0)
			continue

		//Ensure that the the minimum is equal to the metabolization_rate of the reagent if it is higher then the STOMACH_METABOLISM_CONSTANT
		var/rate_min = max(bit.metabolization_rate, STOMACH_METABOLISM_CONSTANT)
		//Do not transfer over more then we have
		var/amount_max = bit.volume

		//If the reagent is part of the food reagents for the organ
		//prevent all the reagents form being used leaving the food reagents
		var/amount_food = food_reagents[bit.type]
		if(amount_food)
			amount_max = max(amount_max - amount_food, 0)

		// Transfer the amount of reagents based on volume with a min amount of 1u
		var/amount = min((round(metabolism_efficiency * amount_max, 0.05) + rate_min) * delta_time, amount_max)

		if(amount <= 0)
			continue

		// transfer the reagents over to the body at the rate of the stomach metabolim
		// this way the body is where all reagents that are processed and react
		// the stomach manages how fast they are feed in a drip style
		reagents.trans_id_to(body, bit.type, amount=amount)

	//Handle disgust
	if(body)
		handle_disgust(body, delta_time, times_fired)

	//If the stomach is not damage exit out
	if(damage < low_threshold)
		return

	//We are checking if we have nutriment in a damaged stomach.
	var/datum/reagent/nutri = locate(/datum/reagent/consumable/nutriment) in reagents.reagent_list
	//No nutriment found lets exit out
	if(!nutri)
		return

	// remove the food reagent amount
	var/nutri_vol = nutri.volume
	var/amount_food = food_reagents[nutri.type]
	if(amount_food)
		nutri_vol = max(nutri_vol - amount_food, 0)

	// found nutriment was stomach food reagent
	if(!(nutri_vol > 0))
		return

	//The stomach is damage has nutriment but low on theshhold, lo prob of vomit
	if(DT_PROB(0.0125 * damage * nutri_vol * nutri_vol, delta_time))
		body.vomit(damage)
		to_chat(body, SPAN_WARNING("Your stomach reels in pain as you're incapable of holding down all that food!"))
		return

	// the change of vomit is now high
	if(damage > high_threshold && DT_PROB(0.05 * damage * nutri_vol * nutri_vol, delta_time))
		body.vomit(damage)
		to_chat(body, SPAN_WARNING("Your stomach reels in pain as you're incapable of holding down all that food!"))

/obj/item/organ/stomach/get_availability(datum/species/owner_species)
	return !(NOSTOMACH in owner_species.inherent_traits)

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/disgusted, delta_time, times_fired)
	if(disgusted.disgust)
		var/pukeprob = 2.5 + (0.025 * disgusted.disgust)
		if(disgusted.disgust >= DISGUST_LEVEL_GROSS)
			if(DT_PROB(5, delta_time))
				disgusted.stuttering += 1
				disgusted.add_confusion(2)
			if(DT_PROB(5, delta_time) && !disgusted.stat)
				to_chat(disgusted, SPAN_WARNING("You feel kind of iffy..."))
			disgusted.jitteriness = max(disgusted.jitteriness - 3, 0)
		if(disgusted.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(DT_PROB(pukeprob, delta_time)) //iT hAndLeS mOrE ThaN PukInG
				disgusted.add_confusion(2.5)
				disgusted.stuttering += 1
				disgusted.vomit(10, 0, 1, 0, 1, 0)
			disgusted.Dizzy(5)
		if(disgusted.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(DT_PROB(13, delta_time))
				disgusted.blur_eyes(3) //We need to add more shit down here

		disgusted.adjust_disgust(-0.25 * disgust_metabolism * delta_time)
	switch(disgusted.disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			disgusted.clear_alert("disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			disgusted.throw_alert("disgust", /atom/movable/screen/alert/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			disgusted.throw_alert("disgust", /atom/movable/screen/alert/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			disgusted.throw_alert("disgust", /atom/movable/screen/alert/disgusted)

/obj/item/organ/stomach/Remove(mob/living/carbon/stomach_owner, special = 0)
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.clear_alert("disgust")

	return ..()

#undef STOMACH_METABOLISM_CONSTANT
