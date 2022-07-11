/mob/living/carbon/getStaminaLoss()
	return staminaloss

/mob/living/carbon/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	staminaloss = clamp(staminaloss + amount, 0, MAX_STAMINA)
	update_stamina_hud()
	return amount

/mob/living/carbon/setStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	var/current = getStaminaLoss()
	var/diff = amount - current
	if(!diff)
		return
	adjustStaminaLoss(diff, updating_health, forced)

/mob/living/carbon/update_stamina()
	return

/mob/living/carbon/use_stamina(amount = 0, threshold = 0)
	// If we go below the threshold when we spent the amount, return FALSE
	if(MAX_STAMINA - staminaloss - amount < threshold)
		return FALSE
	// Else, spend the stamina and return TRUE
	adjustStaminaLoss(amount)
	return TRUE

/// Handles stamina regeneration, is called in life
/mob/living/carbon/proc/handle_stamina(delta_time)
	if(staminaloss <= 0)
		return
	adjustStaminaLoss(-STAMINA_REGEN_PER_SECOND * delta_time)

/// Handles updating the stamina hud for carbons
/mob/living/carbon/proc/update_stamina_hud()
	if(!client || !hud_used)
		return
	if(!hud_used.stamina)
		return
	hud_used.stamina.cut_overlays()
	if(stat != DEAD)
		var/hud_suffix = clamp(CEILING(staminaloss * 0.1, 1), 0, 10)
		hud_used.stamina.icon_state = "stamina[hud_suffix]"
		switch(hud_suffix)
			if(5 to 6)
				hud_used.stamina.add_overlay("stamina_alert1")
			if(7 to 10)
				hud_used.stamina.add_overlay("stamina_alert2")
	else
		hud_used.stamina.icon_state = "stamina10"
