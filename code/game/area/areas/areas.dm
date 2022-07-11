/area/space
	name = "Space"

/**
 * Update the icon of the area (overridden to always be null for space
 */
/area/space/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	icon_state = null

/area/unassigned
	name = "unassigned area"

/area/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY

/area/testroom
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	name = "Test Room"
	icon_state = "purple"

/area/outdoors
	icon_state = "green"
	flags_1 = NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED | NO_ALERTS
	main_ambience = AMBIENCE_JUNGLE
	outdoors = TRUE

/area/outdoors/jungle
	name = "Jungle"
	icon_state = "green"

/area/outdoors/coast
	name = "Coast"
	icon_state = "yellow"

/area/outdoors/caves
	name = "Caves"
	icon_state = "cave"
	underground = TRUE

/area/indoors
	icon_state = "purple"
	flags_1 = NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED | NO_ALERTS
	main_ambience = AMBIENCE_AWAY
	outdoors = FALSE

/area/indoors/house
	name = "House"
