/mob/living/carbon/proc/update_shock()
	var/target_stat = SHOCK_NONE
	if (health <= hardcrit_threshold)
		target_stat = SHOCK_SEVERE
	else if(health <= crit_threshold)
		target_stat = SHOCK_MILD
	set_shock_stat(target_stat)

/mob/living/carbon/proc/set_shock_stat(new_shock_stat)
	if(new_shock_stat == shock_stat)
		return
	// Undo previous effects if any
	switch(shock_stat)
		if(SHOCK_MILD)
			REMOVE_TRAIT(src, TRAIT_INCAPACITATED, SHOCK_CONDITION)
			REMOVE_TRAIT(src, TRAIT_FLOORED, SHOCK_CONDITION)
		if(SHOCK_SEVERE)
			REMOVE_TRAIT(src, TRAIT_INCAPACITATED, SHOCK_CONDITION)
			REMOVE_TRAIT(src, TRAIT_FLOORED, SHOCK_CONDITION)
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SHOCK_CONDITION)
			REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, SHOCK_CONDITION)

	shock_stat = new_shock_stat
	// Apply new effects
	switch(shock_stat)
		if(SHOCK_MILD)
			ADD_TRAIT(src, TRAIT_INCAPACITATED, SHOCK_CONDITION)
			ADD_TRAIT(src, TRAIT_FLOORED, SHOCK_CONDITION)
		if(SHOCK_SEVERE)
			ADD_TRAIT(src, TRAIT_INCAPACITATED, SHOCK_CONDITION)
			ADD_TRAIT(src, TRAIT_FLOORED, SHOCK_CONDITION)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, SHOCK_CONDITION)
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, SHOCK_CONDITION)

	update_deathly_grab_weakness()
