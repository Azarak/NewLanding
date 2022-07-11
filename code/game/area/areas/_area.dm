/**
 * # area
 *
 * A grouping of tiles into a logical space, mostly used by map editors
 */
/area
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	//Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

	///Do we have an active fire alarm?
	var/fire = FALSE
	///How many fire alarm sources do we have?
	var/triggered_firealarms = 0
	///Whether there is an atmos alarm in this area
	var/atmosalm = FALSE
	var/poweralm = FALSE
	var/lightswitch = TRUE

	/// All beauty in this area combined, only includes indoor area.
	var/totalbeauty = 0
	/// Beauty average per open turf in the area
	var/beauty = 0
	/// If a room is too big it doesn't have beauty.
	var/beauty_threshold = 150

	/// For space, the asteroid, lavaland, etc. Used with blueprints or with weather to determine if we are adding a new area (vs editing a station room)
	var/outdoors = FALSE

	/// Size of the area in open turfs, only calculated for indoors areas.
	var/areasize = 0

	///Will objects this area be needing power?
	var/requires_power = TRUE
	/// This gets overridden to 1 for space in area/.
	var/always_unpowered = FALSE

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE

	var/has_gravity = STANDARD_GRAVITY

	flags_1 = CAN_BE_DIRTY_1

	var/list/firedoors
	var/list/cameras
	var/list/firealarms
	var/firedoors_last_closed_on = 0

	///Typepath to limit the areas (subtypes included) that atoms in this area can smooth with. Used for shuttles.
	var/area/area_limited_icon_smoothing

	///This datum, if set, allows terrain generation behavior to be ran on Initialize()
	var/datum/map_generator/map_generator

	/// Default network root for this area aka station, lavaland, etc
	var/network_root_id = null
	/// Area network id when you want to find all devices hooked up to this area
	var/network_area_id = null

	///Used to decide what kind of reverb the area makes sound have
	var/sound_environment = SOUND_ENVIRONMENT_NONE

	/// Whether the area is underground, checked for the purposes of above/underground weathers
	var/underground = FALSE

	/// Lazy list of all turfs adjacent to a day/night cycle. Associative from turf to bitfield (8 bit smoothing bitmap)
	var/list/day_night_adjacent_turfs
	/// Lazy list of all turfs affected by day/night blending associative to their applied appearance.
	var/list/day_night_turf_appearance_translation
	var/last_day_night_color
	var/last_day_night_alpha
	var/last_day_night_luminosity
	var/datum/day_night_controller/subbed_day_night_controller

	/// Main ambience that will play for users in the area.
	var/main_ambience = AMBIENCE_GENERIC
	/// A list of miscellanous ambient noises that will also play for users in the area.
	var/list/ambient_noises

/**
 * A list of teleport locations
 *
 * Adding a wizard area teleport list because motherfucking lag -- Urist
 * I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game
 */
GLOBAL_LIST_EMPTY(teleportlocs)

/**
 * Generate a list of turfs you can teleport to from the areas list
 *
 * Includes areas if they're not a shuttle or not not teleport or have no contents
 *
 * The chosen turf is the first item in the areas contents that is a station level
 *
 * The returned list of turfs is sorted by name
 */
/proc/process_teleport_locs()
	for(var/V in GLOB.sortedAreas)
		var/area/AR = V
		if(istype(AR, /area/shuttle) || AR.area_flags & NOTELEPORT)
			continue
		if(GLOB.teleportlocs[AR.name])
			continue
		if (!AR.contents.len)
			continue
		var/turf/picked = AR.contents[1]
		if (picked && is_station_level(picked))
			GLOB.teleportlocs[AR.name] = AR

	sortTim(GLOB.teleportlocs, /proc/cmp_text_asc)

/**
 * Called when an area loads
 *
 *  Adds the item to the GLOB.areas_by_type list based on area type
 */
/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if (area_flags & UNIQUE_AREA)
		GLOB.areas_by_type[type] = src
	return ..()

/*
 * Initalize this area
 *
 * intializes the dynamic area lighting and also registers the area with the z level via
 * reg_in_areas_in_z
 *
 * returns INITIALIZE_HINT_LATELOAD
 */
/area/Initialize(mapload)
	icon_state = ""
	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

		if(dynamic_lighting == DYNAMIC_LIGHTING_FORCED)
			dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
			luminosity = 0
		else if(dynamic_lighting != DYNAMIC_LIGHTING_IFSTARLIGHT)
			dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	if(dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
		dynamic_lighting = CONFIG_GET(flag/starlight) ? DYNAMIC_LIGHTING_ENABLED : DYNAMIC_LIGHTING_DISABLED


	. = ..()

	if(!IS_DYNAMIC_LIGHTING(src))
		add_overlay(/obj/effect/fullbright)

	reg_in_areas_in_z()

	if(!mapload)
		if(!network_root_id)
			network_root_id = STATION_NETWORK_ROOT // default to station root because this might be created with a blueprint

	return INITIALIZE_HINT_LATELOAD

/**
 * Sets machine power levels in the area
 */
/area/LateInitialize()

/area/proc/RunGeneration()
	if(map_generator)
		map_generator = new map_generator()
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.generate_terrain(turfs)

/area/proc/test_gen()
	if(map_generator)
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.generate_terrain(turfs)


/**
 * Register this area as belonging to a z level
 *
 * Ensures the item is added to the SSmapping.areas_in_z list for this z
 */
/area/proc/reg_in_areas_in_z()
	if(!length(contents))
		return
	var/list/areas_in_z = SSmapping.areas_in_z
	update_areasize()
	if(!z)
		WARNING("No z found for [src]")
		return
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] += src
	UpdateDayNightTurfs(find_controller = TRUE)

/**
 * Destroy an area and clean it up
 *
 * Removes the area from GLOB.areas_by_type and also stops it processing on SSobj
 *
 * This is despite the fact that no code appears to put it on SSobj, but
 * who am I to argue with old coders
 */
/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	GLOB.sortedAreas -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/**
 * Generate a power alert for this area
 *
 * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
 */
/area/proc/poweralert(state, obj/source)
	if (area_flags & NO_ALERTS)
		return

/**
 * Generate an atmospheric alert for this area
 *
 * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
 */
/area/proc/atmosalert(isdangerous, obj/source)
	if (area_flags & NO_ALERTS)
		return
	if(isdangerous != atmosalm)

		atmosalm = isdangerous
		return TRUE
	return FALSE

/**
 * Try to close all the firedoors in the area
 */
/area/proc/ModifyFiredoors(opening)
	return
/**
 * Generate a firealarm alert for this area
 *
 * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
 *
 * Also starts the area processing on SSobj
 */
/area/proc/firealert(obj/source)
	START_PROCESSING(SSobj, src)

/**
 * Reset the firealarm alert for this area
 *
 * resets the alert sent to all ai players, alert consoles, drones and alarm monitor programs
 * in the world
 *
 * Also cycles the icons of all firealarms and deregisters the area from processing on SSOBJ
 */
/area/proc/firereset(obj/source)
	STOP_PROCESSING(SSobj, src)

///Get rid of any dangling camera refs
/area/proc/clear_camera()
	return

/**
 * If 100 ticks has elapsed, toggle all the firedoors closed again
 */
/area/process()
	if(!triggered_firealarms)
		firereset() //If there are no breaches or fires, and this alert was caused by a breach or fire, die
	if(firedoors_last_closed_on + 100 < world.time) //every 10 seconds
		ModifyFiredoors(FALSE)

/**
 * Raise a burglar alert for this area
 *
 * Close and locks all doors in the area and alerts silicon mobs of a break in
 *
 * Alarm auto resets after 600 ticks
 */
/area/proc/burglaralert(obj/trigger)
	if (area_flags & NO_ALERTS)
		return
	//Trigger alarm effect
	set_fire_alarm_effect()

/**
 * Trigger the fire alarm visual affects in an area
 *
 * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
 */
/area/proc/set_fire_alarm_effect()
	fire = TRUE
	if(!triggered_firealarms) //If there aren't any fires/breaches
		triggered_firealarms = INFINITY //You're not allowed to naturally die
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/**
 * unset the fire alarm visual affects in an area
 *
 * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
 */
/area/proc/unset_fire_alarm_effects()
	fire = FALSE
	triggered_firealarms = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/**
 * Update the icon state of the area
 *
 * Im not sure what the heck this does, somethign to do with weather being able to set icon
 * states on areas?? where the heck would that even display?
 */
/area/update_icon_state()
	var/weather_icon
	for(var/datum/weather/W as anything in SSweather.GetAllCurrentWeathers())
		if(W.stage != END_STAGE && (src in W.impacted_areas))
			W.update_areas()
			weather_icon = TRUE
	if(!weather_icon)
		icon_state = null
	return ..()

/**
 * Call back when an atom enters an area
 *
 * Sends signals COMSIG_AREA_ENTERED and COMSIG_ENTER_AREA (to a list of atoms)
 */
/area/Entered(atom/movable/arrived, direction)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, arrived, direction)
	for(var/atom/movable/recipient as anything in arrived.area_sensitive_contents)
		SEND_SIGNAL(recipient, COMSIG_ENTER_AREA, src)

///Divides total beauty in the room by roomsize to allow us to get an average beauty per tile.
/area/proc/update_beauty()
	if(!areasize)
		beauty = 0
		return FALSE
	if(areasize >= beauty_threshold)
		beauty = 0
		return FALSE //Too big
	beauty = totalbeauty / areasize


/**
 * Called when an atom exits an area
 *
 * Sends signals COMSIG_AREA_EXITED and COMSIG_EXIT_AREA (to a list of atoms)
 */
/area/Exited(atom/movable/gone, direction)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, gone, direction)
	for(var/atom/movable/recipient as anything in gone.area_sensitive_contents)
		SEND_SIGNAL(recipient, COMSIG_EXIT_AREA, src)


/**
 * Setup an area (with the given name)
 *
 * Sets the area name, sets all status var's to false and adds the area to the sorted area list
 */
/area/proc/setup(a_name)
	name = a_name
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE
	always_unpowered = FALSE
	area_flags &= ~VALID_TERRITORY
	area_flags &= ~BLOBS_ALLOWED
	addSorted()
/**
 * Set the area size of the area
 *
 * This is the number of open turfs in the area contents, or FALSE if the outdoors var is set
 *
 */
/area/proc/update_areasize()
	if(outdoors)
		return FALSE
	areasize = 0
	for(var/turf/open/T in contents)
		areasize++

/**
 * Causes a runtime error
 */
/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/**
 * Causes a runtime error
 */
/area/drop_location()
	CRASH("Bad op: area/drop_location() called")

/// A hook so areas can modify the incoming args (of what??)
/area/proc/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags)
	return flags


/// Called when a living mob that spawned here, joining the round, receives the player client.
/area/proc/on_joining_game(mob/living/boarder)
	return
