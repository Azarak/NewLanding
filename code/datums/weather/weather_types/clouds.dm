/datum/weather/clouds
	name = "clouds"
	desc = "A couple happy clouds."

	telegraph_message = SPAN_NOTICE("Clouds appear over your, blocking the sun..")
	telegraph_skyblock = 0.3

	weather_message = SPAN_NOTICE("The clouds thicken...")
	weather_skyblock = 0.5

	end_message = SPAN_NOTICE("The clouds disperse...")
	end_skyblock = 0.3

	area_type = /area
	protect_indoors = TRUE
	barometer_predictable = TRUE
	affects_underground = FALSE
	aesthetic = TRUE
