/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors/common.dmi'
	icon_state = "water"
	baseturfs = /turf/open/water
	slowdown = 2
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER


/turf/open/water/impassable
	name = "deep water"
	desc = "Deep water."
	density = TRUE
	color = "#aed9f2"
