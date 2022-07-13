/datum/weather/fog
	name = "fog"
	desc = "Thick fog."

	telegraph_message = SPAN_NOTICE("It becomes harder to see as a fog starts to form..")
	telegraph_skyblock = 0.3
	telegraph_overlay = "fog_weak"

	weather_message = SPAN_NOTICE("The fog thickens..")
	weather_overlay = "fog"
	weather_skyblock = 0.5

	end_message = SPAN_NOTICE("The fog disperses...")
	end_skyblock = 0.3
	end_overlay = "fog_weak"

	area_type = /area
	protect_indoors = TRUE
	barometer_predictable = TRUE
	affects_underground = FALSE
	aesthetic = TRUE
