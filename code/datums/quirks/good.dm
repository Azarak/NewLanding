//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 4
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = SPAN_NOTICE("You feel like you could drink a whole keg!")
	lose_text = SPAN_DANGER("You don't feel as resistant to alcohol anymore. Somehow.")
	medical_record_text = "Patient demonstrates a high tolerance for alcohol."

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	value = 8
	mob_trait = TRAIT_DRUNK_HEALING
	gain_text = SPAN_NOTICE("You feel like a drink would do you good.")
	lose_text = SPAN_DANGER("You no longer feel like drinking would ease your pain.")
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."
	processing_quirk = TRUE

/datum/quirk/drunkhealing/process(delta_time)
	var/mob/living/carbon/carbon_holder = quirk_holder
	switch(carbon_holder.drunkenness)
		if (6 to 40)
			carbon_holder.adjustBruteLoss(-0.1*delta_time, FALSE)
			carbon_holder.adjustFireLoss(-0.05*delta_time, FALSE)
		if (41 to 60)
			carbon_holder.adjustBruteLoss(-0.4*delta_time, FALSE)
			carbon_holder.adjustFireLoss(-0.2*delta_time, FALSE)
		if (61 to INFINITY)
			carbon_holder.adjustBruteLoss(-0.8*delta_time, FALSE)
			carbon_holder.adjustFireLoss(-0.4*delta_time, FALSE)

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	value = 8
	mob_trait = TRAIT_EMPATH
	gain_text = SPAN_NOTICE("You feel in tune with those around you.")
	lose_text = SPAN_DANGER("You feel isolated from others.")
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly and take no damage from short falls."
	value = 8
	mob_trait = TRAIT_FREERUNNING
	gain_text = SPAN_NOTICE("You feel lithe on your feet!")
	lose_text = SPAN_DANGER("You feel clumsy again.")
	medical_record_text = "Patient scored highly on cardio tests."

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; footsteps and stepping on sharp objects is quieter and less painful. Also, your hands and clothes will not get messed in case of stepping in blood."
	value = 4
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = SPAN_NOTICE("You walk with a little more litheness.")
	lose_text = SPAN_DANGER("You start tromping around like a barbarian.")
	medical_record_text = "Patient's dexterity belies a strong capacity for stealth."

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	value = 4
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = SPAN_NOTICE("The shadows seem a little less dark.")
	lose_text = SPAN_DANGER("Everything seems a little darker.")
	medical_record_text = "Patient's eyes show above-average acclimation to darkness."

/datum/quirk/night_vision/add()
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/remove()
	refresh_quirk_holder_eyes()

/datum/quirk/night_vision/proc/refresh_quirk_holder_eyes()
	var/mob/living/carbon/human/human_quirk_holder = quirk_holder
	var/obj/item/organ/eyes/eyes = human_quirk_holder.getorgan(/obj/item/organ/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	// We've either added or removed TRAIT_NIGHT_VISION before calling this proc. Just refresh the eyes.
	eyes.refresh()

/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	value = 8
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Patient demonstrates an uncanny knack for self-diagnosis."

/datum/quirk/skittish
	name = "Skittish"
	desc = "You're easy to startle, and hide frequently. Run into a closed locker to jump into it, as long as you have access. You can walk to avoid this."
	value = 8
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."

/datum/quirk/item_quirk/tagger
	name = "Tagger"
	desc = "You're an experienced artist. People will actually be impressed by your graffiti, and you can get twice as many uses out of drawing supplies."
	value = 4
	mob_trait = TRAIT_TAGGER
	gain_text = SPAN_NOTICE("You know how to tag walls efficiently.")
	lose_text = SPAN_DANGER("You forget how to tag walls properly.")
	medical_record_text = "Patient was recently seen for possible paint huffing incident."

/datum/quirk/item_quirk/tagger/add_unique()
	give_item_to_holder(/obj/item/toy/crayon/spraycan, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	value = 4
	mob_trait = TRAIT_VORACIOUS
	gain_text = SPAN_NOTICE("You feel HONGRY.")
	lose_text = SPAN_DANGER("You no longer feel HONGRY.")
