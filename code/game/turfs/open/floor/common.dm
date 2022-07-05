/turf/open/floor/grass
	name = "grass"
	desc = "A patch of grass."
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_FLOOR_GRASS)
	layer = HIGH_TURF_LAYER
	var/smooth_icon = 'icons/turf/floors/grass.dmi'

/turf/open/floor/grass/setup_broken_states()
	return list("damaged")

/turf/open/floor/grass/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(smoothing_flags)
		var/matrix/translation = new
		translation.Translate(-9, -9)
		transform = translation
		icon = smooth_icon

/turf/open/floor/dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors/common.dmi'
	icon_state = "cracked_dirt"
	base_icon_state = "cracked_dirt"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/rock
	name = "rock"
	icon = 'icons/turf/floors/common.dmi'
	icon_state = "rock_floor"
	base_icon_state = "rock_floor"
	color = "#707070"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/mud
	gender = PLURAL
	name = "mud"
	desc = "Thick, claggy and waterlogged."
	icon = 'icons/turf/floors/common.dmi'
	icon_state = "dark_mud"
	base_icon_state = "dark_mud"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/sand
	gender = PLURAL
	name = "sand"
	desc = "It's coarse and gets everywhere."
	icon = 'icons/turf/floors/common.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/sand/Initialize(mapload, inherited_virtual_z)
	. = ..()
	if(prob(10))
		icon_state = "[base_icon_state][rand(1,5)]"

/turf/open/floor/dry_seafloor
	gender = PLURAL
	name = "dry seafloor"
	desc = "Should have stayed hydrated."
	icon = 'icons/turf/floors/common.dmi'
	icon_state = "dry"
	base_icon_state = "dry"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/wasteland
	name = "cracked earth"
	desc = "Looks a bit dry."
	icon = 'icons/turf/floors/wasteland.dmi'
	icon_state = "wasteland"
	base_icon_state = "wasteland"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/wood
	name = "wooden floor"
	desc = "Stylish dark wood."
	icon = 'icons/turf/floors/wood.dmi'
	icon_state = "wood"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/cobblestone
	name = "cobblestone"
	icon = 'icons/turf/floors/cobblestone.dmi'
	icon_state = "cobblestone"
	base_icon_state = "cobblestone"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/cobblestone/dark
	icon_state = "cobblestone_dark"

/turf/open/floor/stone
	name = "stone floor"
	icon = 'icons/turf/floors/stone.dmi'
	icon_state = "stone"
	base_icon_state = "stone"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/sandstone
	name = "sandstone floor"
	icon = 'icons/turf/floors/stone.dmi'
	icon_state = "sandstone"
	base_icon_state = "sandstone"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
