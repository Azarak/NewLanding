/// Gets a "bar" of pain, which is the amount `handle_pain` tries to equalize towards. This is limbs tissue damage and toxin damage
/mob/living/carbon/proc/get_pain_bar()
	var/pain_bar = 0
	for(var/obj/item/bodypart/part as anything in bodyparts)
		pain_bar += part.get_damage() * part.body_damage_coeff
	// Toxins also count into pain, but they dont deal pain immediately when inflicted
	pain_bar += toxloss
	return pain_bar

/// Adjusts pain loss and updates states based on it, also makes the carbon do an emote if the pain is sufficient.
/mob/living/carbon/adjustPainLoss(pain_amt)
	pain = clamp(pain + pain_amt, 0, PAIN_MAXIMUM)
	update_pain_states()
	update_health_hud()

	// Handle pain groans //50 pain amount is 100% for a response, so around 25 damage in a hit
	if(stat != DEAD && next_pain_groan < world.time && pain_amt > PAIN_SCREAM_TRIGGER_THRESHOLD && pain >= PAIN_SCREAM_THRESHOLD && prob(pain_amt * PAIN_SCREAM_TRIGGER_MULTIPLIER))
		next_pain_groan = world.time + 6 SECONDS
		var/scream_chance = pain * 0.2
		var/emote_to_use
		if(prob(scream_chance))
			emote_to_use = "scream"
		else
			emote_to_use = "pain"
		INVOKE_ASYNC(src, .proc/emote, emote_to_use)

/// Runs each life, moves pain towards the "bar" and updates pain states.
/mob/living/carbon/proc/handle_pain(delta_time)
	var/pain_bar = get_pain_bar()
	// If there is pain, pain bar and pain isn't equal to pain bar, we move the pain towards the pain bar
	if((pain || pain_bar) && pain != pain_bar)
		var/bar_difference = pain - pain_bar
		var/abs_difference = abs(bar_difference)
		var/recovery_amount = ((abs_difference * PAIN_RECOVERY_PERCENT) + PAIN_RECOVERY_FLAT) * delta_time
		if(recovery_amount > abs_difference)
			recovery_amount = abs_difference
		if(bar_difference < 0)
			recovery_amount = -recovery_amount
		adjustPainLoss(-recovery_amount)
		return //adjusting pain updates pain states
	update_pain_states()

/// Gets a string description with a span on how painfully the carbon is feeling.
/mob/living/carbon/proc/get_pain_string()
	switch(pain)
		if(0 to 75)
			return SPAN_WARNING("You feel mild pain.")
		if(75 to 125)
			return SPAN_WARNING("You feel pain!")
		if(125 to 175)
			return SPAN_WARNING("You feel great pain!")
		if(175 to 225)
			return SPAN_BOLDWARNING("You feel terrible pain!")
		if(225 to PAIN_MAXIMUM)
			return SPAN_BOLDWARNING("You feel agonizing pain!")

/// Updates pain crit states.
/mob/living/carbon/proc/update_pain_states()
	// Handle pain messages
	if(stat != DEAD && pain > PAIN_MESSAGE_THRESHOLD && next_pain_message < world.time)
		next_pain_message = world.time + 30 SECONDS
		to_chat(src, get_pain_string())

	// Update pain slowdown
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
	else if(pain >= PAIN_SLOWDOWN_THRESHOLD)
		var/pain_slowdown = pain / PAIN_SLOWDOWN_DIVISOR
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, TRUE, multiplicative_slowdown = pain_slowdown)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying, TRUE, multiplicative_slowdown = pain_slowdown)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)

	// Handle paincrit. Paincrit starts from 220 but persists until you get it back below 200.
	var/new_pain_crit_state = 0
	var/paincrit_persists = TRUE
	switch(pain)
		if(0 to 200)
			paincrit_persists = FALSE
			new_pain_crit_state = PAIN_STAT_NONE
		if(200 to 220)
			new_pain_crit_state = PAIN_STAT_NONE
		if(220 to 240)
			new_pain_crit_state = PAIN_STAT_CRAWLING
		if(240 to 260)
			new_pain_crit_state = PAIN_STAT_INCAPACITATED
		if(260 to PAIN_MAXIMUM)
			new_pain_crit_state = PAIN_STAT_UNCONSCIOUS

	if(pain_stat && !new_pain_crit_state && paincrit_persists)
		new_pain_crit_state = PAIN_STAT_CRAWLING

	// If the state is new
	if(new_pain_crit_state != pain_stat)
		if(stat != DEAD && !pain_stat)
			to_chat(src, SPAN_BOLDWARNING("Pain overtakes you!"))
		// Undo effects of the previous state
		switch(pain_stat)
			if(PAIN_STAT_CRAWLING)
				//Incapacitated, floored
				REMOVE_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				REMOVE_TRAIT(src, TRAIT_FLOORED, PAIN)
			if(PAIN_STAT_INCAPACITATED)
				//Incapacitated, floored, immobilized
				REMOVE_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				REMOVE_TRAIT(src, TRAIT_FLOORED, PAIN)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
			if(PAIN_STAT_UNCONSCIOUS)
				// Unconscious + the rest
				REMOVE_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				REMOVE_TRAIT(src, TRAIT_FLOORED, PAIN)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
				REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, PAIN)
		// Apply effects of the new state
		pain_stat = new_pain_crit_state
		switch(pain_stat)
			if(PAIN_STAT_CRAWLING)
				//Incapacitated, floored
				ADD_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				ADD_TRAIT(src, TRAIT_FLOORED, PAIN)
			if(PAIN_STAT_INCAPACITATED)
				//Incapacitated, floored, immobilized
				ADD_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				ADD_TRAIT(src, TRAIT_FLOORED, PAIN)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
			if(PAIN_STAT_UNCONSCIOUS)
				// Unconscious + the rest
				ADD_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				ADD_TRAIT(src, TRAIT_FLOORED, PAIN)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
				ADD_TRAIT(src, TRAIT_KNOCKEDOUT, PAIN)

		update_deathly_grab_weakness()
